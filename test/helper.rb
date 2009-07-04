ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), '..', 'jsmon')
require 'test/unit'
require 'json'
require 'active_record/fixtures' 

fixtures = Dir.glob('test/fixtures/*.yml').map { |file| File.basename(file, File.extname(file)) }
Fixtures.create_fixtures(File.join(File.dirname(__FILE__), 'fixtures'), fixtures)
