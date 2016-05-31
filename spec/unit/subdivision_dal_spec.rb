require 'helpers'

RSpec.configure do |c|
  c.include Helpers
end

require "subdivision_dal"

describe DAL::SubdivisionDal do

  before(:each) do
    @mock_mysql = get_mysql_mock
    @mock_memcache = double('Memcache')
    @mock_log = double('Log')

    @subdivision_dal = DAL::SubdivisionDal.new(@mock_mysql, @mock_memcache, @mock_log)
  end

  describe '#initialize' do
    it 'should have the correct fields and db info' do
      @subdivision_dal.table_name.should eq 'subdivisions'
      @subdivision_dal.fields.should eq( {
        "code"                  => { :type=>:string, :length=>10, :required=>true },
        "name"                  => { :type=>:string, :length=>128, :required=>true },
        "category"              => { :type=>:string, :length=>128, :required=>true },
        "country_code_alpha_2"  => { :type=>:string, :length=>2, :required=>true},
        "parent_code"           => { :type=>:string, :length=>10 },
        "timezones"         => { :type=>:string, :length=>128, :required=>true },
      })
      @subdivision_dal.relations.should eq({
        "subdivisions" => { 
          :type         => :has_many, 
          :table        => 'subdivisions',
          :table_key    => 'parent_code', 
          :this_key     => 'code',
          :table_fields => 'code,name,category,timezones', 
        },
      })
      @subdivision_dal.primary_key.should eq 'code'
    end
  end

  describe '#get_one' do
    before(:each) do
      memcache_null(@mock_memcache)
    end

    it 'should return a single subdivision based on a query with a single field' do
      testdata = [
        {:code=>"AU-NSW", :name => "New South Wales"},
      ]

      result_mock = get_mysql_result_mock(testdata)

      @mock_mysql.should_receive(:query)
        .with("SELECT `code`,`name`,`category`,`country_code_alpha_2`,`parent_code`,`timezones` FROM `subdivisions` WHERE (`code` = 'AU-NSW')")
        .and_return(result_mock)

      @subdivision_dal.get_one({ "code" => 'AU-NSW'}).should eq(testdata[0])
    end

    it 'should return a single subdivision based on a query with a multiple fields' do
      testdata = [
        {:code=>"US-TX", :name => "Texas", :category => "state", :country_code_alpha_2 => "US"}
      ]

      result_mock = get_mysql_result_mock(testdata)

      @mock_mysql.should_receive(:query)
        .with("SELECT `code`,`name`,`category`,`country_code_alpha_2`,`parent_code`,`timezones` FROM `subdivisions` WHERE (`country_code_alpha_2` = 'US') AND (`category` = 'state')")
        .and_return(result_mock)

      @subdivision_dal.get_one({ "country_code_alpha_2" => 'US', 'category' => 'state'})
        .should eq(testdata[0])
    end
  end

end