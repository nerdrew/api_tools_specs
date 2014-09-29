RSpec::Matchers.define :be_a_uuid do
  match do |actual|
    uuid_pattern = /[A-Fa-f0-9]{8}(-?)[A-Fa-f0-9]{4}(-?)[A-Fa-f0-9]{4}(-?)[A-Fa-f0-9]{4}(-?)[A-Fa-f0-9]{12}/
    actual.match uuid_pattern
  end
end
