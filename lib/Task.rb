#output formatters
require_relative 'Output/CsvOutput'

#fetchers
require_relative 'Flurry/flurry'
#require_relative 'GTMetrix/gtmetrix'

class Task
	@@known_modules = %w(
		Flurry
		GTMetrix
		GoogleAnalytics
	)

	def initialize(name, config)
		@name = name
		@config = config
		@data = false
	end

	def process
		type = @config['type']
		$log.info "\tCurrent Task: #{@name}"
		$log.debug "\tData source: #{type}"

		begin
			@data = Object.const_get( type ).new( @config['config'] ).fetch
		rescue
			$log.error "\t\t'#{type}' fetcher encountered a problem or does not exist"
			return 0
		end

		if @data
			Object.const_get( @config['format'].capitalize + 'Output' ).new( @data, @config['output'] ).save
		else
			$log.error "\t\t No data fetched"
		end
	end
end