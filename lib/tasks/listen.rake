desc "Listens to incomming Zulip messages and responds to them"
task listen: :environment do
  puts "Zbots is listening..."
  puts

  listener = ZulipListener.new
  listener.listen
end

namespace :listen do
  desc "A command line interface to test zbots without Zulip"
  task cli: :environment do
    puts "Zbots is listening..."
    puts

    listener = StdinListener.new
    listener.listen
  end
end
