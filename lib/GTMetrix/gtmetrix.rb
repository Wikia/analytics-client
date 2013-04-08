require 'CSV'
require 'date'
require 'net/http'
require 'Curb'
require 'json'

class GTMetrix
	GT_METRICS_URL = 'https://gtmetrix.com'

	ANALYSIS_URL = GT_METRICS_URL + '/api/0.1/test'
	LOCATIONS_URL = GT_METRICS_URL + '/api/0.1/locations'

	def initialize(user, password)
		raise 'User not given' if user.empty?

		@user = user
		@password = password
	end

	private

	def test
		File.open('example.json', 'r') { |file|
			JSON.parse(file.read)
		}
	end

	def poll_result

	end

	def get_url

	end

	public

	def get_results

	end

	def fetch_url(url = '', url_to_analyze = nil)
		puts url

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
				puts fetch_url ANALYSIS_URL, url
			}
		end
	end
end
