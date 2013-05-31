class Flurry
	FLURRY_DOMAIN = 'api.flurry.com'

	def initialize( config = {} )
		@key = config['key']
		@app_keys = config['app_keys'] ? config['app_keys'] : {}
		@data = {}
		@keys = {}
	end

	private

	def date_string( start_date = 0, end_date = 0 )
		start_date = end_date if start_date == 0
		start_date = Date.today + start_date if !start_date.is_a? Date
		end_date = Date.today + end_date if !end_date.is_a? Date

		"&startDate=#{start_date}&endDate=#{end_date}"
	end

	def access_string( app_key )
		"?apiAccessCode=#{@key}&apiKey=#{app_key}"
	end

	def format app_data
		ret = []

		ret << ['name', 'value'] + @keys

		app_data.each { |key, values|
			ret << [key, values].flatten
		}

		ret
	end

	def get_data( data, end_point, app_data )
		day = data['day']
		day = [day] unless day.is_a? Array

		app_data[end_point] = day.reduce(0){|sum, val| sum + val['@value'].to_i }
	end

	def get_summary( data, end_point, app_data )

		data = data['event']

		if data.respond_to? :each
			data.each { |event|
				name = event.delete '@eventName'

				@keys = event.keys.map!{|key| key[1..-1]} if @keys == {}

				vals = event.values

				app_data[name] = [nil] + vals.map{|x| x.to_i}
			}
		end
	end

	public

	def get_apps
		apps = JSON.parse( Curl.get( FLURRY_DOMAIN + "/appInfo/getAllApplications?apiAccessCode=#{@key}" ).body_str )['application']
		keys = []

		if apps.respond_to? :collect
			apps.map{|app|
				keys << [(app['@name'] + ' ' + app['@platform']).gsub(' ', '_'), app['@apiKey']]
			}
		end

		keys
	end

	def get( end_point = '', key = '', start_date = 0, end_date = 0, app_data = {} )

		if end_point.to_s == 'Summary'
			param = '/eventMetrics/'
			name = 'summary'
		else
			param = '/appMetrics/'
			name = 'data'
		end

		url = "#{param}#{end_point}#{access_string key}#{date_string start_date, end_date}"

		data = JSON.parse( Curl.get( FLURRY_DOMAIN + url ).body_str )

		self.method( 'get_' + name ).call( data, end_point, app_data )
	end

	def fetch( save_method, date = -1, end_date = date )

		if @app_keys.empty?
			@app_keys = get_apps
			sleep 1
		end

		@app_keys.each { |app|
			$log.info "\tApp - " + app[0] + ' - ' + app[1]
			app_data = {}

			[:ActiveUsers, :PageViews, :NewUsers, :MedianSessionLength, :AvgSessionLength, :AvgPageViewsPerSession, :Sessions, :RetainedUsers, :Summary].each { |end_point|
				$log.debug "\t\tFetching data for - " + end_point.to_s
				get end_point, app[1], date, end_date, app_data
				# Flurry api is throttled at 1 req/sec
				sleep 1
			}

			save_method[ format( app_data ), app[0] ]
		}
	end
end