require 'legato'
require 'oauth2'

#to get GA token follow these instructions: http://jonathanotto.com/blog/google_oauth2_api_quick_tutorial.html

class GoogleAnalytics

	def initialize( config = {} )
		if !config['client_id'] || !config['client_secret']
			$log.error "\t\tclient_id or client_secret not passed"
			$log.error "\t\tYou can get it here: https://code.google.com/apis/console/"
			raise 'client_id or client_secret not given'
		end

		if !config['token'] || !config['refresh_token']
			$log.error "\t\ttoken and refresh_token not passed"
			$log.error "\t\tFollow these instructions: http://jonathanotto.com/blog/google_oauth2_api_quick_tutorial.html"
			raise 'token or refresh_token not given'
		end

		client = OAuth2::Client.new(
			config['client_id'],
			config['client_secret'],
			{
				:site => 'https://accounts.google.com',
		        :authorize_url => '/o/oauth2/auth',
				:token_url => '/o/oauth2/token'
			}
		)

		access_token = OAuth2::AccessToken.new(
			client,
			config['token'],
			{
				refresh_token: config['refresh_token'],
			}
		).refresh!

		user = Legato::User.new( access_token )

		@profile = user.profiles.first
	end

	public

	def fetch
		results = []
		keys = []

		Dupa.filters.each_key{|as|
			p as
		}

		#@profile.dupa.filters.each {|result|
		#	result_hash = result.marshal_dump
		#	res = []
		#
		#	keys = result_hash.keys if keys.empty?
		#
		#	result_hash.each_value{|value|
		#		res << value
		#	}
		#
		#	results << res
		#}
		#
		#results.unshift keys
	end
end