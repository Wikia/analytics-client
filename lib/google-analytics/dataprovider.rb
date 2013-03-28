require 'google/api_client'

module GoogleAnalytics
	class DataProvider
		def initialize
			@client = Google::APIClient.new
			ga = @client.discovered_api('analytics', 'v3')
			puts ga
		end

		def fetch
			if !@ga
				@ga = @client.discovered_api('analytics', 'v3')
			end

			authorize
			#TODO continue...
			puts 'DONE'
		end

		private
		def authorize
			#TODO implement
			puts 'REQUESTING ATHORIZATION'
		end
	end
end

#TEST
#c = GoogleAnalytics::DataProvider.new
#c.fetch
