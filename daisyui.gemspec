# frozen_string_literal: true

require_relative "lib/daisy_ui/version"

Gem::Specification.new do |s|
  s.name = "daisyui"
  s.version = DaisyUI::VERSION
  s.licenses = ["MIT"]
  s.summary = "Ruby UI components for DaisyUI built with Phlex"
  s.description = "DaisyUI is a comprehensive Ruby UI component library that brings DaisyUI's beautiful Tailwind CSS components to your Ruby applications using Phlex. Build modern, accessible web interfaces with ease."
  s.authors = ["Mikael Henriksson"]
  s.email = "mikael@zoolutions.llc"
  # Use `git ls-files` when packaging from a checkout; fall back to a Dir glob
  # when there is no .git (e.g. building the docs Docker image from the gem source
  # copied into the container). Both paths MUST ship the same prefixes — app/ and
  # config/ carry the Stimulus controller (app/javascript) and importmap config,
  # so omitting them would publish a broken gem.
  s.files = begin
    files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
      ls.readlines("\x0", chomp: true).select do |f|
        f.start_with?("exe/", "lib/", "app/", "config/") ||
          f == "CHANGELOG.md" || f == "LICENSE.txt" || f == "LICENSE-tailwind_merge.txt" || f == "README.md"
      end
    end
    files.empty? ? raise(Errno::ENOENT) : files
  rescue Errno::ENOENT
    Dir[
      "exe/*", "lib/**/*.rb", "app/**/*", "config/**/*",
      "CHANGELOG.md", "LICENSE.txt", "LICENSE-tailwind_merge.txt", "README.md"
    ].select { |f| File.file?(f) }
  end
  s.bindir = "exe"
  s.executables = s.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  s.homepage = "https://github.com/mhenrixon/daisyui"
  s.metadata = {
    "source_code_uri" => "https://github.com/mhenrixon/daisyui",
    "changelog_uri" => "https://github.com/mhenrixon/daisyui/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/mhenrixon/daisyui/issues",
    "rubygems_mfa_required" => "true"
  }

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "phlex", "~> 2.0", ">= 2.0.0"
  s.add_dependency "zeitwerk", "~> 2.6", ">= 2.6.2"
end
