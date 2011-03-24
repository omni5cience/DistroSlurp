require "rubygems"
require "json"
require "net/http"
require "uri"

def getConfig(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return JSON.parse data
end

def getSession(email, password) #Get a Session Cookie
	uri = URI.parse("http://distro.fm/api/login")
	session = Net::HTTP.post_form(uri, { "email" => email, "password" => password })["set-cookie"]
end

def getTrackList(session)
	uri = URI.parse("http://distro.fm/api/library/tracks")
	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Get.new(uri.request_uri)	
	request["Cookie"] = session
	tracks = JSON.parse(http.request(request).body)["data"]
end

config = getConfig("DistroSlurp.json")
session = getSession(config["email"], config["password"])
trackListJSON = getTrackList(session)
trackListJSON.each do |track|
	puts "#{track['name']} : #{track['filename']}" 
end
