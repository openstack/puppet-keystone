require 'spec_helper'

describe 'keystone::cron::token_flush' do

  let :facts do
    @default_facts.merge({ :osfamily => 'Debian' })
  end

  let :params do
    { :ensure      => 'present',
      :minute      => 1,
      :hour        => 0,
      :monthday    => '*',
      :month       => '*',
      :weekday     => '*',
      :maxdelay    => 0,
      :destination => '/var/log/keystone/keystone-tokenflush.log' }
  end

  describe 'with default parameters' do
    it 'configures a cron' do
      is_expected.to contain_cron('keystone-manage token_flush').with(
        :ensure      => params[:ensure],
        :command     => "keystone-manage token_flush >>#{params[:destination]} 2>&1",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Package[keystone]',
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
      is_expected.to contain_cron('keystone-manage token_flush').with(
        :ensure      => params[:ensure],
        :command     => "sleep `expr ${RANDOM} \\% #{params[:maxdelay]}`; keystone-manage token_flush >>#{params[:destination]} 2>&1",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Package[keystone]',
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
      is_expected.to contain_cron('keystone-manage token_flush').with(
        :ensure      => 'present',
        :command     => 'keystone-manage token_flush >>/var/log/keystone/keystone-tokenflush.log 2>&1',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystonecustom',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Package[keystone]',
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
      is_expected.to contain_cron('keystone-manage token_flush').with(
        :ensure      => params[:ensure],
        :command     => "keystone-manage token_flush >>#{params[:destination]} 2>&1",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Package[keystone]',
      )
    end
  end
end
