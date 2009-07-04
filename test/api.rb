require File.join(File.dirname(__FILE__), 'helper')
require 'json'

begin
  require 'rack/test'
rescue LoadError
  puts "*** Please run get install rack-test to run these tests"
  raise
end

class ApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @service = Service.create :name => 'My cron script', :description => 'Runs every 12 hours'
    @service_state = ServiceState.create :service_id => @service.id, :state => 'success', :exit_code => 0
  end

  def app
    Sinatra::Application
  end

  def test_update_state
    get "/service/#{@service.code}/failure"
    assert last_response.ok?
    assert_equal 'failure', JSON.parse(last_response.body)['state']
  end

  def test_invalid_code
    get "/service/invalid/failure"
    assert !last_response.ok?
  end
  
  def test_get_service
    get "/service/#{@service.code}"
    last_response.body
    assert_equal 'My cron script', JSON.parse(last_response.body)['name']
  end

  def test_create_service
    post '/service', { :name => 'Another cron script', :description => 'This is a test' }
    assert_equal '/?created=true#manage', last_response.location
  end
end
