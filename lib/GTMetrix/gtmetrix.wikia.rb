#!/usr/bin/env ruby -w

require_relative 'gtmetrix'
require_relative '../config'

gt_config = WIKIA_CONFIG[:gt_metrix]

gt_metrix = GTMetrix.new(gt_config[:user], gt_config[:password])

gt_metrix.fetch(gt_config[:tests])