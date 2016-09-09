require 'octokit'
module Ghsync
  class RepoSync
    def initialize(config)
      @config = config
    end

    def sync
      org_sync
    end

    # Organization Sync should for each org
    # 1. Collect all the known projects in the target folder
    # 2. Collect all the organization repositories
    # 3. Exclude repos from the blacklist
    # 4. Exclude already pulled projects
    # 5. Clone projects using the ssh_url
    # 6. Fetch in existing projects for the org?
    def org_sync
      @config.organizations.each do |org|
        target_folder = File.expand_path(org["base_path"]) || @config.base_path
        known_projects = cloned_projects(org["name"], target_folder)
        Dir.chdir target_folder

        organization_repositories(org["name"]).each do |repo|
          unless known_projects.include?(repo[:name])
            `git clone #{repo[:ssh_url]}`
          end
        end
      end
    end

    def cloned_projects(org_name, target_folder)
      origin_urls(target_folder).collect do |origin| 
        $1 if origin =~ /#{org_name}\/(.*)\.git/
      end.compact
    end

    def origin_urls(target_folder)
      `cd #{target_folder} && for d in $(ls -d */); do (cd $d && git config --get remote.origin.url); done`.split
    end

    def organization_repositories(org_name)
      client.organization_repositories(org_name, per_page: 500)
    end


    def client
      @client ||= Octokit::Client.new login: @config.username, password: @config.password
    end
  end
end
