#!/bin/bash

# Логотип
echo -e '\e[40m\e[32m'
echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
echo -e '\e[0m'

echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"

function show_menu {
  echo "1. Установить ноду Side Protocol"
  echo "2. Проверить синхронизацию Side Protocol"
  echo "3. Создать кошелек Side Protocol"
  echo "4. Импортировать уже существующий кошелек Side Protocol"
  echo "5. Создать валидатора Side Protocol"
  echo "6. Просмотреть логи ноды Side Protocol"
  echo "7. Проверить баланс кошелька"
  echo "8. Выйти из установочного скрипта"
  read -p "Выберите опцию: " option
  case $option in
    1) install_node ;;
    2) check_sync ;;
    3) create_wallet ;;
    4) import_wallet ;;
    5) create_validator ;;
    6) view_logs ;;
    7) check_balance ;;
    8) exit 0 ;;
    *) echo "Неверный выбор, попробуйте снова" && show_menu ;;
  esac
}

function install_node {
  source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/common.sh)
  
  printLogo

  read -p "Введите имя КОШЕЛЬКА: " WALLET
  echo 'export WALLET='$WALLET
  read -p "Введите ваш Моникер: " MONIKER
  echo 'export MONIKER='$MONIKER
  read -p "Введите ваш Порт (например 17, по умолчанию 26): " PORT
  echo 'export PORT='$PORT

  echo "export WALLET="$WALLET"" >> $HOME/.bash_profile
  echo "export MONIKER="$MONIKER"" >> $HOME/.bash_profile
  echo "export SIDE_CHAIN_ID="S2-testnet-2"" >> $HOME/.bash_profile
  echo "export SIDE_PORT="$PORT"" >> $HOME/.bash_profile
  source $HOME/.bash_profile

  printLine
  echo -e "Моникер:        \e[1m\e[32m$MONIKER\e[0m"
  echo -e "Кошелек:        \e[1m\e[32m$WALLET\e[0m"
  echo -e "Chain id:       \e[1m\e[32m$SIDE_CHAIN_ID\e[0m"
  echo -e "Порт ноды:  \e[1m\e[32m$SIDE_PORT\e[0m"
  printLine
  sleep 1

  printGreen "1. Устанавливаем Go..." && sleep 1
  cd $HOME
  VER="1.21.3"
  wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
  rm "go$VER.linux-amd64.tar.gz"
  [ ! -f ~/.bash_profile ] && touch ~/.bash_profile
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
  source $HOME/.bash_profile
  [ ! -d ~/go/bin ] && mkdir -p ~/go/bin

  echo $(go version) && sleep 1

  source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/dependencies_install)

  printGreen "4. Устанавливаем бинарный файл..." && sleep 1
  cd $HOME
  rm -rf side
  git clone https://github.com/sideprotocol/side.git
  cd side
  git checkout v0.8.1
  make install

  printGreen "5. Конфигурируем и инициализируем приложение..." && sleep 1
  sided config node tcp://localhost:${SIDE_PORT}657
  sided config keyring-backend os
  sided config chain-id S2-testnet-2
  sided init $MONIKER --chain-id S2-testnet-2
  sleep 1
  echo done

  printGreen "6. Скачиваем genesis и addrbook..." && sleep 1
  wget -O $HOME/.side/config/genesis.json https://testnet-files.itrocket.net/side/genesis.json
  wget -O $HOME/.side/config/addrbook.json https://testnet-files.itrocket.net/side/addrbook.json
  sleep 1
  echo done

  printGreen "7. Добавляем seeds, peers, конфигурируем порты, pruning, минимальную цену газа..." && sleep 1
  SEEDS="9c14080752bdfa33f4624f83cd155e2d3976e303@side-testnet-seed.itrocket.net:45656"
  PEERS="bbbf623474e377664673bde3256fc35a36ba0df1@side-testnet-peer.itrocket.net:45656"
  sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.side/config/config.toml

  sed -i.bak -e "s%:1317%:${SIDE_PORT}317%g;
  s%:8080%:${SIDE_PORT}080%g;
  s%:9090%:${SIDE_PORT}090%g;
  s%:9091%:${SIDE_PORT}091%g;
  s%:8545%:${SIDE_PORT}545%g;
  s%:8546%:${SIDE_PORT}546%g;
  s%:6065%:${SIDE_PORT}065%g" $HOME/.side/config/app.toml

  sed -i.bak -e "s%:26658%:${SIDE_PORT}658%g;
  s%:26657%:${SIDE_PORT}657%g;
  s%:6060%:${SIDE_PORT}060%g;
  s%:26656%:${SIDE_PORT}656%g;
  s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${SIDE_PORT}656\"%;
  s%:26660%:${SIDE_PORT}660%g" $HOME/.side/config/config.toml

  sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.side/config/app.toml
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.side/config/app.toml
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.side/config/app.toml

  sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.005uside"|g' $HOME/.side/config/app.toml
  sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.side/config/config.toml
  sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.side/config/config.toml
  sleep 1
  echo done

  sudo tee /etc/systemd/system/sided.service > /dev/null <<EOF
  [Unit]
  Description=side node
  After=network-online.target
  [Service]
  User=$USER
  WorkingDirectory=$HOME/.side
  ExecStart=$(which sided) start --home $HOME/.side
  Restart=on-failure
  RestartSec=5
  LimitNOFILE=65535
  [Install]
  WantedBy=multi-user.target
  EOF

  printGreen "8. Скачиваем снапшот и запускаем ноду..." && sleep 1
  sided tendermint unsafe-reset-all --home $HOME/.side
  if curl -s --head curl https://testnet-files.itrocket.net/side/snap_side.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
    curl https://testnet-files.itrocket.net/side/snap_side.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.side
  else
    echo "нет снапшота"
  fi

  sudo systemctl daemon-reload
  sudo systemctl enable sided
  sudo systemctl restart sided
  show_menu
}

function check_sync {
  sided status 2>&1 | jq
  show_menu
}

function create_wallet {
  read -p "Введите имя КОШЕЛЬКА: " WALLET
  sided keys add $WALLET
  WALLET_ADDRESS=$(sided keys show $WALLET -a)
  VALOPER_ADDRESS=$(sided keys show $WALLET --bech val -a)
  echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
  echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
  source $HOME/.bash_profile
  show_menu
}

function import_wallet {
  read -p "Введите имя КОШЕЛЬКА: " WALLET
  sided keys add $WALLET --recover
  WALLET_ADDRESS=$(sided keys show $WALLET -a)
  VALOPER_ADDRESS=$(sided keys show $WALLET --bech val -a)
  echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
  echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
  source $HOME/.bash_profile
  show_menu
}

function create_validator {
  read -p "Ранее Вы уже создавали ноду Side? [да/нет]: " response
  if [[ "$response" =~ ^([дД][аА])$ ]]; then
    sided tx staking create-validator \
    --amount 1000000uside \
    --from $WALLET \
    --commission-rate 0.1 \
    --commission-max-rate 0.2 \
    --commission-max-change-rate 0.01 \
    --min-self-delegation 1 \
    --pubkey $(sided tendermint show-validator) \
    --moniker "$MONIKER" \
    --identity "" \
    --details "" \
    --chain-id S2-testnet-2 \
    --gas auto --fees 1000uside \
    -y
  else
    sided tx staking edit-validator \
    --commission-rate 0.1 \
    --new-moniker "$MONIKER" \
    --identity "" \
    --details "SideProtocol" \
    --from $WALLET \
    --chain-id S2-testnet-2 \
    --gas auto --fees 1000uside \
    -y
  fi
  show_menu
}

function view_logs {
  echo "Через 15 секунд начнется отображение логов ноды Side Protocol. Для возвращения в меню нажмите CTRL+C"
  sleep 15
  sudo journalctl -u sided -f
  show_menu
}

function check_balance {
  sided q bank balances $WALLET_ADDRESS
  show_menu
}

show_menu
