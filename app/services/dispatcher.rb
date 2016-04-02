class Dispatcher
  attr_reader :destination

  def initialize(destination)
    @destination = destination
  end

  def dispatch(msg)
    Bot.all.each do |b|
      destination.send(b.call(msg))
    end
  end
end
