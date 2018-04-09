# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.minimum_coverage 100
SimpleCov.start
require 'minitest/autorun'
require 'rack/test'

require 'roda/plugins/logger'


ENV['RACK_ENV'] = 'test'


def create_app(&block)
  c = Class.new(Roda)
  c.class_eval(&block)
  c
end
