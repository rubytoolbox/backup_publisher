# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::HerokuClient do
  before do
    default_headers = {
      headers: {
        "Authorization" => "Basic #{Base64.encode64([username, api_key].join(':'))}".strip,
      },
    }

    stub_request(:get, "https://postgres-api.heroku.com/client/v11/apps/#{app}/transfers")
      .with(default_headers)
      .to_return(status: 200, body: fixture("backups_list.json"), headers: {})

    stub_request(:post, "https://postgres-api.heroku.com/client/v11/apps/#{app}/transfers/123/actions/public-url")
      .with(default_headers)
      .to_return(status: 200, body: fixture("backup_download_url.json"), headers: {})
  end

  let(:username) { "foo" }
  let(:api_key) { "bar" }
  let(:app) { "example" }

  let(:client) do
    described_class.new username: username, api_key: api_key
  end

  describe "#backups" do
    let(:expected_backups) do
      [
        described_class::Backup.new(
          num: 5,
          processed_bytes: 40_703_267,
          succeeded: true,
          schedule: true,
          finished_at: "2018-09-27 04:04:53 +0000"
        ),
        described_class::Backup.new(
          num: 3,
          processed_bytes: 15_828_892,
          succeeded: true,
          schedule: false,
          finished_at: "2018-01-05 22:23:03 +0000"
        ),
      ]
    end

    it "returns the expected backups for given app" do
      expect(client.backups(app).map(&:attributes))
        .to match expected_backups.map(&:attributes)
    end
  end

  describe "#download_url" do
    it "returns the download url for given app and backup" do
      expect(client.download_url(app, 123)).to be == "https://example.com/foo/bar/baz/my-very-long-download-url"
    end
  end
end
