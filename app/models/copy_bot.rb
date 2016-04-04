class CopyBot < Bot
  def self.update_state
    copy = all.first!

    copy.update!(state: copy.state.merge(state_from_db))
  end

  def self.state_from_db
    {
      "bots" => Bot.all.map { |b| {"name" => b.name, "parent" => b.parent} },
    }
  end

  attr_accessor :set_code, :set_state

  private

  def before_state_save(msg, destination)
    self.set_code = state.delete("set_code")
    self.set_state = state.delete("set_state")
  end

  def after_send(msg, destination)
    old_bots = self.class.state_from_db["bots"]
    new_bots = state["bots"]

    if set_code
      bot = Bot.where(name: set_code["name"]).first!
      bot.update!(code: set_code["code"])

      reply(msg, "Updated code for #{bot.name}!", destination)
    end

    if set_state
      bot = Bot.where(name: set_state["name"]).first!
      bot.update!(set_state["state"])

      reply(msg, "Updated state for #{bot.name}!", destination)
    end

    to_create = new_bots - old_bots
    # to_destroy = old_bots - new_bots

    to_create.each do |bot|
      parent = Bot.where(name: bot["parent"]).first!

      Bot.create!(
        name: bot["name"],
        parent: parent.name,
        username: 'asdf',
        api_key: 'asdf',
        code: parent.code,
        state: parent.state
      )

      reply(msg, "Created #{bot["name"]}!", destination)
    end
  end

  def reply(msg, reply, destination)
    resp = Message.new(
      from: name,
      stream: msg.stream,
      subject: msg.subject,
      body: reply
    )

    destination.send(resp)
  end
end
