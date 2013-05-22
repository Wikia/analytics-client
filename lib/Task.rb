#output formatters
require_relative 'Output/CsvOutput'

#fetchers
require_relative 'Flurry/Flurry'
require_relative 'GTMetrix/GTMetrix'

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

		@format = @config['format'] ? @config['format'].capitalize : 'Csv'
		@output = @config['output'] ? @config['output'] : @name
	end

	def process
		type = @config['type']
		$log.info "\tCurrent Task: #{@name}"
		$log.debug "\tData source: #{type}"

		begin
			@data = Object.const_get( type ).new( @config['config'] ).fetch
		rescue => detail
			$log.error "\t\t'#{type}' fetcher encountered a problem or does not exist"
			$log.error "\t\t\t#{detail}"
			$log.debug detail.backtrace.join("\r\n")
			return 0
		end

		if @data
			Object.const_get( @format + 'Output' ).new( @data, @output ).save
		else
			$log.error "\t\t No data fetched"
		end
	end
end