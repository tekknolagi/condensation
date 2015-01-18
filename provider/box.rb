require 'net/http'
require 'json'
require 'launchy'

class Provider ; end

class BoxService < Provider
	AUTH_URL = 'http://condensation-auth.herokuapp.com/box'
	attr_accessor :access_token

	puts "one"

	def get_token
		# Make GET to auth server/build_url
		authorize_url_json = Net::HTTP.post_form(URI("#{AUTH_URL}/build_url"), {})
    parsed_json = JSON.parse(authorize_url_json.body)
    authorize_url = parsed_json['authorize_url']

		# Launchy(authorize_url)
		Launchy.open(authorize_url)
		puts "Please paste the code from the browser."
		code = gets.chomp

		# Send code to Box for access_token
					
	end

	puts "end"
end
