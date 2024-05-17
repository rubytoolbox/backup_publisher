# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::Storage do
  let(:storage) do
    described_class.new
  end

  describe described_class::File do
    describe "#created_at" do
      {
        "data-dump-2018-02-16T20:07:25+00:00.dump" => Time.parse("2018-02-16T20:07:25+00:00"),
        "data-dump-201///--+00:00.dump" => nil,
        "nonsense" => nil,
      }.each do |name, expected_value|
        it "is #{expected_value.inspect} for #{name.inspect}" do
          expect(described_class.new(key: name).created_at).to eq expected_value
        end
      end
    end
  end

  it "has a list of files" do
    expect(storage.files).to be_an Array
  end

  describe "#upload" do
    let(:file) { File.open(fixture_path("backups_list.json")) }
    let(:expected_size) { file.size }
    let(:expected_file) do
      described_class::File.new(
        key: "my_file",
        content_length: expected_size,
        public_url: "https://databucket.s3.eu-central-1.amazonaws.com/my_file"
      )
    end

    it "uploads given IO under specified name" do
      expect { storage.upload key: "my_file", reader: file, expected_size: }
        .to change(storage, :files)
        .from([])
        .to([expected_file])
    end

    it "raises an exception when the expected size does not match" do
      expect { storage.upload key: "my_file", reader: file, expected_size: 1 }
        .to raise_error(/File size mismatch/)
    end
  end
end
