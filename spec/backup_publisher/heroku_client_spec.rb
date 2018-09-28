# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::HerokuClient do
  before { stub_heroku_api_calls! }

  let(:app) { "example" }

  let(:client) do
    described_class.new username: "foo", api_key: "bar"
  end

  describe "#backups" do
    let(:expected_backups) do
      [
        described_class::Backup.new(
          app: "example",
          num: 5,
          processed_bytes: 23,
          succeeded: true,
          schedule: true,
          finished_at: "2018-09-27 04:04:53 +0000"
        ),
        described_class::Backup.new(
          app: "example",
          num: 3,
          processed_bytes: 23,
          succeeded: true,
          schedule: false,
          finished_at: "2018-01-05 22:23:03 +0000"
        ),
      ]
    end

    it "returns the expected backups for given app" do
      expect(client.backups(app))
        .to be == expected_backups
    end
  end

  describe "#download_url" do
    it "returns the download url for given backup object" do
      backup = described_class::Backup.new(app: "example", num: 5)
      expect(client.download_url(backup)).to be == "https://example.com/foo/bar/baz/my-very-long-download-url"
    end
  end
end
