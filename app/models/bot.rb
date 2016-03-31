class Bot < ApplicationRecord
  belongs_to :parent, class_name: 'Bot', optional: true
  has_many :children, class_name: 'Bot', foreign_key: :parent_id

  validates :username, :api_key, presence: true
  validates :parent_id, presence: true, unless: :root?
  validates :watchword, uniqueness: true
  validate :only_one_root_bot

  def handle(msg, destination)
    response = Message.new(
      username,
      msg.stream,
      msg.subject,
      "I got your message @**#{msg.from}**"
    )
    destination.send(response)
  end

  private

  def only_one_root_bot
    if Bot.where(root: true).count > 0 && root?
      errors[:root] << "cannot be set for more than one bot"
    end
  end
end
