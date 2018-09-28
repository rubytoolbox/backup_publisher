# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher do
  describe ".logger" do
    it "is a Logger" do
      expect(described_class.logger).to be_a Logger
    end

    it "is a memoized instance" do
      expect(described_class.logger.object_id).to be == described_class.logger.object_id
    end
  end

  describe ".process!" do
    before do
      stub_heroku_api_calls!
      allow(BackupPublisher::Deployer).to receive(:new).and_return(deployer)
    end

    let(:deployer) { instance_double BackupPublisher::Deployer }

    it "deploys using the deployer" do
      expect(deployer).to receive(:deploy).with(kind_of(String))
      described_class.process!
    end
  end
end
