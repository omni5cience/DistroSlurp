require "rubygems"
require "json"
require "net/http"
require "uri"
require "curb"

def getJSONFile(filename)
	data = ''
	file = File.open(filename, "r") 
	file.each_line do |line|
		data += line
	end
	return JSON.parse data
end

def writeJSONFile(filename, data)
	data = JSON.generate data
	file = File.open(filename, "w")
	file.write(data)	
	return data
end

def getSession(email, password)
	uri = URI.parse("http://distro.fm/api/login")
	session = Net::HTTP.post_form(uri, { "email" => email, "password" => password })["set-cookie"]
end

# def checkSession(session)
#     uri = URI.parse("http://omni:3000/api/library")
# end

def getTrackList(session)
	uri = URI.parse("http://distro.fm/api/library/tracks")
	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Get.new(uri.request_uri)	
	request["Cookie"] = session
	tracks = JSON.parse(http.request(request).body)["data"]
end

def downloadTracks(urlList)
	Curl::Multi.download(urlList){|c,code,method| 
		filename = c.url.split(/\?/).first.split(/\//).last
		puts filename
	}
end

config = getJSONFile("DistroSlurp.json")
session = getSession(config["email"], config["password"])
urlList = []
trackListJSON = getTrackList(session)
trackListJSON.each do |track|
	url = "http://distro-music.s3.amazonaws.com/#{track['networkWithFile']['name']}/#{track['filename']}.mp3"
	urlList.push url
end
downloadTracks(urlList)
