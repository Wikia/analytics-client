#!/usr/bin/env ruby -w

require '../Flurry/flurry'
require '../config'

@flurry = Flurry.new(WIKIA_CONFIG[:flurry][:api_key])

@flurry.get_all