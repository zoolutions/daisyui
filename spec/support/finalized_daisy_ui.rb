# frozen_string_literal: true

# The suite's configuration is finalized (spec_helper configures DaisyUI, as
# an app does at boot), so it is frozen. Examples tagged :finalizes run
# against a writable copy of it, which they may write to directly or
# finalize, and get the suite's own back afterwards. Component registries
# stay frozen once finalized; every writer replaces them instead of mutating
# them.
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
