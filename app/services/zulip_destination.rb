class ZulipDestination
  attr_reader :z

  def initialize
    @z = ZulipClient.new
  end

  def send(message)
    if message
      z.send(message.stream, message.subject, message.body)
    end
  end
end
