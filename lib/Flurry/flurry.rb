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
		@data[endPoint] = data['day']['@value']
	end

	def getSummary data

		data = data['event']

		if data.respond_to? 'each'
			data.each do |event|
				@data[event['@eventName']] = event['@usersLastDay']
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

	def getAll date = -1

		[:ActiveUsers, :PageViews, :NewUsers, :AvgSessionLength, :AvgPageViewsPerSession, :Summary].each do |endPoint|
			puts "Fetching data for - " + endPoint.to_s
			get endPoint, date
			# Flurry api is throttled at 1 req/sec
			sleep 1
		end

		CSV.open "data.csv", "wb" do |csv|
			csv << ['//' + (Date.today + date).to_s]

			csv << ['Name', 'Value']

			@data.each do |key, value|
				csv << [key, value]
			end
		end
	end
end

#Flurry.new(@apiKey, @androidGG).getAll
Flurry.new(@apiKey).getApps