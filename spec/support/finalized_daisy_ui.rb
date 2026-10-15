# frozen_string_literal: true

# DaisyUI.finalize! freezes the configuration it finds. Examples tagged
# :finalizes run against a copy of the suite's configuration and get the
# suite's own, still writable one back afterwards. Component registries stay
# frozen once finalized; every writer replaces them instead of mutating them.
RSpec.configure do |config|
  config.around(:each, :finalizes) do |example|
    suite_configuration = DaisyUI.configuration
    DaisyUI.instance_variable_set(:@configuration, suite_configuration.dup)
    DaisyUI::ClassMerge.reset!
    example.run
  ensure
    DaisyUI.instance_variable_set(:@configuration, suite_configuration)
    DaisyUI::ClassMerge.reset!
  end
end
