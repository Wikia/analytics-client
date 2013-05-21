#!/usr/bin/env ruby -w

require 'optparse'
require 'yaml'

require_relative 'Helper'
require_relative 'Job'
require_relative 'OutputFormatter'

puts 'Fetching all data'

$options = {}

OptionParser.new do |opts|
	opts.banner = "Usage: analytics-client.rb [options]"

	opts.on("-v", "Run verbosely") do |v|
		$options[:verbose] = v
	end

	opts.on("-c", "--config PATH", "Path to config") do |path|
		settings = YAML::load_file path

		if settings
			$options[:config] = settings
		else
			raise 'Config file does not exist.'
		end
	end

	opts.on("-j", "--jobs JOBS", Array, "Job names that you want to run") do |jobs|
		$options[:jobs] = jobs
	end
end.parse!

#leave only jobs that were specified in cli
if $options[:jobs].respond_to? :each
	$options[:config].keep_if { |key|
		$options[:jobs].member? key
	}
end

#lets run each job and save its results
if $options[:config].respond_to? :each
	$options[:config].each { |job_name, job_config|
		Job.new(job_name, job_config).process
	}
end

puts 'Done'