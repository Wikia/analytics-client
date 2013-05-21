#!/usr/bin/env ruby -w
require 'optparse'
require 'yaml'

require_relative 'Flurry/flurry'
#require_relative 'GTMetrix/gtmetrix'

puts 'Fetching all data'

#grab config
options = {
	known_modules: %w(
		Flurry
		GTMetrix
		GoogleAnalytics
	)
}

OptionParser.new do |opts|
	opts.banner = "Usage: analytics-client.rb [options]"

	opts.on("-v", "Run verbosely") do |v|
		options[:verbose] = v
	end

	opts.on("-c", "--config PATH", "Path to config") do |path|
		settings = YAML::load_file path

		if settings
			options[:config] = settings
		else
			raise 'Config file does not exist.'
		end
	end

	opts.on("-j", "--jobs JOBS", Array, "job name") do |jobs|
		options[:jobs] = jobs
	end
end.parse!


class Helper
	def initialize options
		@verbose = options[:verbose]
	end

	def log msg
		puts msg if @verbose
	end
end

helper = Helper.new options

#leave only jobs that were specified in cli
if options[:jobs].respond_to? :each
	options[:config].keep_if { |key|
		options[:jobs].member? key
	}
end

#lets run each job and save its results
if options[:config].respond_to? :each
	options[:config].each { |job_name, job_config|
		helper.log "Working on #{job_name}"

		if job_config.respond_to? :each
			job_config.each { |name, config|
				type = config['type']
				helper.log "\tCurrent Task: #{name}"
				helper.log "\tData source: #{type}"

				if options[:known_modules].member? type
					fetcher = Object.const_get(type).new config['config']

					#fetcher.fetch
				end
			}
		end
	}
end



puts 'Done'