# Test a normal puppet run with idempotency.
shared_examples_for 'puppet_apply_success' do |manifest|
  it 'should apply the manifest without error' do
    apply_manifest(manifest, :catch_failures => true)
  end
  it 'should be idempotent' do
    apply_manifest(manifest, :catch_changes => true)
  end
end

# Check that a file exists and its content match the one given as
# argument.  The argument can be a multiline string or an array of
# regexp.
#
# To use it encapsulate it in a context whose name is the file to
# test.
shared_examples 'a_valid_configuration' do |config_content|
  let(:configuration_file) do |example|
    # see the idiom it leads to later in this file
    example.metadata[:example_group][:parent_example_group][:description]
  end
  subject { file(configuration_file) }
  it { is_expected.to be_file }
  it { is_expected.to exist }
  content = nil
  if config_content.is_a?(Array)
    content = config_content
  else
    content = config_content.split("\n").map { |l| Regexp.quote(l) }
  end
  it 'content should be valid' do
    expect(subject.content).to include_regexp(content)
  end
end
