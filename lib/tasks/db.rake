# Silence foreign key queries while running `bin/rake db:migrate`
t = Rake::Task['db:schema:dump']

def t.invoke
  ActiveRecord::Base.logger.silence do
    super
  end
end
