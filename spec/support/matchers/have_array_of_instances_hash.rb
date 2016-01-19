RSpec::Matchers.define :have_array_of_instances_hash do |expected|
  expected_array = expected.dup
  match do |actual|
    if actual.count != expected_array.count
      return false
    end
    actual_array = actual.map { |i| i.instance_variable_get('@property_hash') }
    expected_array.each do |e|
      actual_array.each do |a|
        if e == a
          actual_array.delete(a)
        end
      end
    end
    actual_array.empty?
  end
end
