require 'spec_helper'

describe 'keystone::messaging::amqp' do

  shared_examples_for 'keystone messaging amqp' do
    it { is_expected.to contain_class('keystone::messaging::amqp').with(
      'amqp_pre_settled'            => ['<SERVICE DEFAULT>'],
      'amqp_idle_timeout'           => '<SERVICE DEFAULT>',
      'amqp_ssl_ca_file'            => '<SERVICE DEFAULT>',
      'amqp_ssl_cert_file'          => '<SERVICE DEFAULT>',
      'amqp_ssl_key_file'           => '<SERVICE DEFAULT>',
      'amqp_ssl_key_password'       => '<SERVICE DEFAULT>',
      'amqp_allow_insecure_clients' => '<SERVICE DEFAULT>',
      'amqp_sasl_mechanisms'        => '<SERVICE DEFAULT>',
    )}

    context 'with specific parameters' do
      let :params do
        {
          :amqp_pre_settled            => ['rpc-cast','rpc-reply','notify'],
          :amqp_idle_timeout           => '100',
          :amqp_allow_insecure_clients => 'yes',
          :amqp_sasl_mechanisms        => 'ANONYMOUS DIGEST-MD5 EXTERNAL PLAIN',
        }
      end

      it { is_expected.to contain_class('keystone::messaging::amqp').with(
        'amqp_pre_settled'            => ['rpc-cast','rpc-reply','notify'],
        'amqp_idle_timeout'           => '100',
        'amqp_allow_insecure_clients' => 'yes',
        'amqp_sasl_mechanisms'        => 'ANONYMOUS DIGEST-MD5 EXTERNAL PLAIN',
      )}
    end

    context 'with AMQP 1.0 communication SSLed' do
      let :params do
        {
          :amqp_ssl_ca_file      => '/path/to/ssl/ca/certs',
          :amqp_ssl_cert_file    => '/path/to/ssl/cert/file',
          :amqp_ssl_key_file     => '/path/to/ssl/keyfile',
          :amqp_ssl_key_password => '/path/to/ssl/pw_file',
        }
      end

      it { is_expected.to contain_class('keystone::messaging::amqp').with(
        'amqp_ssl_ca_file'      => '/path/to/ssl/ca/certs',
        'amqp_ssl_cert_file'    => '/path/to/ssl/cert/file',
        'amqp_ssl_key_file'     => '/path/to/ssl/keyfile',
        'amqp_ssl_key_password' => '/path/to/ssl/pw_file',
      )}
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'keystone messaging amqp'
    end
  end

end
