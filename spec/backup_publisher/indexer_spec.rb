# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::Indexer do
  let(:files) do
    [
      BackupPublisher::Storage::File.new(
        key: "data-dump-2018-02-16T20:07:25+00:00.dump",
        content_length: 12_000_000,
        public_url: "https://example.com/foo.dump"
      ),
      BackupPublisher::Storage::File.new(
        key: "data-dump-2018-08-16T20:07:25+00:00.dump",
        content_length: 12_000_000,
        public_url: "https://example.com/bar.dump"
      ),
      BackupPublisher::Storage::File.new(
        content_length: 12_000_000,
        key: "data-dump-2018-09-16T20:07:25+00:00.dump"
      ),
    ]
  end

  let(:indexer) do
    described_class.new files:
  end

  describe "#files" do
    it "only contains public files" do
      expect(indexer.files).to all(satisfy(&:public_url))
    end

    it "is sorted by created at DESC" do
      expect(indexer.files).to eq indexer.files.sort_by(&:created_at).reverse
    end

    it "respects a given custom limit" do
      indexer = described_class.new files:, limit: 1
      expect(indexer.files).to eq [files[1]]
    end
  end

  describe "#json" do
    # rubocop:disable RSpec/ExampleLength
    it "is the expected json representation" do
      expect(Oj.load(indexer.json)).to eq [
        {
          "created_at" => "2018-08-16T20:07:25+00:00",
          "download_url" => "https://example.com/bar.dump",
          "size" => 12_000_000,
        },
        {
          "created_at" => "2018-02-16T20:07:25+00:00",
          "download_url" => "https://example.com/foo.dump",
          "size" => 12_000_000,
        },
      ]
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "#html" do
    let(:doc) { Nokogiri::HTML.parse(indexer.html) }

    it "contains the expected list entries" do
      expect(doc.css("ul li").map(&:text)).to eq [
        "2018-08-16 20:07:25 UTC (~11.44 MB)",
        "2018-02-16 20:07:25 UTC (~11.44 MB)",
      ]
    end

    # This is only for debugging and styling the actual export ;)
    it "saves the file to temp dir" do
      tmp_dir = File.join(File.dirname(__FILE__), "..", "..", "tmp")
      destination = File.join(tmp_dir, "index.html")
      File.open(destination, "w+") { |f| f.puts indexer.html }
      expect(File.read(destination)).to eq "#{indexer.html}\n"
    end
  end

  describe "#exports" do
    it "contains backups.json and index.html files with expected contents" do
      expect(indexer.exports).to eq(
        "backups.json" => indexer.json,
        "index.html" => indexer.html
      )
    end
  end

  describe "#zip" do
    it "builds a zip file containing the exports" do
      entries = {}
      indexer.zip do |zip_path|
        Zip::File.open(zip_path) do |zip_file|
          # Handle entries one by one
          zip_file.each do |entry|
            entries[entry.name] = entry.get_input_stream.read
          end
        end
      end

      expect(entries).to eq indexer.exports
    end
  end
end
