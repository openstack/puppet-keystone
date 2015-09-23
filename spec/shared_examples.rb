shared_examples_for "a Puppet::Error" do |description|
  it "with message matching #{description.inspect}" do
    expect { is_expected.to have_class_count(1) }.to raise_error(Puppet::Error, description)
  end
end

shared_examples_for 'parse title correctly' do |result|
  let(:title) do |example|
    example.metadata[:example_group][:description]
  end
  let(:current_class) do |example|
    example.metadata[:described_class]
  end
  let(:resource) { current_class.new(:title => title) }
  it 'should parse this title correctly' do
    times = result.delete(:calling_default) || 0
    Puppet::Provider::Keystone.expects(:default_domain).times(times).returns('Default')
    expect(resource.to_hash).to include(result)
  end
end

shared_examples_for 'croak on the title' do
  let(:title) do |example|
    example.metadata[:example_group][:description]
  end
  let(:current_class) do |example|
    example.metadata[:described_class]
  end
  let(:user) { current_class.new(:title => title) }
  it 'croak on the title' do
    expect { user }.to raise_error(Puppet::Error, /No set of title patterns matched the title/)
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
  let(:current_class) do |example|
    example.metadata[:described_class]
  end
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
    m_first.expects(:class).returns(current_class.resource_type)
    current_class.prefetch(resource)

    # found and not found
    expect(existing.provider.ensure).to eq(:present)
    expect(non_existing.provider.ensure).to eq(:absent)
  end
end

# attribute [Array[Hash]]
# - the first hash are the expected result
# - second are parameters to test default domain, required but can be empty
# - the rest are the combination of attributes you want to test
# see examples in user/user_role/tenant
shared_examples_for 'create the correct resource' do |attributes|
  expected_results = attributes.shift['expected_results']
  default_domain   = attributes.shift

  context 'domain filled' do
    attributes.each do |attribute|
      context 'test' do
        let(:resource_attrs) { attribute.values[0] }
        it "should correctly create the resource when #{attribute.keys[0]}" do
          times = resource_attrs.delete(:default_domain)
          unless times.nil?
            Puppet::Provider::Keystone.expects(:default_domain)
              .times(times)
              .returns(default_domain[:name])
          end
          provider.create
          expect(provider.exists?).to be_truthy
          expected_results.each do |key, value|
            expect(provider.send(key)).to eq(value)
          end
        end
      end
    end
  end
  context 'domain not passed, using default' do
    with_default_domain = default_domain[:attributes]
    if with_default_domain
      with_default_domain.each do |attribute|
        let(:resource_attrs) { attribute[1] }
        it 'should fall into the default domain' do
          Puppet::Provider::Keystone.expects(:default_domain)
            .times(default_domain[:times])
            .returns(default_domain[:name])
          provider.create
          expect(provider.exists?).to be_truthy
          expected_results.each do |key, value|
            expect(provider.send(key)).to eq(value)
          end
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
