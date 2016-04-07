require 'tempfile'

class Bot < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :api_key, presence: true
  validate :only_one_copy, on: :create

  def call(msg, destination)
    resp = Message.parse(run(msg), self)

    if resp&.state
      assign_attributes(state: resp.state)
    end

    before_state_save(msg, destination)

    save!
    destination.send(resp)

    after_send(msg, destination)
  end

  private

  def before_state_save(msg, destination)
    # defined in subclasses
  end

  def after_send(msg, destination)
    # defined in subclasses
  end

  def run(msg)
    RubyRunner.new(msg.with_state(state), code).run
  end

  def only_one_copy
    if CopyBot.count > 0 && type == 'CopyBot'
      errors[:type] << "cannot be set for more than one bot"
    end
  end
end
