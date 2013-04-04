#!/usr/bin/env ruby

require 'CSV'
require 'date'
require 'net/http'
require 'json'
require '../Flurry/config'

class Flurry
	FLURRY_DOMAIN = 'api.flurry.com'
	FILE_NAME = 'data.csv'

	def initialize key = '', appKey = ''
		@key = key
		@appKey = appKey
		@data = {}
	end

	def getApps
		apps = JSON.parse(Net::HTTP.get(FLURRY_DOMAIN, "/appInfo/getAllApplications?apiAccessCode=#{@key}"))['application']

		if apps.respond_to? 'collect'
			apps.collect!{|app| app['@name'] + ' ' + app['@platform'] + ' ' + app['@apiKey']}
		end

		puts apps
	end

	def dateString (startDate = 0, endDate)

		if startDate == 0
			startDate = endDate
		end

		if !startDate.kind_of? Date
			startDate = Date.today + startDate
		end

		if !endDate.kind_of? Date
			endDate = Date.today + endDate
		end

		"&startDate=#{startDate}&endDate=#{endDate}"
	end

	def accessString
		"?apiAccessCode=#{@key}&apiKey=#{@appKey}"
	end

	def getData data, endPoint
		day = data['day']
		day = [day] if !day.is_a? Array

		@data[endPoint] = day.reduce(0){|sum, val| sum + val['@value'].to_i }
	end

	def getSummary data, endPoint

		data = data['event']

		if data.respond_to? 'each'
			data.each do |event|
				name = event.delete '@eventName'

				@keys = event.keys.map!{|key| key[1..-1]} if @keys == nil

				vals = event.values

				@data[name] = [nil] + vals.map{|x| x.to_i}
			end
		end
	end

	def get endPoint = '', startDate = 0, endDate

		if endPoint.to_s == 'Summary'
			param = '/eventMetrics/'
			get = 'getSummary'
		else
			param = '/appMetrics/'
			get = 'getData'
		end

		url = "#{param}#{endPoint}#{accessString}#{dateString startDate, endDate}"

		data = JSON.parse Net::HTTP.get FLURRY_DOMAIN, url

		self.send get, data, endPoint
	end

	def getAll date = -1, endDate = date

		[:ActiveUsers, :PageViews, :NewUsers, :AvgSessionLength, :AvgPageViewsPerSession, :Summary].each do |endPoint|
			puts 'Fetching data for - ' + endPoint.to_s
			get endPoint, date, endDate
			# Flurry api is throttled at 1 req/sec
			sleep 1
		end

		CSV.open 'data.csv', 'wb' do |csv|
			csv << ['//' + (Date.today + date).to_s]

			csv << ['Name', 'Value'] + @keys

			@data.each do |key, value|
				csv << [key, value].flatten
			end
		end
	end
end

Flurry.new(@apiKey, @androidGG).getAll
#Flurry.new(@apiKey).getApps
