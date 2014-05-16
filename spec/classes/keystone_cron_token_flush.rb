require 'spec_helper'

describe 'keystone::cron::token_flush' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  it 'configures a cron' do
    should contain_cron('keystone-manage token_flush').with(
      :command     => 'keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1',
      :environment => 'PATH=/bin:/usr/bin:/usr/sbin',
      :user        => 'keystone',
      :minute      => 1,
      :hour        => 0,
      :monthday    => '*',
      :month       => '*',
      :weekday     => '*'
    )
  end
end
