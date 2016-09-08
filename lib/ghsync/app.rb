require_relative 'config'
require_relative 'repo_sync'
require 'pry'

module Ghsync
  class App
    def run
      config = Config.load_config
      repo_syncer = RepoSync.new(config)
      binding.pry
      repo_syncer.sync
    end
  end
end
