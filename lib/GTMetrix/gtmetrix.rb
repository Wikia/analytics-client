require 'CSV'
require 'date'
require 'net/http'
require 'Curb'
require 'json'

class GTMetrix
	GT_METRICS_URL = 'https://gtmetrix.com/api/0.1/'

	ANALYSIS_URL = GT_METRICS_URL + 'test'
	LOCATIONS_URL = GT_METRICS_URL + 'locations'

	COMPLETED = 'completed'

	def initialize( user, password )
		raise 'User not given' if user.empty?
		raise 'Password not given' if password.empty?

		@user = user
		@password = password
		@data = {}
	end

	def save
		today = (Date.today).to_s
		filename = "gtmetrix-#{today}.csv"

		CSV.open(filename, 'wb') { |csv|
			csv << ['//' + (Date.today).to_s]

			csv << [:page_url, @data.first[1].keys].flatten

			@data.each { |key, values|
				csv << [key, values.values].flatten
			}
		}

		puts "Data saved in #{filename} file"
	end

	def poll_result(url, url_to_analyze)

		result = false
		state = ''
		count = 30

		puts "Trying to fetch data for #{url}"

		while state != COMPLETED and count >= 0 do

			c = Curl::Easy.new(url)
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
			puts "Data fetched in #{31 - count} tries"
			@data[url_to_analyze] = result['results'].merge result['resources']
		else
			puts 'Something went wrong and after 30 tries there still is no data'
		end
	end

	def fetch_test_url( url = ANALYSIS_URL, url_to_analyze )
		raise 'Url not given' if url_to_analyze.empty?

		puts "Requesting test for #{url_to_analyze}"

		c = Curl::Easy.new(url)
		c.http_auth_types = :basic
		c.username = @user
		c.password = @password
		c.http_post(Curl::PostField.content('url', url_to_analyze))
		c.perform

		result_url = JSON.parse c.body_str

		result_url['poll_state_url']
	end

	public

	def fetch urls
		now = Time.now
		puts "Start process at #{now}"

		urls = [urls] unless urls.is_a? Array

		if urls.respond_to? :each
			urls.each { |url|
				poll_result(fetch_test_url(url), url)
			}
		end

		save

		puts "Process finised in #{(Time.now - now).round(2)}"
	end
end