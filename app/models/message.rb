require 'json'

class Message
  class ParseError < StandardError; end

  attr_reader :from, :stream, :subject, :body, :state

  def self.parse(s, bot)
    return if s.blank?

    headers, body = s.split("\n\n", 2)

    if headers.blank?
      raise ParseError, "Can't have headers without a body"
    elsif body.blank?
      raise ParseError, "Can't have body without headers"
    end

    h = headers.split("\n").map { |header| header.split(": ", 2) }.to_h

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
      from: bot.name,
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
      #{header_string}

      #{body}
    END
  end

  def headers
    h = {
      "From" => from,
      "Type" => "Message",
      "Stream" => stream,
      "Subject" => subject,
    }

    h["State"] = JSON.generate(state) if state

    h
  end

  private

  def header_string
    headers.map { |k, v| "#{k}: #{v}" }.join("\n")
  end
end
