# frozen_string_literal: true

module BackupPublisher
  class Deployer
    attr_accessor :http, :site
    private :http, :http=, :site=

    def initialize(netlify_token: ENV.fetch("NETLIFY_TOKEN"), netlify_site: ENV.fetch("NETLIFY_SITE"))
      self.http = HTTP.auth("Bearer #{netlify_token}")
      self.site = netlify_site
    end

    def deploy(zip_path:)
      deploy_id = perform_deployment file: File.open(zip_path)
      wait_for_deployment deploy_id
    end

    private

    def perform_deployment(file:)
      response = http.headers("Content-Type" => "application/zip")
                     .post(
                       "https://api.netlify.com/api/v1/sites/#{site}/deploys",
                       body: file
                     )

      raise "Unexpected response status=#{response.status}" unless response.status.success?

      Oj.load(response)["id"]
    end

    def wait_for_deployment(deploy_id, max_tries: 20)
      tries = 0
      while tries <= max_tries
        tries += 1
        BackupPublisher.logger.info "Waiting for deployment #{deploy_id} to #{site} to become ready"
        return true if deployment_ready? deploy_id

        sleep 1
      end
    end

    def deployment_ready?(deploy_id)
      response = http.get("https://api.netlify.com/api/v1/sites/#{site}/deploys/#{deploy_id}")
      raise "Unexpected response status=#{response.status}" unless response.status.success?

      Oj.load(response.body)["state"] == "ready"
    end
  end
end
