#! /bin/bash

# BiblePay (https://www.biblepay.org/)
# Script compiled using this guide (https://www.reddit.com/r/BiblePay/comments/6ummuj/how_to_mine_biblepay_on_linux/)

# Before running this script, create an account and a worker name here (pool.biblepay.org)

## Usage
# 1) Download this script and go to the downloaded directory
# 2) sudo chmod +x install_biblepay.sh
# 3) ./install_biblepay.sh {number of mining threads} {pool worker name}
#    Eg: ./install_biblepay.sh 8 workername 

echo "Installing BiblePay"
echo Y | sudo apt-get install software-properties-common
echo | sudo add-apt-repository ppa:bitcoin/bitcoin

sudo apt-get update &&
echo Y | sudo apt-get install -y libdb4.8-dev libdb4.8++-dev automake bsdmainutils

echo Y | sudo apt-get update && sudo apt-get install g++ git make build-essential autoconf libtool pkg-config libboost-all-dev libssl-dev libevent-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler htop

cd ~
git clone https://github.com/biblepay/biblepay

BP_ROOT=$(pwd)
BDB_PREFIX="${BP_ROOT}/db4"
mkdir -p $BDB_PREFIX

wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix
../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
make install

cd $BP_ROOT
cd biblepay
sudo chmod 777 share/genbuild.sh
sudo chmod 777 autogen.sh

./autogen.sh
./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/"
sudo make -j4

cd src
./biblepayd -daemon 

echo -e "addnode=node.biblepay.org\naddnode=biblepay.inspect.network\ngen=1\ngenproclimit=$1\npoolport=80\npool=http://pool.biblepay.org\nworkerid=$2" > ~/.biblepaycore/biblepay.conf

sleep 5m
./biblepay-cli getinfo
sleep 10
./biblepay-cli stop
sleep 30
./biblepayd -daemon
sleep 60
./biblepay-cli getmininginfo

echo "Installation done! Started mining on pool"

## If you find this script useful, consider donating to the official orphan foundation
# Biblepay: BB2BwSbDCqCqNsfc7FgWFJn4sRgnUt4tsM (http://biblepay.inspect.network/address/BB2BwSbDCqCqNsfc7FgWFJn4sRgnUt4tsM)