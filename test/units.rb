require File.join(File.dirname(__FILE__), 'helper')

fixtures = Dir.glob('test/fixtures/*.yml').map { |file| File.basename(file, File.extname(file)) }
Fixtures.create_fixtures(File.join(File.dirname(__FILE__), 'fixtures'), fixtures)

class ServiceTest < Test::Unit::TestCase
  def test_failing_services
    assert_equal Service.find(1), Service.failing_services.first
    assert_equal 1, Service.failing_services.size
  end
end
