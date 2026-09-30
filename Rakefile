# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Build gem and verify contents"
task :build do
  sh("gem build daisyui.gemspec --strict")
  gem_file = Dir["daisyui-*.gem"].first
  abort "Gem file not found after build" unless gem_file

  sh("gem unpack #{gem_file} --target /tmp/gem-verify")
  puts "\n=== Gem contents ==="
  sh("find /tmp/gem-verify -type f | sort")
  sh("rm -rf /tmp/gem-verify #{gem_file}")
end

# `rake release[X.Y.Z]` lives in rakelib/release.rake (shared across the
# zoolutions gems); `bin/release` is its interactive front door.
namespace :release do
  desc "Stamp lib/daisy_ui/updated_at.rb (release hook, run by rake release)"
  task :prepare, [:version] do
    timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
    File.write("lib/daisy_ui/updated_at.rb", <<~RUBY)
      # frozen_string_literal: true

      module DaisyUI
        # This timestamp is automatically updated when releasing a new version
        # Format: YYYY-MM-DD HH:MM:SS UTC
        UPDATED_AT = "#{timestamp}"
      end
    RUBY
    puts "\e[32m✓\e[0m Updated lib/daisy_ui/updated_at.rb to #{timestamp}"
  end
end

task default: %i[spec rubocop]
