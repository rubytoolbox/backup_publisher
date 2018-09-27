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
      .to_return(status: 200, body: "[]", headers: {})

    stub_request(:post, "https://postgres-api.heroku.com/client/v11/apps/#{app}/transfers/123/actions/public-url")
      .with(default_headers)
      .to_return(status: 200, body: '"Hello World"', headers: {})
  end

  let(:username) { "foo" }
  let(:api_key) { "bar" }
  let(:app) { "example" }

  let(:client) do
    described_class.new username: username, api_key: api_key
  end

  describe "#backups" do
    it "returns the expected backups for given app" do
      expect(client.backups(app)).to be_an Array
    end
  end

  describe "#download_url" do
    it "returns the download url for given app and backup" do
      expect(client.download_url(app, 123)).to be_a String
    end
  end
end
