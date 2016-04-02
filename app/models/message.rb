require 'json'

class Message
  attr_reader :from, :stream, :subject, :body, :state

  def self.parse(s)

  end

  def initialize(from:, stream:, subject:, body:, state: nil)
    @from    = from
    @stream  = stream
    @subject = subject
    @body    = body
    @state   = state
  end

  def with_state(state)
    Message.new(
      from: from,
      stream: stream,
      subject: subject,
      body: body,
      state: state
    )
  end

  def to_s
    <<~END
      #{headers}

      #{body}
    END
  end

  private

  def headers
    h = {
      "Type" => "Message",
      "From" => from,
      "Stream" => stream,
      "Subject" => subject,
    }

    h["State"] = JSON.generate(state) if state

    h.map { |k, v| "#{k}: #{v}" }.join("\n")
  end
end
