require 'rubygems'

module DAL
	class RegionDal < CrudService::Dal

    def initialize(mysql, memcache, log) 
      super mysql, memcache, log
      @table_name = 'regions'
      @fields = {
        "code"        => { :type=>:string, :length=>3, :required=>true },
        "name"        => { :type=>:string, :length=>128, :required=>true },
        "parent_code" => { :type=>:string, :length=>3 },
      }
      @relations = {
        "countries" => { 
          :type         => :has_many_through, 
          :table        => 'countries',
          :link_table   => 'region_countries',
          :link_key     => 'region_code',
          :link_field   => 'country_code_alpha_2',
          :table_key    => 'code_alpha_2', 
          :this_key     => 'code',
          :table_fields => 'code_alpha_2,code_alpha_3,code_numeric,name,default_currency_code',
        },
        "subregions" => { 
          :type         => :has_many, 
          :table        => 'regions',
          :table_key    => 'parent_code', 
          :this_key     => 'code',
          :table_fields => 'code,name'
        },
      }
      @primary_key = 'code'
    end
	end
end