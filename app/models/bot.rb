class Bot < ApplicationRecord
  belongs_to :parent, class_name: 'Bot', optional: true
  has_many :children, class_name: 'Bot', foreign_key: :parent_id

  validates :username, :api_key, :code, presence: true
  validates :parent_id, presence: true, unless: :root?
  validate :only_one_root
  validate :only_one_copy

  def call(msg)
    IO.popen("ruby -e '#{code}'", "r+") do |pipe|
      pipe.write(msg.to_s)

      pipe.read
    end
  end

  private

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
