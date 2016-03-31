class Command < ApplicationRecord
  belongs_to :bot

  validates :name, presence: true
  validates :method_name, presence: true, if: :builtin?
  validates :body, presence: true, unless: :builtin?

  def run(msg)
    if builtin?
      bot.send(method_name, msg)
    else
      "normal commands are not yet supported"
    end
  end
end
