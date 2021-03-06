require 'rspec'

RSpec::Matchers.define :contain do |expected|
  match do |actual|
    actual.any? { |x| expected === x }
  end
end
