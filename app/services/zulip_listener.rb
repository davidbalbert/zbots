class ZulipListener
  attr_reader :z, :dispatcher

  def initialize
    @z = ZulipClient.new
    @dispatcher = Dispatcher.new(ZulipDestination.new)

    trap(:INT) do
      exit
    end
  end

  def listen
    z.each_message do |resp|
      message = message_from_response(resp)
      dispatcher.dispatch(message)
    end
  end

  private

  def message_from_response(resp)
    Message.new(
      from: resp["sender_full_name"],
      stream: resp["display_recipient"],
      subject: resp["subject"],
      body: resp["content"],
    )
  end
end
