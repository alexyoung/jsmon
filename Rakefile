namespace :db do
  desc "Migrate the database"
  task :migrate => :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end

  task :environment do
    require 'jsmon'
  end

  desc "Install some sample data"
  task :fixtures => :environment do
    require 'active_record/fixtures'
    fixtures = Dir.glob('test/fixtures/*.yml').map { |file| File.basename(file, File.extname(file)) }
    puts "Loading: #{fixtures.join(', ')} into: #{ENV['RACK_ENV'] || 'development'}"
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), 'test', 'fixtures'), fixtures)
  end

  namespace :test do
    desc "Clone the active database structure into test"
    task :clone_structure do
      ENV['RACK_ENV'] = 'test'
      Rake::Task['db:environment'].execute
      Rake::Task['db:migrate'].execute
    end
  end
end

