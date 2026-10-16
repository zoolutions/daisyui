# frozen_string_literal: true

require "English"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Minified Stimulus controllers (scripts/build_controllers.js). The output is
# deterministic for the bun in .bun-version, so it is committed and shipped.
namespace :build do
  # `git status`, not `git diff`: a .min.js deleted from the index comes back
  # from the rebuild as an untracked file, which only status reports. Quoted so
  # git, not the shell, expands the pathspec.
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
    status = `git status --porcelain -- '#{min_glob}'`
    abort "git status failed" unless $CHILD_STATUS.success?
    # Second column: the working tree against the index (a staged rebuild is fine).
    drift = status.lines.reject { |line| line[1] == " " }.join
    next if drift.empty?

    warn drift
    warn "\e[31mMinified controllers are stale — run `bundle exec rake build:js` and commit the result.\e[0m"
    abort "Committed .min.js/.min.js.map do not match a fresh build."
  end
end

# data/daisyui/tailwind_manifest.json: what an app's Tailwind build needs per
# component (DaisyUI::Tailwind). The manifest spec fails until it is regenerated.
namespace :tailwind do
  desc "Regenerate data/daisyui/tailwind_manifest.json from the components"
  task :manifest do
    require_relative "lib/daisyui"

    path = DaisyUI::Tailwind::ManifestBuilder.write
    puts "\e[32m✓\e[0m #{path}"
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
