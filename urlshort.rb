require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'

set :port, 8080
set :id_length, 5
set :url_prefix, "http://localhost:8080/"

@@conn = Mongo::Connection.new
@@db   = @@conn['mydb']
@@coll = @@db['urls']


get '/' do
  erb :index
end

get '/:key' do |key|
	dest_url = find_url(key)
	if(dest_url==false) 
	  status 404
	  "Sorry the url(#{settings.url_prefix + key}) you requested does not redirect to anything. =("
  else
	  redirect dest_url
  end
end

put '/create' do 
  target = JSON.parse(request.body.string)
  id = save_url target[0]
  s_url = settings.url_prefix + id
  status 200
  res = JSON.pretty_generate('short_url'=>s_url)
  body(res)
end

post '/create' do
  key = save_url params[:target] 
  s_url = settings.url_prefix + key
  "Here is the shortened url: #{s_url}"
end


def find_url(id)
  found = @@coll.find_one(:key=>id) #find document with identified by key=id, the result is a normal Hash
  if found.nil?
    return false
  end
  return found['url']
end

def get_id()
  chars = "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM".split(//)
  s=""
  
  settings.id_length.times { s << chars[rand(chars.length)] }

  return s
end

def save_url(url_in)
  id = get_id
  doc = {:key=>id, :url=>url_in}
  @@coll.insert(doc)
  return id
end
