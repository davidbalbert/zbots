require 'net/http'
require 'uri'
require 'json'

class ZulipClient
  API_URL = 'https://api.zulip.com/v1'

  attr_reader :username, :key, :server

  def initialize(username: ENV["ZULIP_USERNAME"], key: ENV["ZULIP_API_KEY"], server: ENV["ZULIP_SERVER"])
    @username = username or raise ArgumentError, "keyword username or ENV['ZULIP_USERNAME'] required"
    @key      = key      or raise ArgumentError, "keyword key or ENV['ZULIP_API_KEY'] required"
    @server   = normalize_server(server)
  end

  def pm(to, body)
    post('/messages', {
      type: "private",
      to: JSON.generate(Array(to)),
      content: body
    })
  end

  def send(stream, subject, body)
    post("/messages", {
      type: "stream",
      to: stream,
      subject: subject,
      content: body
    })
  end

  def each_message
    resp = register(event_types: ["message"])
    queue_id, last_event_id = resp.values_at("queue_id", "last_event_id")

    each_event(queue_id, last_event_id) do |event|
      yield(event["message"]) if event["type"] == "message"
    end
  end

  def each_event(queue_id, last_event_id)
    loop do
      resp = get('/events', queue_id: queue_id, last_event_id: last_event_id)

      if resp["result"] != "success"
        puts "Error:"
        p resp
        sleep(1)
        next
      end

      resp["events"].each do |event|
        last_event_id = [last_event_id, event["id"].to_i].max
        yield(event)
      end
    end
  end

  def register(event_types: nil)
    data = {}
    data["event_types"] = JSON.generate(Array(event_types)) if event_types.present?

    post('/register', data)
  end

  private

  def get(path, data)
    request(path, Net::HTTP::Get, data)
  end

  def post(path, data)
    request(path, Net::HTTP::Post, data)
  end

  def request(path, method, data)
    uri = URI.parse("#{server}#{path}")
    resp = nil

    Net::HTTP.start(uri.host, uri.port) do |http|
      http.use_ssl = uri.scheme == "https"

      uri.query = URI.encode_www_form(data) if method == Net::HTTP::Get

      req = method.new(uri.request_uri)
      req.basic_auth(username, key)

      req.set_form_data(data.stringify_keys) if method == Net::HTTP::Post

      resp = http.request(req)
    end


    unless resp.code == "200"
      return {
        "result" => "error",
        "error_type" => "request_error",
        "response_code" => resp.code,
        "body" => resp.body,
      }
    end

    begin
      parsed_response = JSON.parse(resp.body)
    rescue JSON::ParserError => e
      return {
        "result" => "error",
        "error_type" => "parse_error",
        "body" => e.message,
      }
    end

    parsed_response
  end

  def normalize_server(server)
    return API_URL if server.blank?

    unless server.start_with?("http")
      server = "https://" + server
    end

    u = URI.parse(server)

    if u.host.end_with? "zulip.com"
      API_URL
    else
      u.path = "/api/v1"
      u.to_s
    end
  end
end
