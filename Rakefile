# frozen_string_literal: true

task :environment do
  require File.join(File.dirname(__FILE__), "environment")
end

desc "Development console"
task console: :environment do
  # This is actually legitimate :)
  # rubocop:disable Lint/Debugger
  binding.pry
  # rubocop:enable Lint/Debugger
end
