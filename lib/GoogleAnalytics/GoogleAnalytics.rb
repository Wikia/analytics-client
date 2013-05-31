class GoogleAnalytics
	#to get GA token follow these instructions: http://jonathanotto.com/blog/google_oauth2_api_quick_tutorial.html

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

		raise "Config file not passed" unless config['conf']
		require_relative '../' + config['conf']

		raise "Model class not passed" unless config['model']
		@model = config['model']

		@filters ||= config['filters']

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
				:refresh_token => config['refresh_token']
			}
		).refresh!

		@profile = Legato::User.new( access_token ).profiles.first
	end

	public

	def fetch save_method
		results = []
		keys = []

		model_obj = Object.const_get( @model )
		filters = model_obj.filters

		model = @profile.send(model_obj.to_s.underscore)

		#leave only jobs that were specified in cli
		if @filters.respond_to? :each
			filters.keep_if { |key|
				@filters.member? key.to_s
			}
		end

		filters.each_key{ |filter|
			model.send(filter)
		}

		model.each {|result|
				result_hash = result.marshal_dump
				res = []

				keys = result_hash.keys if keys.empty?

				result_hash.each_value{|value|
					res << value
				}

				results << res
			}

		save_method[ results.unshift keys ]
	end
end