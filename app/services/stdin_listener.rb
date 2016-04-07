class StdinListener
  attr_reader :dispatcher

  def initialize
    @dispatcher = Dispatcher.new(StdoutDestination.new)

    trap(:INT) do
      exit
    end
  end

  def listen
    loop do
      message = read_message
      dispatcher.dispatch(message)
    end
  end

  private

  def read_message
    print "From: "
    from = $stdin.gets.chomp

    print "Stream: "
    stream = $stdin.gets.chomp

    print "Subject: "
    subject = $stdin.gets.chomp

    puts "Enter your message terminated by a \".\""
    puts


    s = ""

    loop do
      line = $stdin.gets

      if line.chomp == ".."
        s << ".\n"
      elsif line.chomp == "."
        break
      else
        s << line
      end
    end

    Message.new(
      from: from,
      stream: stream,
      subject: subject,
      body: s.chomp
    )
  end
end
