namespace :zbots do
  desc "Create or update initial bots from bots/*"
  task bootstrap: :environment do
    empty = Bot.where(root: true).first_or_initialize
    empty.update!(name: "EmptyBot", username: 'asdf', api_key: 'asdf')

    ruby = empty.children.where(name: "RubyBot").first_or_initialize
    ruby.update!(username: 'asdf', api_key: 'asdf', code: File.read("bots/ruby_bot.rb"))

    rubycmd = ruby.children.where(name: "RubyCommandBot").first_or_initialize
    rubycmd.update!(
      username: 'asdf',
      api_key: 'asdf',
      code: File.read("bots/ruby_command_bot.rb"),
      state: {
        "watchword" => "cmdbot",
      },
    )

    copy = rubycmd.children.where(name: "CopyBot", type: "CopyBot").first_or_initialize
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
