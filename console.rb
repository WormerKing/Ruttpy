#!/usr/bin/env ruby
require "httparty"
require "json"
require "yaml"

arr = ARGV

module Error
	class EmptyUrlError < StandardError
		def message
			"Url not empty"
		end
	end
	class WrongUrlError < StandardError
		def message
			"Wrong url"
		end
	end
	class NoDataError < StandardError
		def message
			"Post method required data"
		end
	end
end

class App
	attr_accessor :url,:method,:data
	def initialize(url="",method="get",data="")
 		yield(self) if block_given?
 		@method ||= method
 		@url ||= url
 		@data ||= data

 		control
 		case @method
 		when "get"
 			get
 		when "post"
 			post
 		end
	end
	def control
		if @url.nil? || @url == ""
			raise(Error::EmptyUrlError)
		elsif @url.match(/(http.?)(:\/\/)([a-z0-9]+)/i).nil?
			raise(Error::WrongUrlError)
		end
	end
	def get
		getHttp = HTTParty.get(@url)
		if getHttp.body.match(/(<.+?>)(.+)(<\/.+>)/)
			puts getHttp
		elsif getHttp.is_a?(HTTParty::Response)
			getHttp.each {|i| puts i.to_yaml}
		end
	end
	def post
		raise(Error::NoDataError) if @data.empty?
		#hash_data = @data.gsub("{","").gsub("}","").split(",")

		postHttp = HTTParty.post(@url,:body => YAML.load(@data))
		puts postHttp.body if postHttp.is_a?(String)
		postHttp.each {|i| puts i.to_yaml} unless postHttp.is_a?(String)
	end
end

new_hash = {}

arr.each do |i|
	if i.match(/(\-\-url=)(.+)/)
		a = i.match(/(\-\-url=)(.+)/)
		new_hash.store(a[1].gsub("-","").gsub("=",""),a[2].gsub("'",""))
	elsif i.match(/(\-\-method=)(.+)/)
		a = i.match(/(\-\-method=)(.+)/)
		new_hash.store(a[1].gsub("-","").gsub("=",""),a[2])
	elsif i.match(/(\-\-data=)(.+)/)
		a = i.match(/(\-\-data=)(.+)/)
		new_hash.store(a[1].gsub("-","").gsub("=",""),a[2])
	end
end

new_hash

worm = App.new do |i|
	i.url = new_hash["url"]
	i.method = new_hash["method"]
	i.data = new_hash["data"]
end