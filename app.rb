require "rubygems"
require "sinatra"
require "haml"
require "ez_http"

before do
  @host = request.host
  @host << ":4567" if request.host == "localhost"
end

get "/" do
  redirect "/edition/"
end

get "/edition/" do
  key = ENV['KEY']
  begin
    number = EZHttp.Get("http://api.tumblr.com/v2/blog/trextrying.tumblr.com/info?api_key=#{key}")
    number = JSON.parse(number.body)['response']['blog']['posts']
    n = number.to_i - 10 - params[:n].to_i
    results = EZHttp.Get("http://api.tumblr.com/v2/blog/trextrying.tumblr.com/posts/photo?limit=1&offset=#{n}&api_key=#{key}")
    photo = JSON.parse(results.body)['response']['posts'][0]
    puts photo
    @img = photo['photos'][0]['alt_sizes'][1]['url']
    @caption = photo['caption']
    etag Digest::MD5.hexdigest("#{n}")
  rescue
    halt 400
  end
  @img.gsub!(/\\\"/, "\"")
  haml :index
end

error 400 do
  '<center><h1>Error 400!</h1> <br />Bad request, no credenitals provided.</center>'
end