require "spec_helper"
require "rack/test"

describe "Geo Service Subdivisions" do

  describe "/subdivisions" do

    it 'should regions the correct CORS header' do
      get '/subdivisions'
      last_response.headers['Access-Control-Allow-Origin'].should == "*"
    end

    it "should respond to GET with a valid query that has the correct fields" do
      get '/subdivisions?category=county'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Array
      data.each do |row|
        row.has_key?('code').should be true
        row.has_key?('name').should be true
        row.has_key?('category').should be true
        row.has_key?('country_code_alpha_2').should be true
        row.has_key?('parent_code').should be true
        row.has_key?('timezones').should be true

        row.keys.length.should be 6
      end
    end

    it "should support exclude and have the correct fields" do
      get '/subdivisions?category=county&exclude=timezones'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Array
      data.each do |row|
        row.has_key?('code').should be true
        row.has_key?('name').should be true
        row.has_key?('category').should be true
        row.has_key?('country_code_alpha_2').should be true
        row.has_key?('parent_code').should be true

        row.keys.length.should be 5
      end
    end

    it "should respond to GET with invalid query with 400" do
      get '/subdivisions?five_six_seven=123'
      last_response.should_not be_ok
      last_response.status.should be 400
    end

    it "should respond to GET with a specific code that exists" do
      get '/subdivisions/GB-DOW'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Hash
    end

    it "should 404 with a specific code that does not exist" do
      get '/subdivisions/NARGEOLTHEP'
      last_response.should_not be_ok
      last_response.status.should be 404
    end

    it "should respond to GET with a specific code with the correct fields" do
      get '/subdivisions/ENG'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('category').should be true
      data.has_key?('country_code_alpha_2').should be true
      data.has_key?('parent_code').should be true
      data.has_key?('timezones').should be true

      data.keys.length.should be 6
    end

    it "should respond to GET with a specific code with the correct fields" do
      get '/subdivisions/ENG?include=subdivisions'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('category').should be true
      data.has_key?('country_code_alpha_2').should be true
      data.has_key?('parent_code').should be true
      data.has_key?('timezones').should be true
      data.has_key?('subdivisions').should be true
      data['subdivisions'].should be_kind_of Array

      data.keys.length.should be 7
    end

    it "should respond to GET on countries with a specific country code and subdivision code with the correct fields" do
      get '/countries/AU/AU-NSW'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('category').should be true
      data.has_key?('country_code_alpha_2').should be true
      data.has_key?('parent_code').should be true
      data.has_key?('timezones').should be true

      data.keys.length.should be 6
    end

    it "should respond to GET on countries with a specific country code and subdivision code with the correct fields" do
      get '/countries/AU/AU-NSW?include=subdivisions'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('category').should be true
      data.has_key?('country_code_alpha_2').should be true
      data.has_key?('parent_code').should be true
      data.has_key?('timezones').should be true
      data.has_key?('subdivisions').should be true
      data['subdivisions'].should be_kind_of Array

      data.keys.length.should be 7
    end
  end

end