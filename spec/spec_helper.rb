require "rack/test"

require "server"

def app
  API::GeoApi
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

