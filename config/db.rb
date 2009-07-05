configure :development do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/development.sqlite'
  )
end

configure :production do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/production.sqlite'
  )
end

configure :test do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/test.sqlite'
  )
end
