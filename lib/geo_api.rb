require 'rubygems'
require 'sinatra'
require 'ipaddr'

module API
	class GeoApi < Sinatra::Base

    register CrudService::Api

    before do

      if ['PUT', 'POST', 'DELETE'].include? request.request_method
        # TODO: Auth for POST, PUT, DELETE
        response.status = 401
        throw :halt
      end

      content_type 'application/json; charset=utf-8'

      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    end

    get "/" do
      content_type 'text/html; charset=utf-8'
      puts File.join(settings.base,"index.html")
      send_file File.join(settings.base,"index.html")
      200
    end

    crud_api 'regions', :region_service, 'code'
    crud_api 'countries', :country_service, 'code_alpha_2'
    crud_api 'subdivisions', :subdivision_service, 'code'
    crud_api 'currencies', :currency_service, 'code'
    crud_api 'languages', :language_service, 'code'

    # Edge case country/subdivision query
    get "/countries/:country_code_alpha_2/:code" do
      sanitize_params(params)
      return 400 unless settings.subdivision_service.valid_query?(params)

      subdivision = settings.subdivision_service.get_one_by_query(params)
      return 404 if subdivision.nil?
      JSON.fast_generate subdivision
    end

    # GeoIP lookup

    get "/geoip/:ip_address" do
      sanitize_params(params)

      return 400 if params['ip_address'].nil?

      begin
        ip = IPAddr.new params['ip_address']
      rescue
        return 400
      end

      country = settings.geoip_service.get_one_by_ip(params['ip_address'])
      return 404 if country.nil?
      JSON.fast_generate country
    end

    # Install
    get "/install" do
      stream do |out|
        out << "Starting..."
        require File.dirname(__FILE__)+"/installer"
        out << "Done"
      end
    end

    # Hide Errors
    not_found do
      404
    end

    error do
      params.each do |error|
        settings.log.error error
      end
      500
    end

    def sanitize_params(params)
      params.delete 'splat'
      params.delete 'captures'
    end
	end
end
