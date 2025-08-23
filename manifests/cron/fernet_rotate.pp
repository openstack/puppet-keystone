# Copyright 2017 Red Hat, Inc.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: keystone::cron::fernet_rotate
#
# Installs a cron job that rotates fernet keys.
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
#   Defaults to '0'
#
# [*monthday*]
#   (Optional) Day of month.
#   Defaults to '*'
#
# [*month*]
#   (Optional) Month.
#   Defaults to '*'.
#
# [*weekday*]
#   (Optional) Day of week.
#   Defaults to '*'
#
# [*maxdelay*]
#   (Optional) Max random delay, should be a positive integer.
#   Induces a random delay before running the cronjob to avoid running all
#   cron jobs at the same time on all hosts this job is configured.
#   Defaults to 0
#
# [*user*]
#   (Optional) Allow to run the crontab on behalf any user.
#   Defaults to $keystone::params::user
#
class keystone::cron::fernet_rotate (
  Enum['present', 'absent'] $ensure = present,
  $minute                           = 1,
  $hour                             = 0,
  $monthday                         = '*',
  $month                            = '*',
  $weekday                          = '*',
  Integer[0] $maxdelay              = 0,
  $user                             = $keystone::params::user,
) inherits keystone::params {
  include keystone::deps

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  cron { 'keystone-manage fernet_rotate':
    ensure      => $ensure,
    command     => "${sleep}keystone-manage fernet_rotate",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => $user,
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday,
    require     => Anchor['keystone::service::end'],
  }
}
