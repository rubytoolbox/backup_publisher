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
end
