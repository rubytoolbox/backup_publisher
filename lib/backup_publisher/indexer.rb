# frozen_string_literal: true

module BackupPublisher
  class Indexer
    attr_accessor :files
    private :files=

    def initialize(files:)
      self.files = files.select(&:public_url).sort_by(&:created_at).reverse
    end

    def json
      data = files.map do |file|
        {
          download_url: file.public_url,
          created_at: file.created_at.iso8601,
        }
      end
      Oj.dump(data, mode: :json)
    end
  end
end
