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

      alias success? succeeded
      alias scheduled? schedule

      def filename
        "#{app}-#{finished_at.iso8601}.dump"
      end
    end
  end
end
