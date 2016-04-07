require 'json'

def from
  ENV["From"]
end

def type
  ENV["Type"]
end

def stream
  ENV["Stream"]
end

def subject
  ENV["Subject"]
end

def body
  return $body if defined? $body
  $body = STDIN.read
end

def state
  return $state if defined? $state
  $state = ENV["State"] && JSON.parse(ENV["State"])
end

def send_message(stream: stream(), subject: subject(), state: state(), body:)
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

# To send a response:
#
# send_message(body: "Hello, world!")
