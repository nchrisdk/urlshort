require 'rubygems'
require 'sinatra'
require 'test/unit'
require 'rack/test'
require 'json'
require_relative "urlshort.rb"



class ApplicationTest < Test::Unit::TestCase
	include Rack::Test::Methods
	
	
  def app
    Sinatra::Application
  end

  def test_create_short_url
    doc = JSON.pretty_generate(['url'=>'http://www.realllylongurl.com/right/on/dude'])
    put '/create', doc
    assert_equal 200, last_response.status

    res = JSON.parse(last_response.body)
    assert res['short_url'].start_with?('http://localhost:8080/')
  end
  
  def test_root
    get '/'
    assert last_response.ok?
  end
  
  def test_not_found
    get '/blah' 
    assert_equal 404, last_response.status
  end


end