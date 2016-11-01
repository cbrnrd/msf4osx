#!/bin/bash

#Author: Carter Brainerd (https://github.com/thecarterb)

if ["$(id -u)" = "0"]; then
  echo "DO NOT RUN THE SCRIPT AS ROOT UNLESS YOU ALWAYS INTEND\nTO USE METASPLOIT AS ROOT"
fi
echo \" ""__  __  _____ ______ _  _    ____   _______   __\n"
          "|  \/  |/ ____|  ____| || |  / __ \ / ____\ \ / /\n"
          "| \  / | (___ | |__  | || |_| |  | | (___  \ V /\n"
          "| |\/| |\___ \|  __| |__   _| |  | |\___ \  > < \n"
          "| |  | |____) | |       | | | |__| |____) |/ . \ \n"
          "|_|  |_|_____/|_|       |_|  \____/|_____//_/ \_\ \n\"
echo "\n\n"
echo "This script automates the tedious task of installing the metasploit-framework"
echo "on Mac OSX. You can look at the source code here --> https://github.com/thecarterb/msf4osx"

#globals
MSFDFILE = "/usr/local/share/metasploit-framework/config/database.yml"
GREENIN = "\033[1;32;0m"
GREENOUT = "\033[0m 1;32;0m"
ENDTEXT = "You're all set up! just type --> \"./metasploit-framework/msfconsole\" (without quotes in " \
             "the terminal to fire up metasploit!"
UNAME = uname

msfdsetup ()
{
    echo 'production:' >> $MSFDFILE
    echo ' adapter: postgresql' >> $MSFDFILE
    echo ' database: msf' >> $MSFDFILE
    echo ' username: msf' >> $MSFDFILE
    echo ' password: ' >> $MSFDFILE
    echo ' host: 127.0.0.1' >> $MSFDFILE
    echo ' port: 5432' >> $MSFDFILE
    echo ' pool: 75' >> $MSFDFILE
    echo ' timeout: 5' >> $MSFDFILE
}

if [$UNAME = "Darwin"]; then
  install
fi

#function to install dependencies
install ()
{
  echo $GREENIN"Installing brew package manager..."$GREENOUT
  /usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"
  echo $GREENIN"Installing git..."$GREENOUT
  brew install git
  echo $GREENIN"Installing the latest version of ruby..."$GREENOUT
  brew install ruby
  echo $GREENIN"Installing nmap..."$GREENOUT
  brew install nmap
  echo $GREENIN"Installing bindler ruby gem..."$GREENOUT
  gem install bundler
  echo $GREENIN"Installing postgresql..."$GREENOUT
  brew install postgresql --without-ossp-uuid
  initdb /usr/local/var/postgres
  mkdir -p ~/Library/LaunchAgents
  cp /usr/local/Cellar/postgresql/9.4.4/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
  launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
  pg_ctl -D /usr/local/var/postgres start
  createuser msf -P -h localhost
  createdb -O msf msf -h localhost

  echo $GREENIN"Cloning the metasploit-framework..."$GREENOUT
  cd /usr/local/share
  git clone https://github.com/rapid7/metasploit-framework
  cd metasploit-framework
  for MSF in $(ls msf*); do ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF;done
  sudo chmod go+w /etc/profile
  sudo echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/config/database.yml >> /etc/profile
  echo "Installing required ruby gems..."
  bundle install

  msfdsetup #sets up the metasploit database by appending info to the $MSFDFILE

  #resets profiles
  source /etc/profile
  source ~/.bash_profile

  echo $ENDTEXT

}
