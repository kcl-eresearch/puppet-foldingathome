# frozen_string_literal: true

require 'puppet_litmus/rake_tasks' if Bundler.rubygems.find_name('puppet_litmus').any?
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'github_changelog_generator/task' if Bundler.rubygems.find_name('github_changelog_generator').any?
require 'puppet-strings/tasks' if Bundler.rubygems.find_name('puppet-strings').any?

def changelog_user
  return unless Rake.application.top_level_tasks.include? "changelog"
  returnVal = nil || JSON.load(File.read('metadata.json'))['author']
  raise "unable to find the changelog_user in .sync.yml, or the author in metadata.json" if returnVal.nil?
  puts "GitHubChangelogGenerator user:#{returnVal}"
  returnVal
end

def changelog_project
  return unless Rake.application.top_level_tasks.include? "changelog"

  returnVal = nil
  returnVal ||= begin
    metadata_source = JSON.load(File.read('metadata.json'))['source']
    metadata_source_match = metadata_source && metadata_source.match(%r{.*\/([^\/]*?)(?:\.git)?\Z})

    metadata_source_match && metadata_source_match[1]
  end

  raise "unable to find the changelog_project in .sync.yml or calculate it from the source in metadata.json" if returnVal.nil?

  puts "GitHubChangelogGenerator project:#{returnVal}"
  returnVal
end

def changelog_future_release
  return unless Rake.application.top_level_tasks.include? "changelog"
  returnVal = "v%s" % JSON.load(File.read('metadata.json'))['version']
  raise "unable to find the future_release (version) in metadata.json" if returnVal.nil?
  puts "GitHubChangelogGenerator future_release:#{returnVal}"
  returnVal
end

PuppetLint.configuration.send('disable_relative')

if Bundler.rubygems.find_name('github_changelog_generator').any?
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    raise "Set CHANGELOG_GITHUB_TOKEN environment variable eg 'export CHANGELOG_GITHUB_TOKEN=valid_token_here'" if Rake.application.top_level_tasks.include? "changelog" and ENV['CHANGELOG_GITHUB_TOKEN'].nil?
    config.user = "#{changelog_user}"
    config.project = "#{changelog_project}"
    config.future_release = "#{changelog_future_release}"
    config.exclude_labels = ['maintenance']
    config.header = "# Change log\n\nAll notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org)."
    config.add_pr_wo_labels = true
    config.issues = false
    config.merge_prefix = "### UNCATEGORIZED PRS; GO LABEL THEM"
    config.configure_sections = {
      "Changed" => {
        "prefix" => "### Changed",
        "labels" => ["backwards-incompatible"],
      },
      "Added" => {
        "prefix" => "### Added",
        "labels" => ["feature", "enhancement"],
      },
      "Fixed" => {
        "prefix" => "### Fixed",
        "labels" => ["bugfix"],
      },
    }
  end
else
  desc 'Generate a Changelog from GitHub'
  task :changelog do
    raise <<EOM
The changelog tasks depends on unreleased features of the github_changelog_generator gem.
Please manually add it to your .sync.yml for now, and run `pdk update`:
---
Gemfile:
  optional:
    ':development':
      - gem: 'github_changelog_generator'
        git: 'https://github.com/skywinder/github-changelog-generator'
        ref: '20ee04ba1234e9e83eb2ffb5056e23d641c7a018'
        condition: "Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.2')"
EOM
  end
end


desc 'Provision VM and run litmus tests'
task :run_tests, [:key, :collection, :module_repository] do |_task, args|
  args.with_defaults(module_repository: 'https://forgeapi.puppetlabs.com', key: 'vagrant')
  Rake::Task['litmus:provision_list'].invoke(args[:key])
  Rake::Task['litmus:install_agent'].invoke(args[:collection])
  Rake::Task['fix_secure_path'].invoke
  Rake::Task['litmus:install_module'].invoke(nil, args[:module_repository])
  Rake::Task['litmus:acceptance:parallel'].invoke
end

def fix_secure_path(collection, targets, inventory_hash)
  Honeycomb.start_span(name: 'fix_secure_path') do |span|
    span.add_field('litmus.collection', collection)
    span.add_field('litmus.targets', targets)

    include ::BoltSpec::Run
    params = if collection.nil?
               {}
             else
               Honeycomb.current_span.add_field('litmus.collection', collection)
               { 'collection' => collection }
             end
    raise "puppet_agent was not found in #{DEFAULT_CONFIG_DATA['modulepath']}, please amend the .fixtures.yml file" \
     unless File.directory?(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'puppet_agent'))

    # using boltspec, when the runner is called it changes the inventory_hash dropping the version field. The clone works around this
    bolt_result = run_task('provision::fix_secure_path', targets, params, config: DEFAULT_CONFIG_DATA, inventory: inventory_hash.clone)
    raise_bolt_errors(bolt_result, 'Fixing secure path failed.')
    bolt_result
  end
end

task :fix_secure_path, [:collection, :target_node_name] do |_task, args|
  inventory_hash = inventory_hash_from_inventory_file
  targets = 'ssh_nodes'

  puts 'fix_secure_path'
  require 'bolt_spec/run'
  include BoltSpec::Run

  results = fix_secure_path(args[:collection], targets, inventory_hash)
  results.each do |result|
    if result['status'] != 'success'
      command_to_run = "bolt task run provision::fix_secure_path --targets #{result['target']} --inventoryfile inventory.yaml --modulepath #{DEFAULT_CONFIG_DATA['modulepath']}"
      raise "Failed on #{result['target']}\n#{result}\ntry running '#{command_to_run}'"
    else
      puts "#{result['status']} running #{result['object']} on #{result['target']}"
    end
  end
end


