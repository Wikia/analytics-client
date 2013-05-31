require 'Curb'
require 'json'
require 'CSV'
require 'date'
require 'net/http'

class GTMetrix
	GT_METRICS_URL = 'https://gtmetrix.com/api/0.1/'

	ANALYSIS_URL = GT_METRICS_URL + 'test'
	LOCATIONS_URL = GT_METRICS_URL + 'locations'

	COMPLETED = 'completed'

	def initialize( config = {} )
		raise 'User not given' unless config['user']
		raise 'Password not given' unless config['password']
		raise 'No Urls given' unless config['urls']

		@user = config['user']
		@password = config['password']
		@urls = config['urls']
		@urls = [@urls] unless @urls.is_a? Array
		@data = {}
	end

	def format
		ret = []

		ret << [:page_url, @data.first[1].keys].flatten

		@data.each { |key, values|
			ret << [key, values.values].flatten
		}

		ret
	end

	def poll_result( url, url_to_analyze )

		result = false
		state = ''
		count = 30

		$log.debug "\t\t\t\tTrying to fetch data for #{url}"

		while state != COMPLETED and count >= 0 do

			c = Curl::Easy.new( url )
			c.http_auth_types = :basic
			c.username = @user
			c.password = @password
			c.perform

			result = JSON.parse c.body_str
			state = result['state']

			sleep 2 unless state == COMPLETED
			count -= 1
		end

		if state == COMPLETED
			$log.debug "\t\t\t\tData fetched in #{30 - count} tries"
			@data[url_to_analyze] = result['results'].merge result['resources']
		else
			$log.error 'Something went wrong and after 30 tries there still is no data'
		end
	end

	def fetch_test_url( url_to_analyze )
		$log.info "\t\t\tRequesting test for #{url_to_analyze}"

		c = Curl::Easy.new( ANALYSIS_URL )
		c.http_auth_types = :basic
		c.username = @user
		c.password = @password
		c.http_post( Curl::PostField.content( 'url', url_to_analyze ) )
		c.perform

		result_url = JSON.parse c.body_str

		if result_url['error']
			raise result_url['error']
		end

		$log.debug "\t\t\tTest url: #{result_url['poll_state_url']}"
		result_url['poll_state_url']
	end

	public

	def fetch
		now = Time.now
		$log.debug "\t\tStart process at #{now}"

		@urls.each { |url|
			begin
				test_url = fetch_test_url( url )
			rescue => detail
				$log.error "\t\t\t#{detail.message}"
				next
			end

			poll_result( test_url, url )
		}

		$log.debug "\t\tProcess finished in #{(Time.now - now).round(2)}"

		format
	end
end