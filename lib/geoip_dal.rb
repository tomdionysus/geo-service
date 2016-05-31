require 'rubygems'
require 'ipaddr'

module DAL
	class GeoIPDal < CrudService::Dal

    def initialize(mysql, memcache, log) 
      super mysql, memcache, log
      @table_name = 'geoip'
      @fields = {
        "ipstart"               => { :type=>:integer, :required=>true },
        "ipend"                 => { :type=>:integer, :required=>true },
        "country_code_alpha_2"  => { :type=>:string, :length=>2, :required=>true },
      }
      @relations = {
        "country" => { 
          :type         => :has_one, 
          :table        => 'country',
          :table_key    => 'code_alpha_2', 
          :this_key     => 'country_code_alpha_2',
          :table_fields => 'country_code_alpha_2,name,default_currency_code'
        },
      }
    end

    def get_one_by_ip(ip_address)
      ip = IPAddr.new @mysql.escape(ip_address)

      query = "SELECT `country_code_alpha_2` from `geoip` WHERE #{ip.to_i} BETWEEN `ipstart` AND `ipend`"

      results = cached_query(query,['geoip'])
      return nil if results.length == 0
      results[0]
    end
	end
end