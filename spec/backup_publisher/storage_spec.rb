# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::Storage do
  let(:storage) do
    described_class.new
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
        public: true,
        public_url: "https://databucket.s3-eu-central-1.amazonaws.com/my_file"
      )
    end

    it "uploads given IO under specified name" do
      expect { storage.upload key: "my_file", reader: file, expected_size: expected_size }
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
