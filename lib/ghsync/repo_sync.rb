require 'octokit'
module Ghsync
  class RepoSync
    def initialize(config)
      @config = config
    end

    def organization_repositories(org_name)
      client.organization_repositories(org_name, per_page: 500)
    end


    def client
      @client ||= Octokit::Client.new login: @config.username, password: @config.password
    end
  end
end
