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

def pm?
  type == "PM"
end

def parse_command!
  cmdline = body.split("\n").first

  if cmdline.nil?
    $command = nil
    $args = []

    return nil
  end

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

def_command "help", "Show this message", -> do
  resp = ""

  commands.each do |name, (desc, block)|
    args = block.parameters.map { |a| a[1].to_s }.join(" ")
    args = " " + args if args != ""

    resp << "#{name} #{args} - #{desc}\n"
  end

  resp
end

def_command "hello", "Say hello", -> do
  "Hi There"
end

#################################################

WATCHWORD = state["watchword"]
run_command
