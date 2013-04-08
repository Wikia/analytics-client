require 'CSV'
require 'date'
require 'net/http'
require 'json'

class Flurry
	FLURRY_DOMAIN = 'api.flurry.com'

	def initialize(key = '', app_keys = '', file_name = 'data')
		@key = key
		@app_keys = app_keys != '' ? {file_name => app_keys} : {}
		@data = {}
	end

	private

	def save_to_csv(name = 'data', data = {}, keys = [], date)
		CSV.open(name + '.csv', 'wb') { |csv|
			csv << ['//' + (Date.today + date).to_s]

			csv << ['Name', 'Value'] + keys

			data.each { |key, value|
				csv << [key, value].flatten
			}
		}
	end


	def date_string(start_date = 0, end_date)

		start_date = end_date if start_date == 0
		start_date = Date.today + start_date if !start_date.is_a? Date
		end_date = Date.today + end_date if !end_date.is_a? Date

		"&startDate=#{start_date}&endDate=#{end_date}"
	end

	def access_string(app_key)
		"?apiAccessCode=#{@key}&apiKey=#{app_key}"
	end

	def get_data(data, end_point)
		day = data['day']
		day = [day] unless day.is_a? Array

		@data[end_point] = day.reduce(0){|sum, val| sum + val['@value'].to_i }
	end

	def get_summary(data, end_point)

		data = data['event']

		if data.respond_to? :each
			data.each { |event|
				name = event.delete '@eventName'

				@keys = event.keys.map!{|key| key[1..-1]} if @keys == nil

				vals = event.values

				@data[name] = [nil] + vals.map{|x| x.to_i}
			}
		end
	end

	public

	def get_apps
		apps = JSON.parse(Net::HTTP.get(FLURRY_DOMAIN, "/appInfo/getAllApplications?apiAccessCode=#{@key}"))['application']
		keys = []

		if apps.respond_to? :collect
			apps.map{|app|
				keys << [(app['@name'] + ' ' + app['@platform']).gsub(' ', '_'), app['@apiKey']]
			}
		end

		keys
	end

	def get(end_point = '', key = '', start_date = 0, end_date)

		if end_point.to_s == 'Summary'
			param = '/eventMetrics/'
			name = 'summary'
		else
			param = '/appMetrics/'
			name = 'data'
		end

		url = "#{param}#{end_point}#{access_string key}#{date_string start_date, end_date}"

		data = JSON.parse(Net::HTTP.get(FLURRY_DOMAIN, url))

		self.method('get_' + name).call(data, end_point)
	end

	def get_all(date = -1, end_date = date)

		if @app_keys.empty?
			@app_keys = get_apps
			sleep 1
		end

		@app_keys.each { |app|
			puts 'App - ' + app[0] + ' - ' + app[1]

			[:ActiveUsers, :PageViews, :NewUsers, :MedianSessionLength, :AvgSessionLength, :AvgPageViewsPerSession, :Sessions, :RetainedUsers, :Summary].each { |end_point|
				puts 'Fetching data for - ' + end_point.to_s
				get end_point, app[1], date, end_date
				# Flurry api is throttled at 1 req/sec
				sleep 1
			}

			save_to_csv(app[0], @data, @keys, date)
		}
	end
end