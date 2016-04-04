require 'json'

def parse_message!
  s = STDIN.read

  headers, body = s.split("\n\n", 2)
  h = headers.split("\n").map { |header| header.split(": ", 2) }.to_h

  state = JSON.parse(h["State"])

  $headers = h
  $state = state
  $body = body

  [$headers, $state, $body]
end

def headers
  $headers
end

def stream
  headers["Stream"]
end

def subject
  headers["Subject"]
end

def body
  $body
end

def state
  $state
end

def send_message(stream: $headers["Stream"], subject: $headers["Subject"], state: $state, body:)
  h = {
    "Type" => "Message",
    "Stream" => stream,
    "Subject" => subject,
  }

  if state
    h["State"] = JSON.generate(state)
  end

  puts <<~END
    #{h.map { |k, v| "#{k}: #{v}" }.join("\n")}

    #{body}
  END
end

#################################################

# parse_message!

# To send a response:
#
# send_message(body: "Hello, world!")
