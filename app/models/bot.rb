class Bot < ApplicationRecord
  belongs_to :parent, class_name: 'Bot', optional: true
  has_many :children, class_name: 'Bot', foreign_key: :parent_id
  has_many :commands

  validates :username, :api_key, presence: true
  validates :parent_id, presence: true, unless: :root?
  validates :watchword, uniqueness: true
  validate :only_one_root_bot

  def handle(msg, destination)
    response = Message.new(
      from: username,
      stream: msg.stream,
      subject: msg.subject,
      body: "I got your message @**#{msg.from}**"
    )
    destination.send(response)
  end

  def handle_cmd(msg, destination)

  end

  private

  def clone(

  end

  def only_one_root_bot
    if Bot.where(root: true).count > 0 && root?
      errors[:root] << "cannot be set for more than one bot"
    end
  end
end
