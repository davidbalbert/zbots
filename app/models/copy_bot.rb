class CopyBot < Bot
  def self.update_state
    copy = all.first!

    copy.update!(state: state_from_db)
  end

  def self.state_from_db
    {
      "watchword" => "copybot",
      "bots" => Bot.all.map { |b| {"name" => b.name, "parent" => b.parent_name} },
    }
  end

  def call(msg, destination)
    super

    old_bots = self.class.state_from_db["bots"]
    new_bots = state["bots"]

    to_create = new_bots - old_bots
    # to_destroy = old_bots - new_bots

    to_create.each do |bot|
      parent = Bot.where(name: bot["parent"]).first!

      Bot.create!(
        name: bot["name"],
        parent: parent,
        username: 'asdf',
        api_key: 'asdf',
        code: parent.code,
        state: parent.state
      )

      resp = Message.new(
        from: name,
        stream: msg.stream,
        subject: msg.subject,
        body: "Created #{bot["name"]}!",
      )

      destination.send(resp)
    end
  end
end
