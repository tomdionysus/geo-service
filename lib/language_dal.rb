require 'rubygems'

module DAL
	class LanguageDal < CrudService::Dal

    def initialize(mysql, memcache, log) 
      super mysql, memcache, log
      @table_name = 'languages'
      @fields = {
        "code"          => { :type=>:string, :length=>2, :required=>true },
        "name"          => { :type=>:string, :length=>128, :required=>true },
        "native_name"   => { :type=>:string, :length=>128, :required=>true },
        "code_t"        => { :type=>:string, :length=>3, :required=>true },
        "code_b"        => { :type=>:string, :length=>3, :required=>true },
      }
      @relations = {
        "countries" => { 
          :type         => :has_many_through, 
          :table        => 'countries',
          :link_table   => 'country_languages',
          :this_key     => 'code',
          :link_key     => 'language_code', 
          :link_field   => 'country_code_alpha_2',
          :table_key    => 'code_alpha_2',
          :table_fields => 'code_alpha_2,name'
        },
      }
      @primary_key = 'code'
    end
	end
end