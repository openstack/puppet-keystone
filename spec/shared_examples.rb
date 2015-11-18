shared_examples_for "a Puppet::Error" do |description|
  it "with message matching #{description.inspect}" do
    expect { is_expected.to have_class_count(1) }.to raise_error(Puppet::Error, description)
  end
end

shared_examples_for 'parse title correctly' do |result|
  let(:title) do |example|
    example.metadata[:example_group][:description]
  end
  let(:resource) { described_class.new(:title => title) }
  it 'should parse this title correctly' do
    expect(resource.to_hash).to include(result)
  end
end

shared_examples_for 'croak on the title' do
  let(:title) do |example|
    example.metadata[:example_group][:description]
  end
  let(:resource) { described_class.new(:title => title) }
  it 'croak on the title' do
    expect { resource }.to raise_error(Puppet::Error, /No set of title patterns matched the title/)
  end
end

shared_examples_for 'croak on the required parameter' do |attr|
  let(:title) do |example|
    example.metadata[:example_group][:description]
  end
  prefix = attr.is_a?(String) ? attr : ''

  let(:resource) { described_class.new(:title => title) }
  it 'croak on the missing required parameter' do
    expect { resource }
      .to raise_error(Puppet::ResourceError, "#{prefix} Required parameter.")
  end
end

shared_examples_for 'croak on read-only parameter' do |resource|
  prefix = resource.delete(:_prefix)
  it 'should raise an error' do
    expect { described_class.new(resource) }
      .to raise_error(Puppet::ResourceError, "#{prefix} Read-only property.")
  end
end

shared_examples_for 'succeed with the required parameters' do |extra_params|
  let(:title) do |example|
    example.metadata[:example_group][:description]
  end
  extra_params_to_merge = extra_params || {}
  let(:resource) { described_class.new({ :title => title }.merge(extra_params_to_merge)) }
  it 'has all required parameters' do
    expect { resource }.not_to raise_error
  end
end

# Let resources to [<tested_resource>, <required>, <required>, ..., <not_required>]
shared_examples_for 'autorequire the correct resources' do
  let(:catalog) { Puppet::Resource::Catalog.new }
  it 'should autorequire correctly' do
    resource = resources[0]
    resources_good = resources[1...resources.count-1]
    catalog.add_resource(*resources)

    dependency = resource.autorequire
    expect(dependency.size).to eq(resources_good.count)
    resources_good.each_with_index do |good, idx|
      expect(dependency[idx].target).to eq(resource)
      expect(dependency[idx].source).to eq(good)
    end
  end
end

# Let resources to [<existing>, <non_existing>]
shared_examples_for 'prefetch the resources' do
  it 'should correctly prefetch the existing resource' do
    existing     = resources[0]
    non_existing = resources[1]
    resource = mock
    r = []
    r << existing

    catalog = Puppet::Resource::Catalog.new
    r.each { |res| catalog.add_resource(res) }
    m_value = mock
    m_first = mock
    resource.expects(:values).returns(m_value)
    m_value.expects(:first).returns(m_first)
    m_first.expects(:catalog).returns(catalog)
    m_first.expects(:class).returns(described_class.resource_type)
    described_class.prefetch(resource)

    # found and not found
    expect(existing.provider.ensure).to eq(:present)
    expect(non_existing.provider.ensure).to eq(:absent)
  end
end

# attribute [Array[Hash]]
# - the first hash are the expected result
# - second are the combination of attributes you want to test
# The provider must be build from ressource_attrs
# see examples in keystone_{user/user_role/tenant/service}
shared_examples_for 'create the correct resource' do |attributes|
  expected_results = attributes.shift['expected_results']
  attributes.each do |attribute|
    context 'test' do
      let(:resource_attrs) { attribute.values[0] }
      it "should correctly create the resource when #{attribute.keys[0]}" do
        provider.create
        expect(provider.exists?).to be_truthy
        expected_results.each do |key, value|
          expect(provider.send(key)).to eq(value)
        end
      end
    end
  end
end

# Let resources to [<resource_1>, <duplicate>]
shared_examples_for 'detect duplicate resource' do
  let(:catalog) { Puppet::Resource::Catalog.new }
  it 'should detect the duplicate' do
    expect { catalog.add_resource(resources[0]) }.not_to raise_error
    expect { catalog.add_resource(resources[1]) }.to raise_error(ArgumentError,/Cannot alias/)
  end
end
