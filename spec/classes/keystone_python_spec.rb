require 'spec_helper'

describe 'keystone::python' do

  let :facts do
    @default_facts.merge({ :osfamily => 'Debian' })
  end

  it { is_expected.to contain_package('python-keystone').with_ensure("present") }

  describe 'override ensure' do
    let(:params) { { :ensure => "latest" } }

    it { is_expected.to contain_package('python-keystone').with_ensure("latest") }
  end

end
