require 'rubygems'

module DAL
	class CurrencyDal < CrudService::Dal

    def initialize(mysql, memcache, log) 
      super mysql, memcache, log
      @table_name = 'currencies'
      @fields = {
        "code"            => { :type=>:string, :length=>3, :required=>true },
        "name"            => { :type=>:string, :length=>128, :required=>true },
        "symbol"          => { :type=>:string, :length=>10, :required=>true },
        "decimal_places"  => { :type=>:integer, :required=>true },
      }
      @relations = {
        "countries" => { 
          :type           => :has_many, 
          :table          => 'countries',
          :table_key      => 'default_currency_code', 
          :this_key       => 'code',
          :table_fields   => 'code_alpha_2,name'
        },
      }
      @primary_key = 'code'
    end
	end
end