require 'json'

module Ghsync
  class Config
    attr_accessor :organizations, :repositories, :username, :password, :base_path
    
    def initialize(config)
      @organizations = config["organizations"] || []
      @repositories = config["repositories"] || []
      @username = config["username"]
      @password = config["password"]
      @base_path = config["base_path"]
      if config["use_pra"]
        pra_config = Config.parse_pra_config_file
        github_config = pra_config["pull_sources"].select {|source| source["type"] == "github"}.first
        unless github_config.nil?
          @organizations += github_config["config"]["organizations"]
          @repositories += github_config["config"]["repositories"]
          @username ||= github_config["config"]["username"]
          @password ||= github_config["config"]["password"]
        end
      end
    end

    def self.load_config
      return self.new(self.parse_config_file)
    end

    def self.parse_config_file
      self.json_parse(self.read_config_file(config_path))
    end

    def self.parse_pra_config_file
      self.json_parse(self.read_config_file(pra_config_path))
    end

    def self.read_config_file(path)
      file = File.open(path, "r")
      contents = file.read
      file.close
      return contents
    end

    def self.config_path
      if File.exists?(File.join(self.users_home_directory, '.ghsync', 'config.json'))
        return File.join(self.users_home_directory, '.ghsync', 'config.json')
      end
    end

    def self.pra_config_path
      if File.exists?(File.join(self.users_home_directory, '.pra', 'config.json'))
        return File.join(self.users_home_directory, '.pra', 'config.json')
      else
        return File.join(self.users_home_directory, '.pra.json')
      end
    end

    def self.users_home_directory
      return ENV['HOME']
    end

    def self.json_parse(content)
      return JSON.parse(content)
    end
  end
end
