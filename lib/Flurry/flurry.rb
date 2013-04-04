#!/usr/bin/env ruby

require 'CSV'
require 'date'
require 'net/http'
require 'json'
require '../Flurry/config'

class Flurry
	FLURRY_DOMAIN = 'api.flurry.com'

	def initialize key = '', appKeys = '', filename = 'data'
		@key = key
		puts appKeys
		if appKeys != ''
			@appKeys = {filename => appKeys}
		else
			@appKeys = {}
		end

		@data = {}
	end

	def getApps
		apps = JSON.parse(Net::HTTP.get(FLURRY_DOMAIN, "/appInfo/getAllApplications?apiAccessCode=#{@key}"))['application']
		keys = []

		if apps.respond_to? 'collect'
			apps.map{|app|
				keys << [(app['@name'] + ' ' + app['@platform']).gsub(' ', '_'), app['@apiKey']]
			}

		end

		keys
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

	def accessString appKey
		"?apiAccessCode=#{@key}&apiKey=#{appKey}"
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

	def get endPoint = '', key = '', startDate = 0, endDate

		if endPoint.to_s == 'Summary'
			param = '/eventMetrics/'
			get = 'getSummary'
		else
			param = '/appMetrics/'
			get = 'getData'
		end

		url = "#{param}#{endPoint}#{accessString key}#{dateString startDate, endDate}"

		data = JSON.parse Net::HTTP.get FLURRY_DOMAIN, url

		self.send get, data, endPoint
	end

	def getAll date = -1, endDate = date

		if @appKeys.empty?
			@appKeys = getApps
			sleep 1
		end

		@appKeys.each{|app|
			puts 'App - ' + app[0] + ' - ' + app[1]

			[:ActiveUsers, :PageViews, :NewUsers, :AvgSessionLength, :AvgPageViewsPerSession, :Summary].each do |endPoint|
				puts 'Fetching data for - ' + endPoint.to_s
				get endPoint, app[1], date, endDate
				# Flurry api is throttled at 1 req/sec
				sleep 1
			end

			CSV.open app[0] + '.csv', 'wb' do |csv|
				csv << ['//' + (Date.today + date).to_s]

				csv << ['Name', 'Value'] + @keys

				@data.each do |key, value|
					csv << [key, value].flatten
				end
			end
		}
	end
end

Flurry.new(@apiKey).getAll
#Flurry.new(@apiKey).getAp