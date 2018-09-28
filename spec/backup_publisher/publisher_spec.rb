# frozen_string_literal: true

require "spec_helper"

RSpec.describe BackupPublisher::Publisher do
  before { stub_heroku_api_calls! }

  let(:publisher) { described_class.new }

  it "mirrors all backups from heroku to storage" do
    expect { publisher.publish }
      .to change { publisher.storage.files.map { |file| { key: file.key, size: file.content_length } } }
      .from([])
      .to([
            { key: "example-2018-01-05T22:23:03+00:00.dump", size: 23 },
            { key: "example-2018-09-27T04:04:53+00:00.dump", size: 23 },
          ])
  end

  it "does not upload already published files again" do
    publisher.publish
    expect(publisher.storage).not_to receive(:upload)
    publisher.publish
  end
end
