# frozen_string_literal: true

require "logger"

module BackupPublisher
  class << self
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end

require "backup_publisher/heroku_client"
