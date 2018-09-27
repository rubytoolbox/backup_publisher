# frozen_string_literal: true

module BackupPublisher
  class HerokuClient
    class Backup
      # We don't care about the actual value, just make a boolean out
      # of the fact whether this is a truthy value
      class PresenceBoolean < Virtus::Attribute
        def coerce(value)
          !!value
        end
      end

      include Virtus.value_object

      values do
        attribute :app, String
        attribute :num, Integer
        attribute :processed_bytes, Integer
        attribute :succeeded, Boolean
        attribute :schedule, PresenceBoolean
        attribute :finished_at, Time
      end
    end

    attr_accessor :username, :api_key
    private :username=, :api_key=

    def initialize(username: ENV.fetch("HEROKU_USER"), api_key: ENV.fetch("HEROKU_API_KEY"))
      self.username = username
      self.api_key = api_key
    end

    def backups(app)
      response = client.get url(app, "transfers")
      handle_response(response)
        .map { |data| Backup.new data.merge(app: app) }
    end

    def download_url(backup)
      response = client.post url(backup.app, "transfers", backup.num.to_s, "actions", "public-url")
      handle_response(response)["url"]
    end

    private

    def handle_response(response)
      raise "Unknown response status #{response.status}" unless response.status.success?

      Oj.load response.body, mode: :json
    end

    def client
      HTTP.basic_auth(user: username, pass: api_key)
    end

    def url(*args)
      File.join base_url, *args
    end

    def base_url
      File.join "https://postgres-api.heroku.com/client/v11/apps"
    end
  end
end
