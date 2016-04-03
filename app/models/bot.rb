require 'tempfile'

class Bot < ApplicationRecord
  belongs_to :parent, class_name: 'Bot', optional: true
  has_many :children, class_name: 'Bot', foreign_key: :parent_id

  validates :username, :api_key, presence: true
  validates :parent_id, :code, presence: true, unless: :root?
  validate :only_one_root, on: :create
  validate :only_one_copy, on: :create

  def self.update_state
    copy = where(copy: true).first!

    copy.update!(state: {
      "bots" => all.map { |b| {"name": b.name, parent: b.parent&.name} },
    })
  end

  def call(msg)
    resp = Message.parse(run(msg), self)

    if resp
      update!(state: resp.state) if resp.state
    end

    resp
  end

  private

  def run(msg)
    Tempfile.create('zbots') do |f|
      f.write(code)
      f.close

      IO.popen("ruby #{f.path}", "r+") do |pipe|
        pipe.write(msg.with_state(state).to_s)
        pipe.close_write

        pipe.read
      end
    end
  end

  def only_one_root
    if Bot.where(root: true).count > 0 && root?
      errors[:root] << "cannot be set for more than one bot"
    end
  end

  def only_one_copy
    if Bot.where(copy: true).count > 0 && copy?
      errors[:copy] << "cannot be set for more than one bot"
    end
  end
end
