#!/usr/bin/env ruby -w

require '../Flurry/flurry'
require '../Flurry/config'

@flurry = Flurry.new @apiKey
@flurry.getAll
