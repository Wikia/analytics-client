#!/usr/bin/env ruby -w

require '../Flurry/flurry'
require '../Flurry/config'

@flurry = Flurry.new(WIKIA_CONFIG[:api_key])

@flurry.get_all