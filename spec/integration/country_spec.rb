require "spec_helper"
require "rack/test"

describe "Geo Service Countries" do

  describe "/countries" do
    it "should respond to GET" do
      get '/countries'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Array
    end

    it 'should have the correct CORS header' do
      get '/countries'
      last_response.headers['Access-Control-Allow-Origin'].should == "*"
    end

    it "should return more than one country and have the correct fields" do
      get '/countries'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
      data.each do |row|
        row.has_key?('code_alpha_2').should be true
        row.has_key?('code_alpha_3').should be true
        row.has_key?('code_numeric').should be true
        row.has_key?('name').should be true
        row.has_key?('default_currency_code').should be true

        row.keys.length.should be 5
      end
    end

    it "should support exclude and have the correct fields" do
      get '/countries?exclude=code_alpha_3,code_numeric'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
      data.each do |row|
        row.has_key?('code_alpha_2').should be true
        row.has_key?('name').should be true
        row.has_key?('default_currency_code').should be true

        row.keys.length.should be 3
      end
    end

    it "should allow queries with fields that exist" do
      get '/countries?default_currency_code=EUR'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
    end

    it "should allow queries with fields that exist with includes" do
      get '/countries?default_currency_code=EUR&include=code_alpha_2'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
    end

    it "should allow queries with fields that exist with excludes" do
      get '/countries?default_currency_code=EUR&exclude=code_alpha_2'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
    end

    it "should 400 on queries where fields do not exist" do
      get '/countries?one_two_three=EUR'
      last_response.should_not be_ok
      last_response.status.should be 400
    end

    it "should respond to GET with a specific code" do
      get '/countries/AU'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Hash
    end

    it "should 404 with a specific code that does not exist" do
      get '/countries/NARGEOLTHEP'
      last_response.should_not be_ok
      last_response.status.should be 404
    end

    it "should respond to GET with a specific code with the correct fields" do
      get '/countries/AU'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code_alpha_2').should be true
      data.has_key?('code_alpha_3').should be true
      data.has_key?('code_numeric').should be true
      data.has_key?('name').should be true
      data.has_key?('default_currency_code').should be true

      data.keys.length.should be 5
    end

    it "should respond to GET with a specific code with the correct fields and relations" do
      get '/countries/AU?include=regions,subdivisions'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code_alpha_2').should be true
      data.has_key?('code_alpha_3').should be true
      data.has_key?('code_numeric').should be true
      data.has_key?('name').should be true
      data.has_key?('default_currency_code').should be true
      data.has_key?('regions').should be true
      data['regions'].should be_kind_of Array

      data.has_key?('subdivisions').should be true
      data['subdivisions'].should be_kind_of Array

      data.keys.length.should be 7
    end
  end

end