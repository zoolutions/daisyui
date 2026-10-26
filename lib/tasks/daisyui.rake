# frozen_string_literal: true

# Loaded by the Rails engine (Rails loads an engine's lib/tasks/*.rake).
namespace :daisyui do
  desc "Write the Tailwind sources of the app's own DaisyUI components to OUTPUT (stdout without one)"
  task :tailwind, [:output] => :environment do |_task, args|
    argv = ["--app"]
    argv.push("--output", args[:output]) if args[:output]
    status = DaisyUI::Tailwind::Command.run(argv)
    exit(status) unless status.zero?
  end
end
