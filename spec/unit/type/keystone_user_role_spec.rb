require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_user_role'

describe Puppet::Type.type(:keystone_user_role) do

  before :each do
    @user_roles = Puppet::Type.type(:keystone_user_role).new(
      :title => 'foo@bar',
      :roles => ['a', 'b']
    )

    @roles = @user_roles.parameter('roles')
  end

  it 'should not be in sync for' do
    expect(@roles.insync?(['a', 'b', 'c'])).to be false
    expect(@roles.insync?('a')).to be false
    expect(@roles.insync?(['a'])).to be false
    expect(@roles.insync?(nil)).to be false
  end

  it 'should be in sync for' do
    expect(@roles.insync?(['a', 'b'])).to be true
    expect(@roles.insync?(['b', 'a'])).to be true
  end

  ['user', 'user@REALM', 'us:er'].each do |user|
    describe "#{user}::user_domain@project::project_domain" do
      include_examples 'parse title correctly',
        :user           => user,
        :user_domain    => 'user_domain',
        :project        => 'project',
        :project_domain => 'project_domain',
        :domain         => PuppetX::Keystone::CompositeNamevar::Unset
    end

    describe "#{user}::user_domain@::domain" do
      include_examples 'parse title correctly',
        :user           => user,
        :user_domain    => 'user_domain',
        :project        => PuppetX::Keystone::CompositeNamevar::Unset,
        :project_domain => PuppetX::Keystone::CompositeNamevar::Unset,
        :domain         => 'domain'
    end

    describe "#{user}::user_domain@project" do
      include_examples 'parse title correctly',
        :user           => user,
        :user_domain    => 'user_domain',
        :project        => 'project',
        :project_domain => 'Default',
        :domain         => PuppetX::Keystone::CompositeNamevar::Unset
    end

    describe "#{user}@project::project_domain" do
      include_examples 'parse title correctly',
        :user           => user,
        :user_domain    => 'Default',
        :project        => 'project',
        :project_domain => 'project_domain',
        :domain         => PuppetX::Keystone::CompositeNamevar::Unset
    end

    describe "#{user}@::domain" do
      include_examples 'parse title correctly',
        :user           => user,
        :user_domain    => 'Default',
        :project        => PuppetX::Keystone::CompositeNamevar::Unset,
        :project_domain => PuppetX::Keystone::CompositeNamevar::Unset,
        :domain         => 'domain'
    end

    describe "#{user}@project" do
      include_examples 'parse title correctly',
        :user           => user,
        :user_domain    => 'Default',
        :project        => 'project',
        :project_domain => 'Default',
        :domain         => PuppetX::Keystone::CompositeNamevar::Unset
    end

    describe "#{user}@proj:ect" do
      include_examples 'parse title correctly',
        :user           => user,
        :user_domain    => 'Default',
        :project        => 'proj:ect',
        :project_domain => 'Default',
        :domain         => PuppetX::Keystone::CompositeNamevar::Unset
    end
  end
  describe 'name::domain::foo@project' do
    include_examples 'croak on the title'
  end
  describe 'name::dom@ain@project' do
    include_examples 'croak on the title'
  end
  describe 'name::domain@' do
    include_examples 'croak on the title'
  end
  describe 'name::domain@project::' do
    include_examples 'croak on the title'
  end
  describe '@project:project_domain' do
    include_examples 'croak on the title'
  end

  describe '#autorequire' do
    let(:project_good) do
      Puppet::Type.type(:keystone_tenant).new(:title => 'bar')
    end
    let(:project_good_ml) do
      Puppet::Type.type(:keystone_tenant).new(:title => 'blah',
                                              :name => 'bar')
    end
    let(:project_good_fq) do
      Puppet::Type.type(:keystone_tenant).new(:title => 'bar::Default')
    end
    let(:project_bad) do
      Puppet::Type.type(:keystone_tenant).new(:title => 'bar::other_domain')
    end
    let(:user_good) do
      Puppet::Type.type(:keystone_user).new(:title => 'foo')
    end
    let(:user_good_ml) do
      Puppet::Type.type(:keystone_user).new(:title  => 'blah',
                                            :name   => 'foo')
    end
    let(:user_good_fq) do
      Puppet::Type.type(:keystone_user).new(:title => 'foo::Default')
    end
    let(:user_bad) do
      Puppet::Type.type(:keystone_user).new(:title => 'foo::other_domain')
    end
    let(:domain) do
      Puppet::Type.type(:keystone_domain).new(:title => 'bar')
    end

    context 'tenant' do
      describe 'normal tenant title' do
        let(:resources) { [@user_roles, project_good, project_bad] }
        include_examples 'autorequire the correct resources',
          :default_domain => 2
      end

      describe 'meaningless tenant title' do
        let(:resources) { [@user_roles, project_good_ml, project_bad] }
        include_examples 'autorequire the correct resources',
          :default_domain => 1
      end

      describe 'meaningless tenant title' do
        let(:resources) { [@user_roles, project_good_fq, project_bad] }
        include_examples 'autorequire the correct resources',
          :default_domain => 1
      end
    end

    context 'domain' do
      it 'should not autorequire any tenant' do
        catalog.add_resource @user_roles, domain
        dependency = @user_roles.autorequire
        expect(dependency.size).to eq(0)
      end
      let(:resources) { [@user_roles, project_good, project_bad] }
      include_examples 'autorequire the correct resources'
    end

    context 'user' do
      describe 'normal user title' do
        let(:resources) { [@user_roles, user_good, user_bad] }
        include_examples 'autorequire the correct resources'
      end
      describe 'meaningless user title' do
        let(:resources) { [@user_roles, user_good_ml, user_bad] }
        include_examples 'autorequire the correct resources'
      end

      describe 'fq user title' do
        let(:resources) { [@user_roles, user_good_fq, user_bad] }
        include_examples 'autorequire the correct resources'
      end
    end
  end

  describe 'parameter conflict' do
    let(:user_roles) do
      Puppet::Type.type(:keystone_user_role).new(
        :title   => 'user@::domain',
        :project => 'project',
        :roles   => %w(a b)
      )
    end
    let(:domain) { user_roles.parameter('domain') }

    it 'should not allow domain and project at the same time' do
      expect { domain.validate }.to raise_error(Puppet::ResourceError, /Cannot define both project and domain/)
    end
  end
end
