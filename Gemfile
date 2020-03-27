source 'https://rubygems.org'
def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end


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
gem 'librarian-puppet'

puppet_version = ENV['PUPPET_GEM_VERSION']
gems = {}

gems['puppet'] = location_for(puppet_version)

if Gem.win_platform? && puppet_version =~ %r{^(file:///|git://)}
  # If we're using a Puppet gem on Windows which handles its own win32-xxx gem
  # dependencies (>= 3.5.0), set the maximum versions (see PUP-6445).
  gems['win32-dir'] =      ['<= 0.4.9', require: false]
  gems['win32-eventlog'] = ['<= 0.6.5', require: false]
  gems['win32-process'] =  ['<= 0.7.5', require: false]
  gems['win32-security'] = ['<= 0.2.5', require: false]
  gems['win32-service'] =  ['0.8.8', require: false]
end

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end
