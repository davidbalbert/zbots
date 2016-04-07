class StdoutDestination
  def send(message)
    if message.present?
      puts message.to_s
      puts
    end
  end
end
