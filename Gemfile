source 'https://rubygems.org'

group :development do
  gem 'puppet-lint'
  gem 'yamllint'

  gem 'hiera-eyaml' # used to encrypt hiera data

  gem 'test-kitchen', '~> 2'
  # Use our own fork which makes it easier to download the latest version of puppet 6 for windows
  gem 'kitchen-puppet', :git => 'https://github.com/red-gate/kitchen-puppet', :branch => 'master'
  gem 'kitchen-vagrant', '~> 1'
  gem 'kitchen-zip', :git => 'https://github.com/nicolasvan/kitchen-zip', :branch => 'master'

  # We use serverspec to test the state of our servers
  gem 'serverspec', '~> 2'

  # We use rake as our build engine
  gem 'rake', '~> 13'
  # This gem tells us how long each rake task takes.
  gem 'rake-performance'

  gem 'ra10ke' # Add rake tasks to manage puppetfile
end

gem 'r10k', '~> 3'
