# frozen_string_literal: true

module BackupPublisher
  class Publisher
    attr_accessor :app, :storage, :heroku
    private :app=, :storage=, :heroku=

    def initialize(
        app: ENV.fetch("PG_HEROKU_APP"),
        storage: BackupPublisher::Storage.new,
        heroku: BackupPublisher::HerokuClient.new
      )
      self.app = app
      self.heroku = heroku
      self.storage = storage
    end

    def publish
      heroku.backups(app).each do |backup|
        if exists? backup
          logger.info "#{backup.filename} already exists on storage, skipping"
        else
          publish_backup backup
        end
      end
    end

    private

    def logger
      BackupPublisher.logger
    end

    def publish_backup(backup)
      logger.info "#{backup.filename} is not uploaded yet, will upload"
      storage.upload key: backup.filename, reader: backup_content(backup), expected_size: backup.processed_bytes
      logger.info "#{backup.filename} uploaded successfully"
    end

    def backup_content(backup)
      response = HTTP.get heroku.download_url(backup)
      raise "Unexpected dump download response #{response.status}" unless response.status.success?

      # This is blatantly wasteful since we load the entire backup content into memory
      # Instead, it should use an IO-readable object since fog can handle those.
      # Unfortunately a http.rb streaming body does not seem to conform to that interface,
      # and I did not want to spend too much time on figuring out how to wrap it.
      # Seems like a nice thing to clean up!
      response.body.to_s
    end

    def exists?(backup)
      cached_stored_files.find do |file|
        file.key == backup.filename && file.content_length == backup.processed_bytes
      end
    end

    # To prevent slow full index fetches we cache the pre-existing files once
    def cached_stored_files
      @cached_stored_files ||= storage.files
    end
  end
end
