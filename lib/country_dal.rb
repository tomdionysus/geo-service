require 'rubygems'

module DAL
	class CountryDal < CrudService::Dal

    def initialize(mysql, memcache, log) 
      super mysql, memcache, log
      @table_name = 'countries'
      @fields = {
        "code_alpha_2"          => { :type=>:string, :length=>2, :required=>true },
        "code_alpha_3"          => { :type=>:string, :length=>3, :required=>true },
        "code_numeric"          => { :type=>:string, :length=>3, :required=>true },
        "name"                  => { :type=>:string, :length=>128, :required=>true },
        "default_currency_code" => { :type=>:string, :length=>3, :required=>true },
      }
      @relations = {
        "regions" => { 
          :type         => :has_many_through, 
          :table        => 'regions',
          :link_table   => 'region_countries',
          :link_key     => 'country_code_alpha_2',
          :link_field   => 'region_code',
          :table_key    => 'code', 
          :this_key     => 'code_alpha_2',
          :table_fields => 'code,name,parent_code',
        },
        "subdivisions" => { 
          :type         => :has_many, 
          :table        => 'subdivisions',
          :table_key    => 'country_code_alpha_2', 
          :this_key     => 'code_alpha_2',
          :table_fields => 'code,name,category,parent_code,timezones'
        },
        "currency" => { 
          :type         => :has_one, 
          :table        => 'currencies',
          :table_key    => 'code', 
          :this_key     => 'default_currency_code',
          :table_fields => 'code,name,symbol'
        },
        "languages" => { 
          :type         => :has_many_through, 
          :table        => 'languages',
          :link_table   => 'country_languages',
          :link_key     => 'country_code_alpha_2',
          :link_field   => 'language_code', 
          :table_key    => 'code', 
          :this_key     => 'code_alpha_2',
          :table_fields => 'code,name'
        },
      }
      @primary_key = 'code_alpha_2'
    end
	end
end