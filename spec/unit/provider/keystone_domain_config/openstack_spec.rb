#
# these tests are a little concerning b/c they are hacking around the
# modulepath, so these tests will not catch issues that may eventually arise
# related to loading these plugins.
# I could not, for the life of me, figure out how to programatcally set the modulepath
$LOAD_PATH.push(
  File.join(
    File.dirname(__FILE__),
    '..',
    '..',
    '..',
    'fixtures',
    'modules',
    'inifile',
    'lib')
)
require 'spec_helper'
provider_class = Puppet::Type.type(:keystone_domain_config).provider(:openstack)

describe provider_class do

  include PuppetlabsSpec::Files
  let(:tmpfile) { tmpfilename('keystone.conf') }

  context '#interface' do
    it 'should configure a domain file if the name has :: delimiter' do
      resource = Puppet::Type::Keystone_domain_config.new(
        { :name => 'bar::dude/foo', :value => 'blahh' }
      )
      provider = provider_class.new(resource)
      expect(provider.path).to eq('/etc/keystone/domains/keystone.bar.conf')
      expect(provider.section).to eq('dude')
      expect(provider.setting).to eq('foo')
    end

    it "should raise an error if the configuration directory doesn't exist" do
      resource = Puppet::Type::Keystone_domain_config.new(
        { :name => 'bar::dude/foo', :value => 'blahh' }
      )
      expect { provider_class.new(resource).create }
        .to raise_error(Puppet::Error::OpenstackMissingDomainDir)
    end
  end

  context '#create' do
    before(:example) do
      # This is created just to get access to the ini_file.
      config = Puppet::Type::Keystone_config.new({
        :name  => 'identity/domain_config_dir',
        :value => '/tmp'
      })
      config_provider = Puppet::Type.type(:keystone_config)
        .provider(:ini_setting)
      keystone_config = config_provider.new(config)
      keystone_config.class.expects(:file_path).at_least_once.returns(tmpfile)
      keystone_config.create

      @domain = Puppet::Type::Keystone_domain_config.new(
        { :name => 'bar::dude/foo', :value => 'blahh' }
      )
      @domain_provider = provider_class.new(@domain)
    end

    after(:example) do
      Dir.glob('/tmp/keystone.*.conf').each do |tmp_conf|
        File.delete(tmp_conf)
      end
    end

    context 'correct name definition' do
      it 'should adjust the domain path if it is modified with Keystone_config' do
        expect(@domain_provider.file_path)
          .to eq('/tmp/keystone.bar.conf')
      end

      it 'should fill a domain configuration correctly' do
        expect { @domain_provider.create }.not_to raise_error
        expect(File).to exist('/tmp/keystone.bar.conf')
        expect(File.read('/tmp/keystone.bar.conf'))
          .to eq('
[dude]
foo=blahh
')
      end

      it 'should fill multiple domain configurations correctly' do
        baz_domain = Puppet::Type::Keystone_domain_config.new(
          { :name => 'baz::duck/go', :value => 'where' }
        )
        baz_domain_provider = provider_class.new(baz_domain)

        expect { @domain_provider.create }.not_to raise_error
        expect { baz_domain_provider.create }.not_to raise_error

        expect(File).to exist('/tmp/keystone.bar.conf')
        expect(File).to exist('/tmp/keystone.baz.conf')

        expect(File.read('/tmp/keystone.bar.conf'))
          .to eq('
[dude]
foo=blahh
')

        expect(File.read('/tmp/keystone.baz.conf'))
          .to eq('
[duck]
go=where
')
      end

      it 'should find the instance' do
        @domain_provider.create
        instances = @domain_provider.class.instances
        expect(instances.count).to eq(1)
        expect(
          instances[0].instance_variable_get('@property_hash')[:name]
        ).to eq('bar::dude/foo')
      end
    end

    context 'invalid name definition' do
      it 'should raise an error if no domain is given' do
        resource = Puppet::Type::Keystone_domain_config.new(
          { :name => 'dude/foo', :value => 'blahh' }
        )
        expect { provider_class.new(resource).create }
          .to raise_error(Puppet::Error::OpenstackMissingDomainName)
      end

      it 'should raise an error if an empty domain is given' do
        resource = Puppet::Type::Keystone_domain_config.new(
          { :name => '::dude/foo', :value => 'blahh' }
        )
        expect { provider_class.new(resource).create }
          .to raise_error(Puppet::Error::OpenstackMissingDomainName)
      end
    end
  end
end
