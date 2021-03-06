#!/bin/bash

### Check user
if [ "$EUID" -eq 0 ]
  then
        echo -e "Warning: You should not run this as root! Create a new user with sudo permissions!\nThis can be done with (replace username with an actual username such as node):\nadduser username\nusermod -aG sudo username\nsu username\ncd ~\n\nYou will be in a new home directory. Make sure you redownload the script or move it from your /root directory!"
        exit
fi

###Begin
clear
read -n1 -r -p "The official guide can be found at https://www.youtube.com/watch?v=yjD3nXmmerU which contains a video of the following steps... Press any key to continue...";echo
read -n1 -r -p "Before you begin, make sure you have already sent your collateral to an address and waited for 15 confirmations! Press any key to continue...";echo
read -n1 -r -p "Go to Masternode tab and click on the \"Generate Masternode Data\" button. Press any key to continue...";echo
read -n1 -r -p "Fill out the information in Setup Masternode using the New Masternode Data shown along with your alias name and VPS IP. Press any key to continue...";echo
read -n1 -r -p "Confirm restarting the wallet. Press any key to continue...";echo


read -n1 -r -p "Let's begin setting up the VPS... Press any key to continue...";echo

### Pre
sudo apt-get update
sudo apt-get -y install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget bsdmainutils automake curl

### Fetch Params
bash -c "$(wget -O - https://raw.githubusercontent.com/Snowgem/Snowgem/master/zcutil/fetch-params.sh)"

### Fetch Daemon
wget --no-check-certificate --content-disposition https://github.com/Snowgem/Snowgem/releases/download/3000452-20190520/snowgem-ubuntu16.04-3000452-20190520.zip
unzip snowgem-ubuntu16.04-3000452-20190520.zip

### Fetch Chain
wget -N https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part1 -O ~/bc.sf-part1
wget -N https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part2 -O ~/bc.sf-part2
wget -N https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part3 -O ~/bc.sf-part3
wget -N https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part4 -O ~/bc.sf-part4
git clone https://github.com/Snowgem/Data ~/data
cd ~/data
npm install
cd ~
nodejs ~/data/joinfile.js
rm ~/bc.sf-part1
rm ~/bc.sf-part2
rm ~/bc.sf-part3
rm ~/bc.sf-part4
unzip -o ~/blockchain.zip -d ~/.snowgem
rm ~/blockchain.zip

### Setup Swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

### Snowgem Config

if [ ! -e ~/.snowgem/snowgem.conf ];
then
        echo -e "#In Modern Wallet, go to the masternodes list and check the box to the left of your new MN. Then go to Actions > Copy Config.\n#Paste your snowgem.conf data at the bottom of this file.\n#If the paste does not correctly format, be sure to change everything to be on its own line in this file.\n#To save, use combo Ctr + X, then type y then Enter.\n\n" >> ~/.snowgem/snowgem.conf
fi
nano ~/.snowgem/snowgem.conf

if [ -e ~/.snowgem/snowgem.conf ];
then
        echo -e "#Do not modify. These will help with getting more connections for the blockchain.\nport=16113\naddnode=45.76.111.3\naddnode=45.76.137.106\naddnode=45.32.79.163\naddnode=207.246.67.167\naddnode=45.77.70.230\naddnode=45.77.160.169\naddnode=104.238.149.197\naddnode=207.148.68.108\naddnode=104.24.117.245\naddnode=142.44.214.53\naddnode=158.69.253.17\naddnode=104.24.123.22\naddnode=104.25.244.104\naddnode=46.252.42.43\naddnode=46.254.16.114\naddnode=24.129.114.44\naddnode=108.249.146.109\naddnode=81.29.192.216\naddnode=46.254.16.114" >> ~/.snowgem/snowgem.conf
fi

### Masternode Config

if [ ! -e ~/.snowgem/masternode.conf ];
then
        echo -e "#In Modern Wallet, go to the masternodes list and check the box to the elft of your new MN. Then go to Actions > Copy Alias.\n#Paste your alias data at the bottom of this file.\n#To save, use combo Ctr + X, then type y then Enter.\n\n" >> ~/.snowgem/masternode.conf
fi
nano ~/.snowgem/masternode.conf

### Start
~/snowgemd --daemon
sleep 60

#Set Vars
highestblock="$(wget -nv -qO - https://explorer.snowgem.org/api/getblockcount)"
currentblock="$(~/snowgem-cli getblockcount)"

while  [ "$highestblock" != "$currentblock" ]
do
        clear
        highestblock="$(wget -nv -qO - https://explorer.snowgem.org/api/getblockcount)"
        currentblock="$(~/snowgem-cli getblockcount)"
        echo "Comparing block heights to ensure server is fully synced";
        echo "Highest: $highestblock";echo "Currently at: $currentblock";
        echo "Checking again in 60 seconds... The install will continue once it's synced.";echo
        echo "Last 20 lines of the log for error checking...";
        echo "===============";
        tail -10 ~/.snowgem/debug.log
        echo "===============";
        echo "Network unreachable errors can be normal. Just ensure the current block height is rising over time...";
        sleep 60
done

### Debug
~/snowgem-cli masternodedebug
read -n1 -r -p "In your local wallet, select your Masternode and then go to Actions > Start... Wait a few minutes and press any key to continue";echo
~/snowgem-cli masternodedebug
read -n1 -r -p "If the response is: “Masternode successfully started“, you’re finished.... Press any key to finish";echo

### Cleanup
read -r -p "Do you you want to clean up? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        rm -fv blockchain_index.zip snowgem-linux-2000458-20181006.zip
fi
