require "spec_helper"
require "rack/test"

describe "Geo Service Languages" do

  describe "/languages" do
    it "should respond to GET" do
      get '/languages'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Array
    end

    it 'should have the correct CORS header' do
      get '/languages'
      last_response.headers['Access-Control-Allow-Origin'].should == "*"
    end

    it "should return more than one language and have the correct fields" do
      get '/languages'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
      data.each do |row|
        row.has_key?('code').should be true
        row.has_key?('name').should be true
        row.has_key?('native_name').should be true
        row.has_key?('code_t').should be true
        row.has_key?('code_b').should be true

        row.keys.length.should be 5
      end
    end

    it "should support exclude and have the correct fields" do
      get '/languages?exclude=native_name,code_t'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should > 1
      data.each do |row|
        row.has_key?('code').should be true
        row.has_key?('name').should be true
        row.has_key?('code_b').should be true

        row.keys.length.should be 3
      end
    end

    it "should allow queries with fields that exist" do
      get '/languages?code_b=eng'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.length.should eq 1
    end

    it "should 400 on queries where fields do not exist" do
      get '/languages?one_two_three=EUR'
      last_response.should_not be_ok
      last_response.status.should be 400
    end

    it "should respond to GET with a specific code" do
      get '/languages/en'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.should be_kind_of Hash
    end

    it "should 404 with a specific code that does not exist" do
      get '/languages/NARGEOLTHEP'
      last_response.should_not be_ok
      last_response.status.should be 404
    end

    it "should respond to GET with a specific code with the correct fields" do
      get '/languages/en'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('native_name').should be true
      data.has_key?('code_t').should be true
      data.has_key?('code_b').should be true

      data.keys.length.should be 5
    end

    it "should respond to GET with a specific code with the correct fields and relations" do
      get '/languages/en?include=countries'
      last_response.should be_ok
      data = JSON.parse(last_response.body)
      data.has_key?('code').should be true
      data.has_key?('name').should be true
      data.has_key?('native_name').should be true
      data.has_key?('code_t').should be true
      data.has_key?('code_b').should be true
      data.has_key?('countries').should be true
      data['countries'].should be_kind_of Array

      data.keys.length.should be 6
    end
  end

end