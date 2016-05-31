require 'helpers'

RSpec.configure do |c|
  c.include Helpers
end

require "country_dal"

describe DAL::CountryDal do

  before(:each) do
    @mock_mysql = get_mysql_mock
    @mock_memcache = double('Memcache')
    @mock_log = double('Log')

    @country_dal = DAL::CountryDal.new(@mock_mysql, @mock_memcache, @mock_log)
  end

  describe '#initialize' do
    it 'should have the correct fields and db info' do
      @country_dal.table_name.should eq 'countries'
      @country_dal.fields.should eq(        
        "code_alpha_2"          => { :type=>:string, :length=>2, :required=>true },
        "code_alpha_3"          => { :type=>:string, :length=>3, :required=>true },
        "code_numeric"          => { :type=>:string, :length=>3, :required=>true },
        "name"                  => { :type=>:string, :length=>128, :required=>true },
        "default_currency_code" => { :type=>:string, :length=>3, :required=>true },
      )
      @country_dal.relations.should eq({
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
      })
      @country_dal.primary_key.should eq 'code_alpha_2'
    end
  end

  describe '#get_one' do
    before(:each) do
      memcache_null(@mock_memcache)
    end

    it 'should return a single country based on a query with a single field' do
      testdata = [
        {:code_alpha_2=>"AU", :name => "Australia"},
      ]

      result_mock = get_mysql_result_mock(testdata)

      @mock_mysql.should_receive(:query)
        .with("SELECT `code_alpha_2`,`code_alpha_3`,`code_numeric`,`name`,`default_currency_code` FROM `countries` WHERE (`code_alpha_2` = 'AU')")
        .and_return(result_mock)

      @country_dal.get_one({ "code_alpha_2" => 'AU'}).should eq(testdata[0])
    end

    it 'should return a single country based on a query with a multiple fields' do
      testdata = [
        {:code_alpha_2=>"AU", :name => "Australia"},
      ]

      result_mock = get_mysql_result_mock(testdata)

      @mock_mysql.should_receive(:query)
        .with("SELECT `code_alpha_2`,`code_alpha_3`,`code_numeric`,`name`,`default_currency_code` FROM `countries` WHERE (`code_alpha_2` = 'AU') AND (`default_currency_code` = 'AUD')")
        .and_return(result_mock)

      @country_dal.get_one({ "code_alpha_2" => 'AU', 'default_currency_code' => 'AUD'})
        .should eq(testdata[0])
    end
  end

end