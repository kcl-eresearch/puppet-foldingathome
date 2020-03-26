require 'rake'
require 'rake_performance'
require 'find'
require 'fileutils'
require 'yaml'
require 'ra10ke'

root_dir = File.dirname(__FILE__)
# always destroy the kitchen when running within Teamcity
destroy_strategy = ENV['TEAMCITY_VERSION'] ? 'always' : 'passing'
# Remove ansi coloring in Teamcity. It messes up our .txt logs.
color = ENV['TEAMCITY_VERSION'] ? '--no-color' : '--color'
ENV['PUPPET_COLOR'] = '--color false' if ENV['TEAMCITY_VERSION']
ENV["PUPPET_DEBUG"] = ENV["PUPPET_DEBUG"] ? ENV["PUPPET_DEBUG"] : 'false'
ENV['SSL_CERT_FILE'] = "#{root_dir}/cacert.pem" unless ENV['SSL_CERT_FILE']

task :default => :restorepackages

namespace :acceptance do
  desc 'Restore packages. Install the puppet modules defined in Puppetfile.'
  task :restorepackages do
    `bundle exec r10k puppetfile install --verbose`
  end

  desc 'Execute the acceptance tests for one of our module.'
  task :kitchen, [:module] => [:restorepackages] do |task, args|
    raise "
    module parameter is missing.
    You should pass a module name to test.
    Try #{task}[devopstools] or #{task}[publicroles]
    " if args[:module].empty?

    modulename = args[:module][0]
    puts "Testing modules: #{modulename}"

    Dir.chdir("modules/#{modulename}") do

      begin
        Dir.mkdir('.kitchen') unless Dir.exist?('.kitchen')
        # This is the preferred way to call kitchen. Use test and let kitchen handle the
        # destroy, create, converge, setup, verify, destroy workflow
        sh "bundle exec kitchen test --destroy=#{destroy_strategy} --concurrency 2 --log-level=info #{color} 2> .kitchen/kitchen.stderr" do |ok, res|
          unless ok
            errors = IO.read('.kitchen/kitchen.stderr')

            # Let's show some nicer teamcity errors for quicker troubleshooting
            errors.split("\n").select { |line| line.include?('failed on instance') || line.include?('Failed to complete') }.each do |line|
              escaped_line = line.gsub('[', '|[').gsub(']', '|]').gsub("'", "|'")
              puts "##teamcity[buildProblem description='#{escaped_line}']"
            end

            raise errors
          end
        end
      ensure
        puts "##teamcity[publishArtifacts '#{Dir.pwd}/.kitchen/logs/*.log => logs.zip']"
      end

    end
  end

end

namespace :check do
  namespace :manifests do
    desc 'Validate syntax for all manifests'
    task :syntax do
      Bundler.with_clean_env  do
        sh "puppet parser validate modules/"
      end
    end

    require 'puppet-lint/tasks/puppet-lint'
    Rake::Task[:lint].clear
    desc 'puppet-lint all the manifests'
    PuppetLint::RakeTask.new :lint do |config|
      # # Pattern of files to ignore
      config.ignore_paths = ['ext-modules/']

      # List of checks to disable
      config.disable_checks = ['80chars', 'trailing_whitespace', '2sp_soft_tabs', 'hard_tabs']

      # # Enable automatic fixing of problems, defaults to false
      # config.fix = true
    end
  end

  namespace :ruby do
    desc 'Validate syntax for all ruby files'
    task :syntax do
      Dir.glob('modules/**/*.rb').each do |ruby_file|
        sh "ruby -c #{ruby_file}"
      end
      Dir.glob('modules/**/*.erb').each do |erb_file|
        sh "erb -P -x -T '-' #{erb_file} | ruby -c"
      end
    end
  end

  namespace :yaml do
    desc 'Validate syntax for all yaml files'
    task :syntax do
      Dir.glob('**/*.*yaml').each do |yaml_file|
        begin
          puts "Checking #{yaml_file}"
          yaml = YAML.load_file(yaml_file)
        rescue Exception => e
          raise "Failed to parse #{yaml_file}: #{e.message}"
        end
      end
    end
  end

  Ra10ke::RakeTask.new
end

# Disable running 'check:manifests:lint' as we have too many modules breaking puppet's rule :/
# someone do something.
task :checks => ['check:yaml:syntax', 'check:manifests:syntax', 'check:ruby:syntax']
#task :checks => ['check:manifests:syntax', 'check:manifests:lint', 'check:ruby:syntax']
