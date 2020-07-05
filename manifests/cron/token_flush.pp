#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# == Class: keystone::cron::token_flush
#
# DEPRECATED!
# Installs a cron job to purge expired tokens.
#
# === Parameters
#
# [*ensure*]
#   (Optional) Valid values are present, absent.
#   Defaults to undef
#
# [*minute*]
#   (Optional) Minute.
#   Defaults to undef
#
# [*hour*]
#   (Optional) Hour.
#   Defaults to undef
#
# [*monthday*]
#   (Optional) Day of month.
#   Defaults to undef
#
# [*month*]
#   (Optional) Month.
#   Defaults to undef
#
# [*weekday*]
#   (Optional) Day of week.
#   Defaults to undef
#
# [*maxdelay*]
#   (Optional) Max random delay in seconds. Should be a positive integer.
#   Induces a random delay before running the cronjob to avoid running all
#   cron jobs at the same time on all hosts this job is configured.
#   Defaults to undef
#
# [*destination*]
#   (Optional) Path to file to which rows should be archived
#   Defaults to undef
#
# [*user*]
#   (Optional) Allow to run the crontab on behalf any user.
#   Defaults to undef
#
class keystone::cron::token_flush (
  $ensure      = undef,
  $minute      = undef,
  $hour        = undef,
  $monthday    = undef,
  $month       = undef,
  $weekday     = undef,
  $maxdelay    = undef,
  $destination = undef,
  $user        = undef,
) {

  warning('The keystone::cron::token_flush class is deprecated and has no effect')

}
