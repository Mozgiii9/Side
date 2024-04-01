#!/bin/bash

while true
do

# Logo



███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
                                                                                        



echo -e '\e[40m\e[92m'
echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗'
echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export SIDE_CHAIN_ID=side-testnet-3" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# install go
if ! [ -x "$(command -v go)" ]; then
ver="1.21.3" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
fi

# download binary
cd && rm -rf sidechain
git clone https://github.com/sideprotocol/sidechain.git
cd sidechain
git checkout v0.7.0-rc2
make install

# config
sided config chain-id $SIDE_CHAIN_ID
sided config keyring-backend test

# init
sided init $NODENAME --chain-id $SIDE_CHAIN_ID

# download genesis and addrbook
curl -L https://snapshots-testnet.nodejumper.io/side-testnet/genesis.json > $HOME/.side/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/side-testnet/addrbook.json > $HOME/.side/config/addrbook.json

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.005uside\"|" $HOME/.side/config/app.toml

# set peers and seeds
SEEDS="6decdc5565bf5232cdf5597a7784bfe828c32277@158.220.126.137:11656,e9ee4fb923d5aab89207df36ce660ff1b882fc72@136.243.33.177:21656,9c14080752bdfa33f4624f83cd155e2d3976e303@side-testnet-seed.itrocket.net:45656"
PEERS="ea6cc33fe12acd75f42b1b9b4aafb0bde6911d41@176.9.139.150:26656,e9ee4fb923d5aab89207df36ce660ff1b882fc72@136.243.33.177:21656,2a6d31c23160e49db1f03a884dc7b9602fffe895@176.9.126.85:30004,e52da5e5fecf65abf9d7a3135196240f065deed3@207.180.212.200:26656,dcb4494c545f450ba38d60cfcba6c92dc55ebef2@80.85.242.149:34656,90913388e45b45b2838db389f780d8b5add90aa4@65.109.23.55:21306,53e164d1b28ba845da0cec828b4f69fe1e8bf78a@65.108.153.66:26656,00170c0c23c3e97c740680a7f881511faf68289a@202.182.119.24:26656,860604d5cfd972a892b2defe50ae5ef1cec49f1e@78.46.103.246:26656,64311e24f75b6fb43b85042e6350bc53366cf218@144.76.111.38:46656,69b93c5cbfc23c018662b7dadca3a9ea4509b01e@95.217.87.81:46656,501081929e6e676229da5d67415a1a2094b88f75@65.109.101.254:26656,7c55344ddca1b3d8f3afbaf6c5976f96c5b4a0d2@135.181.138.178:46656,9ae9fe5f81d2ae0c9fed8cc51c892330f8cf154b@213.199.39.207:11656,623a1ead3eeb2e4171e013959192aa9808626986@213.199.61.251:26656,5baf6e065f8a0cc2cbe78e838fa5dc54be3eb70d@65.109.92.163:1020,4a02056469cdfd852fe736719b56ae22e84d729e@95.217.200.98:26656,996c8e0d0c331c19984c543f6a3ec8520131fb7e@95.164.3.79:34656,ba06a50cb8a80da31cadf1f148607304437c3005@139.59.100.143:26656,85cfebdb59615a1bf427106a32b30c91568fd52a@135.181.216.54:3450"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.side/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.side/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.side/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.side/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.side/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.side/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.side/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.side/config/config.toml

# create service
sudo tee /etc/systemd/system/sided.service > /dev/null << EOF
[Unit]
Description=Side node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which sided) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
sided tendermint unsafe-reset-all --home $HOME/.side --keep-addr-book
curl https://snapshots-testnet.nodejumper.io/side-testnet/side-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.side

# start service
sudo systemctl daemon-reload
sudo systemctl enable sided
sudo systemctl restart sided

break
;;

"Create Wallet")
sided keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
SIDE_WALLET_ADDRESS=$(sided keys show $WALLET -a)
SIDE_VALOPER_ADDRESS=$(sided keys show $WALLET --bech val -a)
echo 'export SIDE_WALLET_ADDRESS='${SIDE_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export SIDE_VALOPER_ADDRESS='${SIDE_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
sided tx staking create-validator \
--amount=10000000uside \
--pubkey=$(sided tendermint show-validator) \
--moniker="$NODENAME" \
--chain-id=side-testnet-3 \
--commission-rate=0.1 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.05 \
--min-self-delegation=1 \
--from=wallet \
-y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done