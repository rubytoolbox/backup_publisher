# frozen_string_literal: true

module BackupPublisher
  class Indexer
    attr_accessor :files
    private :files=

    def initialize(files:, limit: 100)
      self.files = files.select(&:public_url).sort_by(&:created_at).reverse.first(limit)
    end

    def json
      data = files.map do |file|
        {
          download_url: file.public_url,
          created_at: file.created_at.iso8601,
        }
      end
      Oj.dump(data, mode: :json)
    end

    def html
      html_template.render OpenStruct.new(files: files)
    end

    def exports
      {
        "backups.json" => json,
        "index.html" => html,
      }
    end

    # rubocop:disable Metrics/MethodLength:
    def zip
      Dir.mktmpdir do |dir|
        zip_file_path = File.join dir, "export.zip"
        Zip::File.open zip_file_path, Zip::File::CREATE do |zipfile|
          exports.each do |name, content|
            zipfile.get_output_stream(name) do |f|
              f.write content
            end
          end
        end

        yield zip_file_path
      end
    end
    # rubocop:enable Metrics/MethodLength:

    private

    def html_template
      @html_template ||= Slim::Template.new File.join(File.dirname(__FILE__), "index.html.slim")
    end
  end
end
