require 'octokit'
module Ghsync
  class RepoSync
    def initialize(config)
      @config = config
    end

    def sync
      org_sync
      repo_sync
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
        target_folder = File.expand_path(org["base_path"] || @config.base_path)
        known_projects = cloned_projects(org["name"], target_folder)
        project_names = known_projects.keys
        Dir.chdir target_folder

        organization_repositories(org["name"]).each do |repo|
          unless project_names.include?(repo[:name]) || org["exclude"].include?(repo[:name])
            # TODO There should be a library to handle IO
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

    # Repo sync for each owner/repo should
    # 1. Find all known projects from the owner in the target folder
    # 2. Find the specific project by repo name
    # 3. Clone the project if it doesn't exist, else fetch it
    def repo_sync
      @config.repositories.each do |repo_config|
        target_folder = File.expand_path(repo_config["base_path"] || @config.base_path)
        # TODO This seem expensive to search for projects for each repo, maybe
        # turn this into something that is done for all target folders for
        # orgs and repos?
        projects = cloned_projects(repo_config["owner"], target_folder)
        project = projects[repo_config["name"]]
        Dir.chdir target_folder
        if project.nil?
          repo = repository(repo_config["owner"], repo_config["name"])
          puts "Cloning #{repo_config["owner"]}/#{repo_config["name"]}"
          `git clone #{repo[:ssh_url]}`
        else
          puts "Syncing #{repo[:name]}"
          `cd #{project[:path]} && git fetch`
        end
      end
    end

    def projects_in_folder(target_folder)
      # TODO There are probably libraries to make this less hacky
      `cd #{target_folder} && for d in $(ls -d */); do (cd $d && echo "$(pwd)|$(git config --get remote.origin.url)"); done`.split
    end

    def cloned_projects(org_name, target_folder)
      projects = projects_in_folder(target_folder)
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

    def repository(owner, name)
      client.repository("#{owner}/#{name}")
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
