# frozen_string_literal: true

require "logger"

module BackupPublisher
  class << self
    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def process!
      # Sync backups from Heroku to AWS
      publisher = BackupPublisher::Publisher.new
      logger.info "Syncing backups to storage"
      publisher.publish

      # Create index website based on files on AWS
      BackupPublisher::Indexer.new(files: publisher.storage.files, limit: 7).zip do |zip_path|
        # Deploy said website to netlify
        logger.info "Deploying index site"
        BackupPublisher::Deployer.new.deploy zip_path
      end
      true
    end
  end
end

require "backup_publisher/deployer"
require "backup_publisher/heroku_client"
require "backup_publisher/indexer"
require "backup_publisher/publisher"
require "backup_publisher/storage"
