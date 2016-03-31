class Message
  attr_reader :from, :stream, :subject, :body

  delegate :match, to: :body

  def initialize(from:, stream:, subject:, body:)
    @from    = from
    @stream  = stream
    @subject = subject
    @body    = body
  end

  def to_s
    <<~END
      From: #{from}
      Type: Message
      Stream: #{stream}
      Subject #{subject}

      #{body}
    END
  end
end
