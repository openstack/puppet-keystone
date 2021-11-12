require 'spec_helper'

describe 'keystone::cron::trust_flush' do
  let :params do
    {}
  end

  shared_examples 'keystone::cron::trust_flush' do
    context 'with default parameters' do
      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_cron('keystone-manage trust_flush').with(
        :ensure      => 'present',
        :command     => 'keystone-manage trust_flush >>/var/log/keystone/keystone-trustflush.log 2>&1',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => 1,
        :hour        => '*',
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[keystone::dbsync::end]',
      )}
    end

    context 'with overriden params' do
      before do
        params.merge!(
          :ensure      => 'absent',
          :minute      => 13,
          :hour        => 23,
          :monthday    => 3,
          :month       => 4,
          :weekday     => 2,
          :maxdelay    => 600,
          :destination => '/tmp/trustflush.log',
          :user        => 'nobody' )
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_cron('keystone-manage trust_flush').with(
        :ensure      => params[:ensure],
        :command     => "sleep `expr ${RANDOM} \\% #{params[:maxdelay]}`; keystone-manage trust_flush >>#{params[:destination]} 2>&1",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => params[:user],
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Anchor[keystone::dbsync::end]',
      )}
    end

    context 'with age' do
      before do
        params.merge!(
          :age => 14
        )
      end

      it { is_expected.to contain_cron('keystone-manage trust_flush').with(
        :ensure      => 'present',
        :command     => 'keystone-manage trust_flush --date `date --date \'today - 14 days\' +\\%d-\\%m-\\%Y` >>/var/log/keystone/keystone-trustflush.log 2>&1',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => 1,
        :hour        => '*',
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[keystone::dbsync::end]',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({}))
      end

      it_behaves_like 'keystone::cron::trust_flush'
    end
  end
end
