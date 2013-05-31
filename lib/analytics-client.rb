#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'Curb'
require 'date'
require 'json'

require_relative 'Framework/ColorLogger'
require_relative 'Framework/Job'
require_relative 'Framework/Task'

$options = {}

$log.level = Logger::INFO

OptionParser.new do |opts|
	opts.banner = "Usage: analytics-client.rb [options]"

	opts.on( "-v", "Run verbosely" ) do
		$log.level = Logger::DEBUG
	end

	opts.on( "-c", "--config PATH", "Path to config" ) do |path|
		begin
			$options[:config] = YAML::load_file path
		rescue
			$log.fatal "Config file does not exist.\r\n"
			$log.info opts

			exit
		end
	end

	opts.on( "-j", "--jobs JOBS", Array, "Job names that you want to run" ) do |jobs|
		$options[:jobs] = jobs
	end
end.parse!

$log.info 'Working...'

#leave only jobs that were specified in cli
if $options[:jobs].respond_to? :each
	$options[:config].keep_if { |key|
		$options[:jobs].member? key
	}
end

if $options[:config].empty?
	$log.error "No jobs choosen"
else
	#lets run each job and save its results
	if $options[:config].respond_to? :each
		$options[:config].each { |job_name, job_config|
			Job.new( job_name, job_config ).process
		}
	end
end

$log.info 'Done'