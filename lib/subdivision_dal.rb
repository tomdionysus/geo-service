require 'rubygems'

module DAL
	class SubdivisionDal < CrudService::Dal

    def initialize(mysql, memcache, log) 
      super mysql, memcache, log
      @table_name = 'subdivisions'
      @fields = {
        "code"                  => { :type=>:string, :length=>10, :required=>true },
        "name"                  => { :type=>:string, :length=>128, :required=>true },
        "category"              => { :type=>:string, :length=>128, :required=>true },
        "country_code_alpha_2"  => { :type=>:string, :length=>2, :required=>true},
        "parent_code"           => { :type=>:string, :length=>10 },
        "timezones"             => { :type=>:string, :length=>128, :required=>true },
      }
      @relations = {
        "subdivisions" => { 
          :type         => :has_many, 
          :table        => 'subdivisions',
          :table_key    => 'parent_code', 
          :this_key     => 'code',
          :table_fields => 'code,name,category,timezones', 
        },
      }
      @primary_key = 'code'
    end
	end
end