class Dispatcher
  attr_reader :destination

  def initialize(destination)
    @destination = destination
  end

  def dispatch(msg)
    if md = msg.match(/\A(\w+)/)
      watchword = md[1]
    end

    bot = Bot.where(watchword: watchword).first

    if bot
      bot.handle_cmd(msg, destination)
    end

    Bot.where(stream_all: true).each do |b|
      b.handle(msg, destination)
    end
  end
end
