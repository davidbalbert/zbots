class Dispatcher
  attr_reader :destination

  def initialize(destination)
    @destination = destination
  end

  def dispatch(msg)
    Bot.all.each do |b|
      b.call(msg, destination)
    end
  end
end
