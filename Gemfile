source "https://rubygems.org"

ruby File.read(File.join(__dir__, ".ruby-version")).strip

gem "http"
gem "dotenv"

group :development, :test do
  gem "guard-bundler"
  gem "guard-rspec"
  gem "guard-rubocop"

  gem "overcommit"
end

group :test do
  gem "rspec"
end
