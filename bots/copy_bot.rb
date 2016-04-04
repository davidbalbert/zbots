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

def pm?
  headers["Type"] == "PM"
end

def parse_command!
  cmdline = body.split("\n").first

  words = cmdline.split(/\s+/)

  if pm?
    $command = words[0]
    $args = words[1..-1]
  elsif WATCHWORD && words[0] == WATCHWORD
    $command = words[1]
    $args = words[2..-1]
  else
    $command = nil
    $args = []
  end

  $command
end

def command
  return $command if defined? $command

  parse_command!

  $command
end

def args
  return $args if defined? $args

  parse_comand!

  $args
end

$commands = {}

def commands
  $commands
end

def def_command(name, desc, block)
  commands[name] = [desc, block]
end

def run_command
  if command && commands[command]
    block = commands[command][1]

    if block.parameters.size == args.size
      resp = block.call(*args)
    else
      resp = "Wrong number of arguments for \"#{command}\" (got #{args.size}, expected #{block.parameters.size})"
    end

    send_message(body: resp)
  elsif command
    send_message(body: "Unknown command \"#{command}\". Try \"help\".")
  end
end

#################################################

# state:
# {
#   watchword: "copybot",
#
#   # set_code is not persisted
#   set_code: {
#     name: "MyBot",
#     code: "...",
#   }
#
#   bots: [
#     {
#       name: "EmptyBot",
#       parent: nil,
#     },
#     {
#       name: "RubyBot",
#       parent: "EmptyBot",
#     },
#     # etc.
#   ],
# }

def_command "help", "Show this message", -> do
  resp = ""

  commands.each do |name, (desc, block)|
    args = block.parameters.map { |a| a[1].to_s }.join(" ")

    resp << "#{name} #{args} - #{desc}\n"
  end

  resp
end


def_command "copy", "Copy a bot", ->(old_name, new_name) do
  old = state["bots"].find { |b| b["name"] == old_name }
  new = state["bots"].find { |b| b["name"] == new_name }

  if old.nil?
    return "No bot named #{old_name}"
  end

  if new
    return "There is already a bot named #{new_name}"
  end

  state["bots"] << {"name" => new_name, "parent" => old_name}

  "Copying #{old_name} to #{new_name}..."
end


CODE_REGEXP = /^```\w*\n(.*?)^```/m

def_command "setcode", "Set a bot's code", ->(bot_name) do
  bot = state["bots"].find { |b| b["name"] == bot_name }

  if bot.nil?
    return "No bot named #{bot_name}"
  end

  md = body.match(CODE_REGEXP)

  if md.nil?
    return "Send the code you want to set inside fenced code blocks"
  end

  state["set_code"] = {
    name: bot_name,
    code: md[1],
  }

  "Setting code for #{bot_name}..."
end


parse_message!

WATCHWORD = state["watchword"]

run_command
