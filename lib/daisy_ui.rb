# frozen_string_literal: true

require "phlex"
require "zeitwerk"
require_relative "daisy_ui/version"
require_relative "daisy_ui/updated_at"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "daisy_ui" => "DaisyUI"
)
loader.ignore("#{__dir__}/daisyui.rb")
loader.ignore("#{__dir__}/daisy_ui/updated_at.rb")
# The Rails engine references Rails::Engine, so it is required explicitly below
# (only when Rails is present) rather than autoloaded.
loader.ignore("#{__dir__}/daisy_ui/engine.rb")
# lib/tasks holds the engine's rake tasks, no constants.
loader.ignore("#{__dir__}/tasks")
loader.setup # ready!
loader.load_file("#{__dir__}/daisy_ui/base.rb")

module DaisyUI
  extend Configurable
  extend Phlex::Kit
end

# Optional Rails integration (exposes the opt-in Stimulus controller via
# importmap/assets). Loaded only under Rails; the gem stays pure Phlex otherwise.
require_relative "daisy_ui/engine" if defined?(Rails::Engine)
