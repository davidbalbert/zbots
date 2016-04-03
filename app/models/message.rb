require 'json'

class Message
  class ParseError < StandardError; end

  attr_reader :from, :stream, :subject, :body, :state

  def self.parse(s, bot)
    return if s.blank?

    headers, body = s.split("\n\n")

    if headers.blank?
      raise ParseError, "Can't have headers without a body"
    elsif body.blank?
      raise ParseError, "Can't have body without headers"
    end

    h = headers.split("\n").map { |header| header.split(": ") }.to_h

    if h["Type"].blank? || h["Type"] != "Message"
      raise ParseError, "Needs valid Type"
    end

    if h["Stream"].blank?
      raise ParseError, "Missing Stream"
    end

    if h["Subject"].blank?
      raise ParseError, "Missing Subject"
    end

    if h["State"].present?
      begin
        state = JSON.parse(h["State"])
      rescue JSON::ParserError => e
        raise ParseError, "State is not valid JSON"
      end
    end

    new(
      from: bot.username,
      stream: h["Stream"],
      subject: h["Subject"],
      body: body,
      state: state
    )
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
