# frozen_string_literal: true

module BackupPublisher
  class Storage
    class File
      include Virtus.value_object

      attribute :key, String
      attribute :content_length, Integer
      attribute :public_url, String

      def ==(other)
        attributes == other.attributes
      end

      def created_at
        match = key.match(/(\d{4}-\d{2}-\d{2}T[^.]+)/)
        return unless match

        Time.parse match[1]
      end
    end

    attr_accessor :bucket
    private :bucket, :bucket=

    def initialize(
      access_key: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
      region: ENV.fetch("AWS_REGION"),
      bucket_name: ENV.fetch("AWS_BUCKET")
    )
      connection = Fog::Storage.new(
        provider: "AWS",
        aws_access_key_id: access_key,
        aws_secret_access_key: secret,
        region:
      )
      self.bucket = connection.directories.get bucket_name
    end

    def files
      bucket.files.all.map do |file|
        File.new(
          key: file.key,
          content_length: file.content_length,
          public: file.public?,
          public_url: file.public_url
        )
      end
    end

    def upload(key:, reader:, expected_size:)
      file = bucket.files.create(
        key:,
        body: reader,
        public: true
      )
      return true if file.content_length == expected_size

      raise "File size mismatch! expected=#{expected_size} actual=#{file.content_length}"
    end
  end
end
