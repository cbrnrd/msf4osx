import os

__author__ = "Carter Brainerd"

osType = os.name  # gets the name of the OS the user is running

os.system("echo \" ""__  __  _____ ______ _  _    ____   _______   __\n"
          "|  \/  |/ ____|  ____| || |  / __ \ / ____\ \ / /\n"
          "| \  / | (___ | |__  | || |_| |  | | (___  \ V /\n"
          "| |\/| |\___ \|  __| |__   _| |  | |\___ \  > < \n"
          "| |  | |____) | |       | | | |__| |____) |/ . \ \n"
          "|_|  |_|_____/|_|       |_|  \____/|_____//_/ \_\ \n\" ")
print("\n\n")

print "This script automates the tedious task of installing the metasploit-framework\n" \
      "on Mac OSX. You can look at the source code here --> https://github.com/thecarterb/msf4osx/blob/master/main.py"
print "\n"

print "\033[1;31;40m NOTE: WHEN A PASSWORD PROMPT APPEARS, YOU MUST TYPE IN YOUR PASSWORD \033[0m "
print "\n\n"

msfdbFile = "/usr/local/share/metasploit-framework/config/database.yml"
# defines ANSI escape codes for green text in the terminal
greenTextEscIn = "\033[1;32;40m"
greenTextEscOut = "\033[0m 1;32;40m"
endingText = "You're all set up! just type --> \"./metasploit-framework/msfconsole\" (without quotes in " \
             "the terminal to fire up metasploit!"


def dbSetup():
    msfdbFile.writelines(['production:', ' adapter: postgresql', ' database: msf',
                          ' username: msf', '  password: ', ' host: 127.0.0.1',
                          ' port: 5432', ' pool: 75', ' timeout: 5'])
    msfdbFile.close()


if osType != "Windows":
    brewQ = raw_input("Do you have brew? (y/n) ")
    # print(brewQ)
    if brewQ == "n":
        print greenTextEscIn, "Installing brew package manager...", greenTextEscOut
        os.system("/usr/bin/ruby -e \"$(curl -fsSL https://"
                  "raw.githubusercontent.com/Homebrew/install/master/install)\"")
        print "\n\n"
        print greenTextEscIn, "Installing git...", greenTextEscOut
        os.system("brew install git")
        print "\n\n"
        print greenTextEscIn, "Installing ruby 2.1...", greenTextEscOut
        os.system("brew install homebrew/versions/ruby21")
        print "\n\n"
        print greenTextEscIn, "Installing nmap... (Prerequisite for metasploit)", greenTextEscOut
        os.system("brew install nmap")
        print "\n\n"
        print greenTextEscIn, "Fetching latest version of metasploit from GitHub...", greenTextEscOut
        os.system("git clone https://github.com/rapid7/metasploit-framework -v")
        print "\n\n"
        os.system("cd metasploit-framework")
        print greenTextEscIn, "Getting bundler and installing proper ruby gems...", greenTextEscOut
        os.system("sudo gem install bundler")
        os.system("bundle install")

        tempInput = input()
        print "Would you like to set up a database? (y/n)", tempInput
        if tempInput == "y":
            print greenTextEscIn, "Getting and setting up postgres...", greenTextEscOut
            os.system("brew install postgres --without-ossp-uuid")
            os.system("initdb /usr/local/var/postgres")
            os.system("mkdir -p ~/Library/LaunchAgents")
            os.system("cp /usr/local/Cellar/postgresql/9.4.4/homebrew.mxcl.postgresql.plist "
                      "~/Library/LaunchAgents/")
            os.system("launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl."
                      "postgresql.plist")
            os.system("createuser msf -P -h localhost")  # creates db user
            os.system("createdb -O msf msf -h localhost")
            dbSetup()
        else:
            print endingText
    elif brewQ == "y":
        print greenTextEscIn, "Installing git...", greenTextEscOut
        os.system("brew install git")
        print "\n\n"
        print greenTextEscIn, "Installing ruby 2.1...", greenTextEscOut
        os.system("brew install homebrew/versions/ruby21")
        print "\n\n"
        print greenTextEscIn, "Installing nmap... (Prerequisite for metasploit)", greenTextEscOut
        os.system("brew install nmap")
        print "\n\n"
        print greenTextEscIn, "Fetching latest version of metasploit from GitHub...", greenTextEscOut
        os.system("git clone https://github.com/rapid7/metasploit-framework -v")
        print "\n\n"
        os.system("cd metasploit-framework")
        print greenTextEscIn, "Getting bundler and installing proper ruby gems...", greenTextEscOut
        os.system("sudo gem install bundler")
        os.system("bundle install")

        tempInput = input()
        print "Would you like to set up a database? (y/n)", tempInput
        if tempInput == "y":
            print greenTextEscIn, "Getting and setting up postgres...", greenTextEscOut
            os.system("brew install postgres --without-ossp-uuid")
            os.system("initdb /usr/local/var/postgres")
            os.system("mkdir -p ~/Library/LaunchAgents")
            os.system("cp /usr/local/Cellar/postgresql/9.4.4/homebrew.mxcl.postgresql.plist "
                      "~/Library/LaunchAgents/")
            os.system("launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl."
                      "postgresql.plist")
            os.system("createuser msf -P -h localhost")  # creates db user
            os.system("createdb -O msf msf -h localhost")
            dbSetup()
        else:
            print endingText

else:
    print("This script only supports macOS :(")
    exit()
