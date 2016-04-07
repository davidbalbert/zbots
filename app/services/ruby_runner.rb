require 'tempfile'

class RubyRunner
  attr_reader :message, :code

  def initialize(message, code)
    @message = message
    @code    = code
  end

  def run
    Tempfile.create('zbots') do |f|
      f.write(code)
      f.close

      IO.popen("ruby #{f.path}", "r+") do |pipe|
        pipe.write(message.to_s)

        pipe.close_write

        pipe.read
      end
    end
  end
end
