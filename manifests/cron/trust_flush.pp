# Copyright (C) 2020 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: keystone::cron::trust_flush
#
# Installs a cron job to purge expired trusts.
#
# === Parameters
#
# [*ensure*]
#   (Optional) Valid values are present, absent.
#   Defaults to 'present'
#
# [*minute*]
#   (Optional) Minute.
#   Defaults to '1'
#
# [*hour*]
#   (Optional) Hour.
#   Defaults to *
#
# [*monthday*]
#   (Optional) Day of month.
#   Defaults to '*'
#
# [*month*]
#   (Optional) Month.
#   Defaults to '*'
#
# [*weekday*]
#   (Optional) Day of week.
#   Defaults to '*'
#
# [*maxdelay*]
#   (Optional) Max random delay in seconds. Should be a positive integer.
#   Induces a random delay before running the cronjob to avoid running all
#   cron jobs at the same time on all hosts this job is configured.
#   Defaults to 0
#
# [*age*]
#   (Optional) Number of days prior to today for deletion,
#   Defaults to 0
#
# [*destination*]
#   (Optional) Path to file to which rows should be archived
#   Defaults to '/var/log/keystone/keystone-trustflush.log'
#
# [*user*]
#   (Optional) Allow to run the crontab on behalf any user.
#   Defaults to $::keystone::params::user
#
class keystone::cron::trust_flush (
  Enum['present', 'absent'] $ensure = present,
  $minute                           = 1,
  $hour                             = '*',
  $monthday                         = '*',
  $month                            = '*',
  $weekday                          = '*',
  Integer $maxdelay                 = 0,
  Integer $age                      = 0,
  $destination                      = '/var/log/keystone/keystone-trustflush.log',
  $user                             = $::keystone::params::user,
) inherits keystone::params {

  include keystone::deps

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  if $age == 0 {
    $date = ''
  } else {
    $date = "--date `date --date 'today - ${age} days' +\\%d-\\%m-\\%Y` "
  }

  cron { 'keystone-manage trust_flush':
    ensure      => $ensure,
    command     => "${sleep}keystone-manage trust_flush ${date}>>${destination} 2>&1",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => $user,
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday,
    require     => Anchor['keystone::dbsync::end'],
  }
}
