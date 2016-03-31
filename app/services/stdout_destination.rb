class StdoutDestination
  def send(msg)
    puts msg.to_s
    puts
  end
end
