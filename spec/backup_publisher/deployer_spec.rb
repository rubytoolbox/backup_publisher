# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::Deployer do
  let(:deployer) do
    described_class.new
  end

  describe "#deploy" do
    before do
      stub_request(:post, "https://api.netlify.com/api/v1/sites/example.netlify.com/deploys")
        .with(
          body: fixture("backups_list.json"),
          headers: {
            "Authorization" => "Bearer foobarbaz",
            "Content-Type" => "application/zip",
          }
        )
        .to_return(status: 200, body: Oj.dump("id" => "1234"))

      # In order to verify the polling logic on the deployment status check
      # we need to track how often the call was made and adjust the response based on that
      status_calls = 0
      status_response = lambda do |_request|
        status_calls += 1
        state = status_calls > 1 ? "ready" : "uploading"
        { status: 200, body: Oj.dump("state" => state) }
      end

      stub_request(:get, "https://api.netlify.com/api/v1/sites/example.netlify.com/deploys/1234")
        .with(
          headers: {
            "Authorization" => "Bearer foobarbaz",
          }
        )
        .to_return(status_response)
    end

    it "deploys the given file path to netlify" do
      expect(deployer.deploy(zip_path: fixture_path("backups_list.json"))).to be true
    end
  end
end
