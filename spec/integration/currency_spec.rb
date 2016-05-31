require "spec_helper"
require "rack/test"

describe "Geo Service Currencies" do

  describe "/currencies" do
    it "should respond to GET" do
      get '/currencies'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Array
    end

    it 'should have the correct CORS header' do
      get '/currencies'
      last_response.headers['Access-Control-Allow-Origin'].should == "*"
    end

    it "should return more than one currency" do
      get '/currencies'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
      data.each do |row|
        row.has_key?('code').should be true
        row.has_key?('name').should be true
        row.has_key?('symbol').should be true
        row.has_key?('decimal_places').should be true

        row.keys.length.should be 4
      end
    end

    it "should allow queries with fields that exist" do
      get '/currencies?decimal_places=2'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
    end

    it "should allow queries with fields that exist with includes" do
      get '/currencies?decimal_places=2&include=symbol'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
    end

    it "should allow queries with fields that exist with excludes" do
      get '/currencies?decimal_places=2&exclude=symbol'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
    end

    it "should 400 on queries where fields do not exist" do
      get '/currencies?one_two_three=EUR'
      last_response.should_not be_ok
      last_response.status.should be 400
    end

    it "should respond to GET with a specific code" do
      get '/currencies/EUR'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Hash
    end

    it "should 404 with a specific code that does not exist" do
      get '/currencies/NARGEOLTHEP'
      last_response.should_not be_ok
      last_response.status.should be 404
    end

    it "should respond to GET with a specific code with the correct fields" do
      get '/currencies/EUR'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('symbol').should be true
      data.has_key?('decimal_places').should be true

      data.keys.length.should be 4
    end

    it "should respond to GET with a specific code with the correct fields and relations" do
      get '/currencies/EUR?include=countries'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('symbol').should be true
      data.has_key?('decimal_places').should be true
      data.has_key?('countries').should be true
      data['countries'].should be_kind_of Array

      data.keys.length.should be 5
    end
  end

end