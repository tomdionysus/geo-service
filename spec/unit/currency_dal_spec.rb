require 'helpers'

RSpec.configure do |c|
  c.include Helpers
end

require "currency_dal"

describe DAL::CurrencyDal do

  before(:each) do
    @mock_mysql = get_mysql_mock
    @mock_memcache = double('Memcache')
    @mock_log = double('Log')

    @currency_dal = DAL::CurrencyDal.new(@mock_mysql, @mock_memcache, @mock_log)
  end

  describe '#initialize' do
    it 'should have the correct fields' do
      @currency_dal.table_name.should eq 'currencies'
      @currency_dal.fields.should eq({
        "code"            => { :type=>:string, :length=>3, :required=>true },
        "name"            => { :type=>:string, :length=>128, :required=>true },
        "symbol"          => { :type=>:string, :length=>10, :required=>true },
        "decimal_places"  => { :type=>:integer, :required=>true },
      })
      @currency_dal.relations.should eq({
        "countries" => { 
          :type           => :has_many, 
          :table          => 'countries',
          :table_key      => 'default_currency_code', 
          :this_key       => 'code',
          :table_fields   => 'code_alpha_2,name'
        },
      })
      @currency_dal.primary_key.should eq 'code'
    end
  end

  describe '#get_one' do
    before(:each) do
      memcache_null(@mock_memcache)
    end

    it 'should return a single currency based on a query with a single field' do
      testdata = [
        {:code=>"GBP", :name => "Pound Sterling"},
      ]

      result_mock = get_mysql_result_mock(testdata)

      @mock_mysql.should_receive(:query)
        .with("SELECT `code`,`name`,`symbol`,`decimal_places` FROM `currencies` WHERE (`code` = 'GBP')")
        .and_return(result_mock)

      @currency_dal.get_one({ "code" => 'GBP'}).should eq(testdata[0])
    end

    it 'should return a single currency based on a query with a multiple fields' do
      testdata = [
         {:code=>"USD", :name => "United States Dollar"},
      ]

      result_mock = get_mysql_result_mock(testdata)

      @mock_mysql.should_receive(:query)
        .with("SELECT `code`,`name`,`symbol`,`decimal_places` FROM `currencies` WHERE (`code` = 'GBP') AND (`decimal_places` IS NULL)")
        .and_return(result_mock)

      @currency_dal.get_one({ "code" => 'GBP', 'decimal_places' => nil})
        .should eq(testdata[0])
    end
  end

end