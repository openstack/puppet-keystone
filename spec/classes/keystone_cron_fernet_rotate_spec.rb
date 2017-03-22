require 'spec_helper'

describe 'keystone::cron::fernet_rotate' do

  let :facts do
    OSDefaults.get_facts({ :osfamily => 'Debian' })
  end

  let :params do
    { :ensure      => 'present',
      :minute      => 1,
      :hour        => 0,
      :monthday    => '*',
      :month       => '*',
      :weekday     => '*',
      :maxdelay    => 0,
    }
  end

  describe 'with default parameters' do
    it 'configures a cron' do
      is_expected.to contain_cron('keystone-manage fernet_rotate').with(
        :ensure      => params[:ensure],
        :command     => "keystone-manage fernet_rotate",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Anchor[keystone::service::end]',
      )
    end
  end

  describe 'when specifying a maxdelay param' do
    before :each do
      params.merge!(
        :maxdelay => 600
      )
    end

    it 'configures a cron with delay' do
      is_expected.to contain_cron('keystone-manage fernet_rotate').with(
        :ensure      => params[:ensure],
        :command     => "sleep `expr ${RANDOM} \\% #{params[:maxdelay]}`; keystone-manage fernet_rotate",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Anchor[keystone::service::end]',
      )
    end
  end

  describe 'when specifying a user param' do
    let :params do
      {
        :user => 'keystonecustom'
      }
    end

    it 'configures a cron with delay' do
      is_expected.to contain_cron('keystone-manage fernet_rotate').with(
        :ensure      => 'present',
        :command     => 'keystone-manage fernet_rotate',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystonecustom',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[keystone::service::end]',
      )
    end
  end

  describe 'when disabling cron job' do
    before :each do
      params.merge!(
        :ensure => 'absent'
      )
    end

    it 'configures a cron with delay' do
      is_expected.to contain_cron('keystone-manage fernet_rotate').with(
        :ensure      => params[:ensure],
        :command     => "keystone-manage fernet_rotate",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Anchor[keystone::service::end]',
      )
    end
  end
end
