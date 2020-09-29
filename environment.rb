# frozen_string_literal: true

ENV["RACK_ENV"] ||= "development"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")
$stdout.sync = $stderr.sync = true
require "bundler"
Bundler.require :default, ENV.fetch("RACK_ENV")
Dotenv.load ".env", ".env.#{ENV['RACK_ENV']}"

require "backup_publisher"
