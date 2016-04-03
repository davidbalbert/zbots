require 'tempfile'

class Bot < ApplicationRecord
  belongs_to :parent, class_name: 'Bot', optional: true
  has_many :children, class_name: 'Bot', foreign_key: :parent_id

  validates :name, presence: true, uniqueness: true
  validates :api_key, presence: true
  validates :parent_id, :code, presence: true, unless: :root?
  validate :only_one_root, on: :create
  validate :only_one_copy, on: :create

  before_create :set_parent_name

  def call(msg, destination)
    resp = Message.parse(run(msg), self)

    if resp
      update!(state: resp.state) if resp.state
    end

    destination.send(resp)
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
    if CopyBot.count > 0 && type == 'CopyBot'
      errors[:type] << "cannot be set for more than one bot"
    end
  end

  def set_parent_name
    self.parent_name = parent&.name
  end
end
