RSpec.configure do |config|
  require 'api_tools_specs/anonymous_model'
  require 'api_tools_specs/rspec/shared_examples/has_uuid'
  require 'api_tools_specs/rspec/shared_examples/is_soft_deletable'
  require 'api_tools_specs/rspec/shared_examples/belongs_to_with'
  require 'api_tools_specs/rspec/shared_examples/has_default_status'
  require 'api_tools_specs/rspec/shared_examples/scope_uuid'
  require 'api_tools_specs/rspec/helpers'
  config.extend APIToolsSpecs::AnonymousModel
  config.extend APIToolsSpecs::RSpec::Helpers
end
