# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Minified Stimulus controllers (scripts/build_controllers.js). The output is
# deterministic for the bun in .bun-version, so it is committed and shipped.
namespace :build do
  # Quoted so git expands the pathspec against the index: a deleted .min.js
  # is caught too, not just a changed one.
  min_glob = "app/javascript/daisy_ui/controllers/*.min.js*"

  desc "Minify the Stimulus controllers via bun"
  task :js do
    wanted = File.read(".bun-version").strip
    found = `bun --version 2>/dev/null`.strip
    abort "bun #{wanted} is required (found #{found.empty? ? 'none' : found}): https://bun.sh" unless found == wanted

    sh "bun run scripts/build_controllers.js"
  end

  desc "Verify the committed minified controllers match a fresh build (CI drift guard)"
  task js_check: :js do
    sh "git diff --exit-code -- '#{min_glob}'" do |ok, _res|
      unless ok
        warn "\e[31mMinified controllers are stale — run `bundle exec rake build:js` and commit the result.\e[0m"
        abort "Committed .min.js/.min.js.map do not match a fresh build."
      end
    end
  end
end

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
