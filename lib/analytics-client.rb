#!/usr/bin/env ruby -w
require 'optparse'
require 'yaml'

puts 'Fetching all data'

#grab config
options = {}

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

if options[:jobs].respond_to? :each
	options[:config].keep_if { |key|
		options[:jobs].member? key
	}
end

p options[:config]


#require_relative 'Flurry/flurry.wikia'
#require_relative 'GTMetrix/gtmetrix.wikia'

puts 'Done'