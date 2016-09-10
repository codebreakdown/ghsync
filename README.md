# Ghsync - The GitHub Repository Syncronizer

Sync your github organization repos in one command. It clones missing repositories and fetches existing one. Makes joining a new organization a snap!

## Installation

You can easily install `ghsync` with the following command:

    $ gem install ghsync

## Configuration

Your ghsync configuration should be saved to ~/.ghsync/config.json. 
```json
{
  "base_path": "~/dev",
  "username": "<github username>",
  "password": "<github password>",
  "organizations": [
    {
      "name": "codebreakdown",
      "exclude": [],
      "base_path": "~/dev/codebreakdown"
    }
  ],
  "repositories": [
    {
      "owner": "codebreakdown",
      "name": "ghsync"
    }
  ]
}
```

### GitHub Authentication

#### Multi-Factor Authentication

Sadly, at the moment `ghsync` doesn't support GitHub's Multi-Factor
Authentication. 

#### OAuth

It is also lacking support for GitHub's OAuth mechanism.

#### HTTP Basic Auth

The HTTP Basic Auth will work as long as you don't have multi-factor
authentication enabled for your account.

#### Personal Access Token

Personal Access Token authentication is currently supported and this is the
recommended authentication mechanism to use right now. It is the only
authentication mechanism you can use at the moment if you have multi-factor
authentication enabled.

Simply go to your GitHub **Account Settings**, select **Applications**, click
the **Create new token** button in the **Personal Access Token** section. Give
it the name "GHsync" and submit. This will generate your personal access token.
Then simply put your personal access token in the `~/.ghsync/config.json` as your GitHub
username and "x-oauth-basic" as your GitHub password.

## Usage

Once you have configured `ghsync` as described above you can launch it by simply
running the following command:

    ghsync

Once it launches, it will use the information provided in the
`~/.ghsync/config.json` configuration file to fetch all the configured
repositories and either fetch them if they exist, or clone them if they are
missing.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codebreakdown/ghsync. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

