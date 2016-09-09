require 'octokit'
module Ghsync
  class RepoSync
    def initialize(config)
      @config = config
    end

    def sync
      org_sync
    end

    def repo_list(org_name)
      organization_repositories(org_name).collect {|repo| repo[:name] }
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
        project_names = known_projects.keys
        Dir.chdir target_folder

        organization_repositories(org["name"]).each do |repo|
          unless project_names.include?(repo[:name]) || org["exclude"].include?(repo[:name])
            puts "Cloning #{repo[:name]}"
            `git clone #{repo[:ssh_url]}`
          end
        end
        known_projects.each do |name, project|
          puts "Syncing #{name}"
          `cd #{project[:path]} && git fetch`
        end
      end
    end

    def cloned_projects(org_name, target_folder)
      projects = `cd #{target_folder} && for d in $(ls -d */); do (cd $d && echo "$(pwd)|$(git config --get remote.origin.url)"); done`.split
      projects.inject({}) do |hsh, project|
        path, url = project.split("|")
        if url =~ /#{org_name}\/(.*)\.git/
          name = $1
          hsh[name] = {
            url: url,
            path: path
          }
        end 
        hsh
      end
    end

    def organization_repositories(org_name)
      client.organization_repositories(org_name)
    end


    def client
      @client ||= Octokit::Client.new(
        login: @config.username,
        password: @config.password,
        auto_paginate: true
      )
    end
  end
end
