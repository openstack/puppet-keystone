require 'spec_helper'

describe 'keystone::cron::fernet_rotate' do
  shared_examples 'keystone::cron::fernet_rotate' do
    let :params do
      {}
    end

    context 'with default parameters' do
      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_cron('keystone-manage fernet_rotate').with(
        :ensure      => 'present',
        :command     => 'keystone-manage fernet_rotate',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'keystone',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[keystone::service::end]',
      )}
    end

    context 'with overridden params' do
      before do
        params.merge!( :ensure   => 'absent',
                       :minute   => 13,
                       :hour     => 1,
                       :monthday => 3,
                       :month    => 4,
                       :weekday  => 2,
                       :maxdelay => 600,
                       :user     => 'nobody' )
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_cron('keystone-manage fernet_rotate').with(
        :ensure      => params[:ensure],
        :command     => "sleep `expr ${RANDOM} \\% #{params[:maxdelay]}`; keystone-manage fernet_rotate",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => params[:user],
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday],
        :require     => 'Anchor[keystone::service::end]',
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

      it_behaves_like 'keystone::cron::fernet_rotate'
    end
  end
end
