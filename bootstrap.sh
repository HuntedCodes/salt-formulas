#!/bin/sh


############
# References
############

# https://repo.saltstack.com/#debian
# https://repo.saltstack.com/#ubuntu
# https://docs.saltstack.com/en/latest/ref/configuration/index.html


################
# APT Repository
################

# Add repo key
# Debian: https://repo.saltstack.com/apt/debian/8/amd64/latest/SALTSTACK-GPG-KEY.pub
# Ubuntu: https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub
#wget -O - https://repo.saltstack.com/apt/`lsb_release -si | tr '[:upper:]' '[:lower:]'`/`lsb_release -sr`/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -


# Add repo
# Debian: echo deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/ `lsb_release -sc` main | sudo tee /etc/apt/sources.list.d/saltstack.list
# Ubuntu: echo deb http://repo.saltstack.com/apt/debian/8/amd64/latest/ `lsb_release -sc` main | sudo tee /etc/apt/sources.list.d/saltstack.list
#echo deb http://repo.saltstack.com/apt/`lsb_release -si | tr '[:upper:]' '[:lower:]'`/`lsb_release -sr`/amd64/latest/ `lsb_release -sc` main | sudo tee /etc/apt/sources.list.d/saltstack.list


# Update package listings
sudo apt-get update -y


#############
# File System
#############

# Create directories
sudo mkdir -p /srv/salt
sudo mkdir -p /srv/pillar


######################
# Master Configuration
######################

# Install salt master package
sudo apt-get install -y salt-master

# Change hash type when discovering files on master
sudo sed -i -e 's/^#hash_type: md5/hash_type: sha512/g' /etc/salt/master

# GPG deps for secure secrets.
# https://fabianlee.org/2016/10/18/saltstack-keeping-salt-pillar-data-encrypted-using-gpg/
sudo apt-get install -y python-gnupg rng-tools

# Using `/dev/urandom` is bad, according to Arch Linux.
# Either have a TRNG or use `haveged` if really needed.
# https://wiki.archlinux.org/index.php/Rng-tools
# https://wiki.archlinux.org/index.php/Haveged
# sudo rngd -r /dev/urandom

# Generate passwordless GPG keypair for salt
# If it takes a while, just run a VM to generate entropy. ;)
sudo mkdir -p /etc/salt/gpgkeys
sudo chmod 0700 /etc/salt/gpgkeys
sudo gpg --gen-key --homedir /etc/salt/gpgkeys

# Save the keys
sudo gpg --homedir /etc/salt/gpgkeys --export-secret-keys --armor > \
  /etc/salt/gpgkeys/exported-salt-gpg-private.key
sudo gpg --homedir /etc/salt/gpgkeys --export --armor > \
  /etc/salt/gpgkeys/exported-salt-pubkey.gpg

# Import public key to general key ring.
sudo gpg --import /etc/salt/gpgkeys/exported-salt-pubkey.gpg

# Get Key ID
KEYID=$(sudo gpg --list-keys --homedir /etc/salt/gpgkeys|grep uid|tr -s " "|cut -d' ' -f2)

# Encrypting string secrets to put in pillar files:
# sudo bash -c 'echo -n "supersecret" | gpg --armor --batch --trust-model always --encrypt -r "$KEYID"'

# Encrypting file secrets to put in pillar files:
# sudo bash -c 'cat ssh-private.key | gpg --armor --encrypt -r "$KEYID"'

# Place secret in pillar file.
#
# #!jinja|yaml|gpg
#
# a-secret: |
#   -----BEGIN PGP MESSAGE-----
#   Version: GnuPG

#   hQEMAweRHKaPCfNeAQf9GLTN16hCfXAbPw...
#   QuetdvQVLFO/HkrC4lgeNQdM6D9E8PKonM...
#   cnEfmVexS7o/U1VOVjoyUeliMCJlAz/30R...
#   RhkhC0S22zNxOXQ38TBkmtJcqxnqT6YWKT...
#   m4wBkfCAd8Eyo2jEnWQcM4TcXiF01XPL4z...
#   Gr9v2DTF7HNigIMl4ivMIn9fp+EZurJNiQ...
#   FKlwHiJt5yA8X2dDtfk8/Ph1Jx2TwGS+lG...
#   skqmFTbOiA===Eqsm
#   -----END PGP MESSAGE-----


# Restart the salt master
sudo systemctl restart salt-master.service



######################
# Minion Configuration
######################

# Install salt minion package
sudo apt-get install -y salt-minion

# Have local minion point to local master
sudo sed -i -e 's/^#master: salt/master: localhost/g' /etc/salt/minion

# Restart the salt minion
sudo systemctl restart salt-minion.service


############
# Connection
############

# Wait for the minion key to be sent
sleep 5

# Accept local salt minion key on master
sudo salt-key -y -a `hostname`

