# == Class: cloudera::cdh::repo
#
# This class handles installing the Cloudera CDH software repositories.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*cdh_yumserver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*cdh_yumpath*]
#   The path to add to the $cdh_yumserver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*cdh_version*]
#   The version of Cloudera's Distribution, including Apache Hadoop to install.
#   Default: 4
#
# [*proxy*]
#   The URL to the proxy server for the YUM repositories.
#   Default: absent
#
# [*proxy_username*]
#   The username for the YUM proxy.
#   Default: absent
#
# [*proxy_password*]
#   The password for the YUM proxy.
#   Default: absent
#
# === Actions:
#
# Installs YUM repository configuration files.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'cloudera::cdh::repo':
#     cdh_version => '4.1',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class cloudera::cdh::repo (
  $ensure         = $cloudera::params::ensure,
  $cdh_yumserver  = $cloudera::params::cdh_yumserver,
  $cdh_yumpath    = $cloudera::params::cdh_yumpath,
  $cdh_version    = $cloudera::params::cdh_version,
  $proxy          = $cloudera::params::proxy,
  $proxy_username = $cloudera::params::proxy_username,
  $proxy_password = $cloudera::params::proxy_password
) inherits cloudera::params {
  case $ensure {
    /(present)/: {
      $enabled = '1'
    }
    /(absent)/: {
      $enabled = '0'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::operatingsystem {
    'CentOS', 'RedHat', 'OEL', 'OracleLinux': {
      yumrepo { 'cloudera-cdh4':
        descr          => 'Cloudera\'s Distribution for Hadoop, Version 4',
        enabled        => $enabled,
        gpgcheck       => 1,
        gpgkey         => "${cdh_yumserver}${cdh_yumpath}RPM-GPG-KEY-cloudera",
        baseurl        => "${cdh_yumserver}${cdh_yumpath}${cdh_version}/",
        priority       => $cloudera::params::yum_priority,
        protect        => $cloudera::params::yum_protect,
        proxy          => $proxy,
        proxy_username => $proxy_username,
        proxy_password => $proxy_password,
      }

      file { '/etc/yum.repos.d/cloudera-cdh4.repo':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      Yumrepo['cloudera-cdh4'] -> Package<|tag == 'cloudera-cdh4'|>
    }
    'SLES': {
      zypprepo { 'cloudera-cdh4':
        descr       => 'Cloudera\'s Distribution for Hadoop, Version 4',
        enabled     => $enabled,
        gpgcheck    => 1,
        gpgkey      => "${cdh_yumserver}${cdh_yumpath}RPM-GPG-KEY-cloudera",
        baseurl     => "${cdh_yumserver}${cdh_yumpath}${cdh_version}/",
        autorefresh => 1,
        priority    => $cloudera::params::yum_priority,
      }

      file { '/etc/zypp/repos.d/cloudera-cdh4.repo':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      Zypprepo['cloudera-cdh4'] -> Package<|tag == 'cloudera-cdh4'|>
    }
    default: { }
  }
}
