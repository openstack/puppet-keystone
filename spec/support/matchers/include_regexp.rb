RSpec::Matchers.define :include_regexp do |expected|
  regexps = expected.dup
  regexps = [regexps] unless regexps.is_a?(Array)
  expected_count = regexps.count
  count = 0
  match do |actual|
    output = actual
    output = output.split("\n") unless output.is_a?(Array)
    output.each do |line|
      regexps.each_with_index do |regex, regexp_idx|
        if line.match(regex)
          count += 1
          regexps.delete_at(regexp_idx)
          break
        end
      end
    end
    expected_count == count
  end
end
