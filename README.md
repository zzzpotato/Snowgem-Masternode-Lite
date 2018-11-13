# Snowgem-Masternode-Lite
Bash script for easily installing a masternode on a linux vps

Note: This script is a beta and has only been tested on ubuntu 16.04. Report any bugs and I will do my best to fix them.

## Create a sudo user so you are not running as root
Replace username with an actual username such as "node"
```
adduser username
usermod -aG sudo username
su username
cd ~
```

## Run the script
```
bash -c "$(wget -O - https://raw.githubusercontent.com/zzzpotato/Snowgem-Masternode-Lite/master/setup.sh)"
```

## Thanks

If you need assistance or find an issue within the script, contact me on discord at potato#4515 and I will try to help you resolve it. Consider checking out my SnowGem pool at https://snowgem.voidr.net/
