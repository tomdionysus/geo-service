require "crud-service"
require "logger"
require "dalli"

# DALs
require "./lib/country_dal"
require "./lib/region_dal"
require "./lib/currency_dal"
require "./lib/subdivision_dal"
require "./lib/language_dal"
require "./lib/geoip_dal"

# Service
require "./lib/geoip_service"

# API
require "./lib/geo_api"

#class Server

# Setup Logger
log = Logger.new(STDOUT)

# Connect to MySQL
if ENV['DATABASE_URL'].nil? or not ENV['DATABASE_URL'].is_a? String 
  log.fatal("ENV['DATABASE_URL'] not supplied.")
  exit
end

# Test DB Connection
begin
  mysql_options = URI(ENV['DATABASE_URL'])

  mysql = Mysql2::Client.new(
    :host      => mysql_options.host,
    :username  => mysql_options.user,
    :password  => mysql_options.password,
    :database  => mysql_options.path[1..-1],
    :encoding  => 'utf8',
    :reconnect => true,
  )

  mysql.server_info
rescue Exception => msg
  log.fatal("Cannot connect to MySQL server #{ENV['DATABASE_URL']} - #{msg}")
  exit
end

# Connect to memcache
if ENV['MEMCACHED_HOST'].nil?
  memcache = nil
else
  memcache = Dalli::Client.new(ENV['MEMCACHED_HOST']+":"+ENV['MEMCACHED_PORT'])

  begin
    memcache.get('geoservice')
  rescue Exception => msg 
    log.warn("Cannot Contact Memcached server at #{ENV['MEMCACHED_HOST']+":"+ENV['MEMCACHED_PORT']} (#{msg}), disabling caching")
    memcache = nil
  end
end

# IoC DAL/Services

# - DAL
region_dal = DAL::RegionDal.new(mysql, memcache, log)
subdivision_dal = DAL::SubdivisionDal.new(mysql, memcache, log)
country_dal = DAL::CountryDal.new(mysql, memcache, log)
currency_dal = DAL::CurrencyDal.new(mysql, memcache, log)
language_dal = DAL::LanguageDal.new(mysql, memcache, log)
geoip_dal = DAL::GeoIPDal.new(mysql, memcache, log)

# Boot API
config = {
  :server => %w[thin mongrel webrick],

  :run => false,

  :bind => ENV['BIND'],
  :port => ENV['PORT'],
  
  :country_service     => CrudService::Service.new(country_dal, log),
  :region_service      => CrudService::Service.new(region_dal, log),
  :currency_service    => CrudService::Service.new(currency_dal, log),
  :subdivision_service => CrudService::Service.new(subdivision_dal, log),
  :language_service    => CrudService::Service.new(language_dal, log),
  :geoip_service       => Service::GeoIPService.new(geoip_dal, log),

  :base => File.dirname(__FILE__)+"/../public",
  
  :log => log,
  
  :show_exceptions => false,
}

config.each do |k, v|
  API::GeoApi.set k,v
end
