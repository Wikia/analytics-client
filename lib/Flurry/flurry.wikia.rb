#!/usr/bin/env ruby -w

require_relative 'flurry'
require_relative '../config'

Flurry.new(WIKIA_CONFIG[:flurry][:api_key]).get_all