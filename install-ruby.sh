#!/bin/bash
source config.sh

PLATFORM=`uname -m`

if [ $PLATFORM = i686 ]
then
  PLATFORM=i386
fi

echo "Platform is $PLATFORM"

yum install -y wget bzip2 tar make gcc ntp sudo git

wget http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
rpm --import ./RPM-GPG-KEY-EPEL-6

wget http://dl.fedoraproject.org/pub/epel/6/$PLATFORM/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6-8.noarch.rpm

sed -i "s/https/http/" /etc/yum.repos.d/epel.repo

yum install -y libyaml-devel 

echo "Setting time to avoid makefile warning..."
ntpdate pool.ntp.org

echo "Downloading src tarballs..."
cd /tmp
if [ ! -f /tmp/ruby-install-0.4.3.tar.gz ]; then
    wget --no-check-certificate -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz
fi

if [ ! -d /tmp/ruby-install-0.4.3 ]; then
    tar -xzvf ruby-install-0.4.3.tar.gz
fi

if [ ! -f /tmp/chruby-0.3.8.tar.gz ]; then
    wget --no-check-certificate -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
fi

if [ ! -d /tmp/chruby-0.3.8 ]; then
    tar -xzvf chruby-0.3.8.tar.gz
fi

echo "Setting up ruby-install..."
(cd ruby-install-0.4.3/ && make install)

if [ ! -d /opt/rubies/ruby-$FACTER_ruby_version ]; then
    echo "Installing ruby 2.0.0..."
    /usr/local/bin/ruby-install ruby $FACTER_ruby_version
fi

if [ -f /usr/local/bin/ruby-install ]; then
    echo "Setting up chruby..."
    (cd chruby-0.3.8/ && make install)
fi

if [ ! -f /etc/profile.d/chruby.sh ]; then
    echo "Set up 2.0 as default ruby version"
    echo "source /usr/local/share/chruby/chruby.sh && chruby $FACTER_ruby_version" >> /etc/profile.d/chruby.sh
    chmod a+x /etc/profile.d/chruby.sh
fi

echo "Ruby 2.0 installed, ready on next login/new shell."