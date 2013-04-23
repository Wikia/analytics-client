require 'CSV'
require 'date'
require 'net/http'
require 'Curb'
require 'json'

class GTMetrix
	GT_METRICS_URL = 'https://gtmetrix.com'

	ANALYSIS_URL = GT_METRICS_URL + '/api/0.1/test'
	LOCATIONS_URL = GT_METRICS_URL + '/api/0.1/locations'
	COMPLETED = 'completed'

	def initialize( user, password )
		raise 'User not given' if user.empty?
		raise 'Password not given' if password.empty?

		@user = user
		@password = password
	end

	private

	def test
		File.open( 'example.json', 'r' ) { |file|
			JSON.parse( file.read )
		}
	end

	def get_url

	end

	public

	def poll_result url

		result = false
		state = ''
		count = 5

		while state != COMPLETED and count >= 0 do
			puts "Trying to fetch data for #{url}"

			c = Curl::Easy.new(url)
			c.http_auth_types = :basic
			c.username = @user
			c.password = @password
			c.perform

			result = JSON.parse c.body_str
			state = result['state']

			sleep 1 unless state == COMPLETED
			count -= 1
		end

		puts 'done'
		puts result
	end


	def get_results

	end

	def fetch_url( url = ANALYSIS_URL, url_to_analyze )
		puts url

		raise 'Url not given' if url_to_analyze.empty?

		c = Curl::Easy.new(url)
		c.http_auth_types = :basic
		c.username = @user
		c.password = @password
		c.http_post(Curl::PostField.content('url', url_to_analyze)) unless url_to_analyze.nil?
		c.perform

		JSON.parse c.body_str
	end

	def fetch_data urls
		urls = [urls] unless urls.is_a? Array

		if urls.respond_to? :each
			urls.each { |url|
				puts fetch_url url
			}
		end
	end
end
