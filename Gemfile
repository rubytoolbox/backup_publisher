# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(File.join(__dir__, ".ruby-version")).strip

gem "dotenv"
gem "http"

group :development, :test do
  gem "rubocop", require: false
  gem "rubocop-rspec", require: false

  gem "guard-bundler", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false

  gem "overcommit", require: false
end

group :test do
  gem "rspec"
  gem "simplecov", require: false
end
