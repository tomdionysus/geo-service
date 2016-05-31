require "spec_helper"
require "rack/test"

describe "Geo Service Regions" do

  describe "/regions" do

    describe 'options' do
      it 'should regions the correct CORS header' do
        options '/regions'
        last_response.status.should eq 204
        last_response.headers['Access-Control-Allow-Origin'].should == "*"
      end
    end

    describe 'get' do
      it "should respond to GET" do
        get '/regions'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.should be_kind_of Array
      end

      it 'should regions the correct CORS header' do
        get '/regions'
        last_response.headers['Access-Control-Allow-Origin'].should == "*"
      end

      it "should return more than one region and have correct fields" do
        get '/regions'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.length.should > 1
        data.each do |row|
          row.has_key?('code').should be true
          row.has_key?('name').should be true
          row.has_key?('parent_code').should be true

          row.keys.length.should be 3
        end
      end

      it "should support exclude and have correct fields" do
        get '/regions?exclude=parent_code'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.length.should > 1
        data.each do |row|
          row.has_key?('code').should be true
          row.has_key?('name').should be true

          row.keys.length.should be 2
        end
      end

      it "should allow queries with fields that exist" do
        get '/regions?parent_code=002'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.length.should > 1
      end

      it "should allow queries with fields that exist with includes" do
        get '/regions?parent_code=002&include=name'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.length.should > 1
      end

      it "should allow queries with fields that exist with excludes" do
        get '/regions?parent_code=002&exclude=parent_code'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.length.should > 1
      end

      it "should 400 on queries where fields do not exist" do
        get '/regions?one_two_five=002'
        last_response.should_not be_ok
        last_response.status.should be 400
      end

      it "should respond to GET with a specific code that exists" do
        get '/regions/150'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.should be_kind_of Hash
      end

      it "should 404 with a specific code that does not exist" do
        get '/regions/NARGEOLTHEP'
        last_response.should_not be_ok
        last_response.status.should be 404
      end

      it "should respond to GET with a specific code with the correct fields" do
        get '/regions/150'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.has_key?('code').should be true
        data.has_key?('name').should be true
        data.has_key?('parent_code').should be true

        data.keys.length.should be 3
      end

      it "should respond to GET with a specific code with the correct fields and relations" do
        get '/regions/150?include=countries,subregions'
        last_response.status.should eq 200
        data = JSON.parse(last_response.body)
        data.has_key?('code').should be true
        data.has_key?('name').should be true
        data.has_key?('parent_code').should be true

        data.has_key?('countries').should be true
        data['countries'].should be_kind_of Array
        
        data.has_key?('subregions').should be true
        data['subregions'].should be_kind_of Array

        data.keys.length.should be 5
      end
    end
    
    # describe 'put' do
    #   it 'should 404 when the region does not exist' do
    #     put '/regions/aosicbaiysbecviuasncv', { 'data' => 1 }.to_json
    #     last_response.should_not be_ok
    #     last_response.status.should be 404
    #   end

    #   it 'should 400 when the fields are invalid' do
    #     put '/regions/002', { 'data' => 1 }
    #     last_response.should_not be_ok
    #     last_response.status.should be 400
    #   end

    #   it 'should return ok when the region does exist and fields are valid' do
    #     put '/regions/002', { 'code' => "002",'name' => 'African Continent' }.to_json
    #     last_response.status.should eq 200
    #   end
    # end

    # describe 'post' do
    #   it 'should return ok on successful create' do
    #     code = (700+Random.rand(200)).to_s
    #     post '/regions', { 'code' => code, 'name'=>'Test region', 'parent_code'=>nil }.to_json
    #     last_response.status.should eq 200
    #     delete "/regions/#{code}"
    #   end

    #   it 'should 409 when the region exists' do
    #     post '/regions', { 'code' => '002', 'name'=>'Test region', 'parent_code'=>nil }.to_json
    #     last_response.should_not be_ok
    #     last_response.status.should be 409
    #   end

    #   it 'should 400 when the fields are invalid' do
    #     post '/regions', { 'data' => 1 }.to_json
    #     last_response.should_not be_ok
    #     last_response.status.should be 400
    #   end
    # end

    # describe 'delete' do
    #   it 'should return ok on successful delete' do
    #     code = (700+Random.rand(200)).to_s
    #     post '/regions', { 'code' => code, 'name'=>'Test region', 'parent_code'=>nil }.to_json
    #     delete "/regions/#{code}"
    #     last_response.status.should eq 204
    #   end

    #   it 'should return 404 when not found' do
    #     delete "/regions/XXX"
    #     last_response.should_not be_ok
    #     last_response.status.should be 404
    #   end
    # end

  end
end