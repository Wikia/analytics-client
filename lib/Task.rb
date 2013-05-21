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
	end

	def process
		type = @config['type']
		log "\tCurrent Task: #{@name}"
		log "\tData source: #{type}"

		begin
			fetcher = Object.const_get(type).new @config['config']
			formatter = OutputFormatter.new @config['format']
		rescue
			puts "\t\t'#{type}' fetcher does not exist"
		end


			#formatter.save fetcher.fetch, @config['output']
	end

end