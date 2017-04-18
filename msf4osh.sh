#!/bin/bash

#Author: Carter Brainerd (https://github.com/thecarterb)

if ["$(id -u)" = "0"]; then
  echo "Please run script as a non-root user"
  exit $?
fi
echo " __  __  _____ ______ _  _    ____   _______   __"
echo          "|  \/  |/ ____|  ____| || |  / __ \ / ____\ \ / /"
echo          "| \  / | (___ | |__  | || |_| |  | | (___  \ V /"
echo          "| |\/| |\___ \|  __| |__   _| |  | |\___ \  > < "
echo          "| |  | |____) | |       | | | |__| |____) |/ . \ "
echo          "|_|  |_|_____/|_|       |_|  \____/|_____//_/ \_\ "
echo ""
echo ""
echo "This script automates the tedious task of installing the metasploit-framework"
echo "on Mac OSX. You can look at the source code here --> https://github.com/thecarterb/msf4osx"

#globals
MSFDFILE="/usr/local/share/metasploit-framework/config/database.yml"
GREENIN="\033[0;32m"
GREENOUT="\033[0m"
ENDTEXT="You're all set up! justetype --> \"./metasploit-framework/msfconsole\" (without quotes in the terminal to fire up metasploit!"

function msfdsetup ()
{
    ./opt/metasploit-framework/msfdb
}

#function to install dependencies
function installmsf ()
{
  echo -e "${GREENIN} Installing brew package manager...${GREENOUT}"
  /usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"
  echo -e "${GREENIN} Installing git...${GREENOUT}"
  brew install git
  echo -e "${GREENIN} Installing the latest version of ruby...${GREENOUT}"
  brew install ruby
  echo -e "${GREENIN} Installing nmap...${GREENOUT}"
  brew install nmap
  echo -e "${GREENIN} Installing bindler ruby gem...${GREENOUT}"
  gem install bundler
  echo -e "${GREENIN} Installing postgresql...${GREENOUT}"
  brew install postgresql --without-ossp-uuid
  initdb /usr/local/var/postgres
  mkdir -p ~/Library/LaunchAgents
  cp /usr/local/Cellar/postgresql/9.4.4/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
  launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
  pg_ctl -D /usr/local/var/postgres start
  createuser msf -P -h localhost
  createdb -O msf msf -h localhost

  echo -e "${GREENIN} Cloning the metasploit-framework...${GREENOUT}"
  cd /opt
  git clone https://github.com/rapid7/metasploit-framework
  cd metasploit-framework
  git clone https://github.com/thecarterb/msfdb-copy
  mv msfdb-copy/msfdb .
  rm -rf msfdb-copy
  for MSF in $(ls msf*); do ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF;done
  sudo chmod go+w /etc/profile
  sudo echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/config/database.yml >> /etc/profile
  echo "Installing required ruby gems..."
  bundle install

  msfdsetup #sets up the metasploit database by appending info to the $MSFDFILE

  #resets profiles
  source /etc/profile
  source ~/.bash_profile

  echo -e "${ENDTEXT}"

}

if [ `uname` == "Darwin" ]; then
  installmsf
fi
