namespace :zbots do
  desc "Create or update initial bots from bots/*"
  task bootstrap: :environment do
    empty = Bot.where(name: "EmptyBot").first_or_initialize
    empty.update!(username: 'asdf', api_key: 'asdf')

    ruby = Bot.where(name: "RubyBot", parent: empty.name).first_or_initialize
    ruby.update!(username: 'asdf', api_key: 'asdf', code: File.read("bots/ruby_bot.rb"))

    rubycmd = Bot.where(name: "RubyCommandBot", parent: ruby.name).first_or_initialize
    rubycmd.update!(
      username: 'asdf',
      api_key: 'asdf',
      code: File.read("bots/ruby_command_bot.rb"),
      state: {
        "watchword" => "cmdbot",
      },
    )

    copy = CopyBot.where(name: "CopyBot", parent: rubycmd.name).first_or_initialize
    copy.update!(
      username: 'asdf',
      api_key: 'asdf',
      code: File.read("bots/copy_bot.rb"),
      state: {
        "watchword" => "copybot",
      }
    )
    CopyBot.update_state
  end
end
