# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::HerokuClient::Backup do
  let(:scheduled_backup) do
    described_class.new(
      app: "example",
      num: 5,
      processed_bytes: 40_703_267,
      succeeded: true,
      schedule: true,
      finished_at: "2018-09-27 04:04:53 +0000"
    )
  end

  let(:manual_backup) do
    described_class.new(
      app: "example",
      num: 3,
      processed_bytes: 15_828_892,
      succeeded: true,
      schedule: false,
      finished_at: "2018-01-05 22:23:03 +0000"
    )
  end

  describe "filename" do
    it "is the expected value for scheduled backup" do
      expect(scheduled_backup.filename).to eq "example-2018-09-27T04:04:53+00:00.dump"
    end

    it "is the expected value for manual backup" do
      expect(manual_backup.filename).to eq "example-2018-01-05T22:23:03+00:00.dump"
    end
  end
end
