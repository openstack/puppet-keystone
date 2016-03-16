require 'spec_helper'

describe 'keystone::deps' do

  it 'set up the anchors' do
    is_expected.to contain_anchor('keystone::install::begin')
    is_expected.to contain_anchor('keystone::install::end')
    is_expected.to contain_anchor('keystone::config::begin')
    is_expected.to contain_anchor('keystone::config::end')
    is_expected.to contain_anchor('keystone::db::begin')
    is_expected.to contain_anchor('keystone::db::end')
    is_expected.to contain_anchor('keystone::dbsync::begin')
    is_expected.to contain_anchor('keystone::dbsync::end')
    is_expected.to contain_anchor('keystone::service::begin')
    is_expected.to contain_anchor('keystone::service::end')
  end
end
