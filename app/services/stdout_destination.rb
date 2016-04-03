class StdoutDestination
  def send(msg)
    if msg.present?
      puts msg.to_s
      puts
    end
  end
end
