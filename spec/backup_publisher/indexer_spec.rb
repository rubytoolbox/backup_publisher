# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::Indexer do
  let(:files) do
    [
      BackupPublisher::Storage::File.new(
        key: "data-dump-2018-02-16T20:07:25+00:00.dump",
        public_url: "https://example.com/foo.dump"
      ),
      BackupPublisher::Storage::File.new(
        key: "data-dump-2018-08-16T20:07:25+00:00.dump",
        public_url: "https://example.com/bar.dump"
      ),
      BackupPublisher::Storage::File.new(
        key: "data-dump-2018-09-16T20:07:25+00:00.dump"
      ),
    ]
  end

  let(:indexer) do
    described_class.new files: files
  end

  describe "#files" do
    it "only contains public files" do
      expect(indexer.files).to all(satisfy(&:public_url))
    end

    it "is sorted by created at DESC" do
      expect(indexer.files).to be == indexer.files.sort_by(&:created_at).reverse
    end
  end

  describe "#json" do
    it "is the expected json representation" do
      expect(Oj.load(indexer.json)).to be == [
        {
          "download_url" => "https://example.com/bar.dump",
          "created_at" => "2018-08-16T20:07:25+00:00",
        },
        {
          "download_url" => "https://example.com/foo.dump",
          "created_at" => "2018-02-16T20:07:25+00:00",
        },
      ]
    end
  end
end
