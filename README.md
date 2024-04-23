![image](https://github.com/Mozgiii9/SideNode/assets/74683169/4344c896-230f-40a9-9028-1c3e2c99e897)

# SideNode

### Дата создания гайда: 03.04.2024

### Дата обновления гайда: 19.04.2024

### Описание проекта:

*Side protocol* - фулл-стек омниканальная биржевая инфраструктура, предлагающая специализированную инфраструктуру, инструменты и приложения для DeFi обмена активами. Они сосредоточены на 4 принципах. Масштабируемость, совместимость, децентрализация и обмен.

Решение, которое они предлагают, предназначено для решения проблем CEX — централизация, DEX — проблема с интеграцией новых токенов, DEX — ограниченный пользовательский опыт по сравнению с CEX. DEX очень требователен к масштабируемости и производительности, в таких случаях газовые сборы очень высоки, что бьет по мелким трейдерам. Вот основные проблемы, которые хочет решить Side Protocol

**Инвестиции:** 

Я могу выделить Эрика Чена, который является CEO Injective. В конце концов, продукт очень похож на Injective и, возможно, будет дополнять/сочетать его. Как сказал CEO Shane, будет закрытый токенсейл на $30M, а эта сумма будет привлекать многих людей в проект.

**Официальные ресурсы:**

- *Веб-сайт:* [перейти](https://side.one/)

- *Ссылка на Medium проекта:* [перейти](https://medium.com/@SideProtocol)

- *Ссылка на Twitter проекта:* [перейти](http://x.com/sideprotocol)

- *Ссылка на Discord проекта:* [перейти](https://discord.gg/sideprotocol)

### Рекомендуемые характеристики сервера: 

- *CPU : 4 CORES;*
- *RAM : 8 GB;*
- *Storage : 200GB SSD;*
- *OS : Ubuntu 20.04 / Ubuntu 22.04*

**Перед установкой ноды необходимо пройти [квесты на Galxe](https://galxe.com/sideprotocol/campaign/GCraxUn3Fj). Делается это для того, чтобы получить доступ к крану, который выдает тестовые токены. Тестовые токены необходимы для корректного запуска и работы ноды.**

**Переходим по [ссылке](https://galxe.com/sideprotocol/campaign/GCraxUn3Fj), выполняем квесты. Привязываем свой Discord, Twitter, Telegram если ранее этого не делали. После успешного прохождения квестов вам станет доступна ветка "#testnet-faucet" в Дискорде Side Protocol.**

**Далее подключаемся к серверу. Делаем обновление пакетов командой:**

```
sudo apt update && sudo apt upgrade -y
```

**Устанавливаем ноду с помощью скрипта:**

```
source <(curl -s https://itrocket.net/api/testnet/side/autoinstall/)
```

**Указываем имя кошелька, имя ноды и оставляем 26 порт. Нода установилась тогда, когда пошли логи. Выходим из режима отображения логов комбинацией клавиш CTRL+C.**

**Далее обновим софт ноды. Выполняйте команды последовательно:**

```
sudo systemctl stop sided
```

```
wget https://github.com/sideprotocol/testnet/raw/main/side-testnet-3/genesis.json -O ~/.side/config/genesis.json
```

```
SEEDS="00170c0c23c3e97c740680a7f881511faf68289a@202.182.119.24:26656,00170c0c23c3e97c740680a7f881511faf68289a@202.182.119.24:26656"
```

```
PEERS="dcb4494c545f450ba38d60cfcba6c92dc55ebef2@80.85.242.149:34656,53e164d1b28ba845da0cec828b4f69fe1e8bf78a@65.108.153.66:26656,e9ee4fb923d5aab89207df36ce660ff1b882fc72@136.243.33.177:21656"
```

```
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.side/config/config.toml
```

```
sided config chain-id side-testnet-3
```

```
cd $HOME
```

```
rm -rf side
```

```
git clone https://github.com/sideprotocol/side.git
```

```
cd side
```

```
git checkout v0.7.0
```

```
make build
```

```
sudo mv $HOME/side/build/sided $(which sided)
```

```
sudo systemctl restart sided && sudo journalctl -u sided -f
```

**Проверим синхронизацию ноды:**

```
sided status 2>&1 | jq .SyncInfo
```

**Пока значение "catching_up" не изменится на "false" не переходите к следующему шагу!**

**Когда нода синхронизировалась, можно переходить к созданию кошелька. Выполните команды последовательно, замените "$WALLET" на имя Вашего кошелька, которое Вы указали при запуске скрипта:**

```
sided keys add $WALLET
```

**Сохраните адрес кошелька а также seed-фразу (mnemonic phrase) в надежное место. Переходим к следующим шагам (Не забудьте заменить "$WALLET" на имя Вашего кошелька:)**

```
WALLET_ADDRESS=$(sided keys show $WALLET -a)
```

```
VALOPER_ADDRESS=$(sided keys show $WALLET --bech val -a)
```

```
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
```

```
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
```

```
source $HOME/.bash_profile
```

**Еще раз проверим статус синхронизации ноды и убедимся, что catching_up равен "false":**

```
sided status 2>&1 | jq .SyncInfo
```

**Переходим в ветку с краном в Дискорде (#testnet-faucet) и запрашиваем токены отправкой сообщения:**

```
$request side-testnet-3 <АДРЕС_КОШЕЛЬКА>
```

**Замените АДРЕС_КОШЕЛЬКА на адрес Вашего кошелька.**

**Для запуска валидатора используйте команду "Create validator":**

```
sided tx staking create-validator \
--amount 1000000uside \
--from $WALLET \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(sided tendermint show-validator) \
--moniker "test" \
--identity "" \
--details "I love blockchain" \
--chain-id side-testnet-3 \
--gas auto --fees 1000uside \
-y
```

**Замените значения:**

*- moniker : Укажите имя Вашей ноды, которое Вы давали ей после запуска Bash-скрипта;*

*- details : Можете указать свое значение или оставить исходное;*

После отправки команды введите пароль от Вашего кошелька. Сервер должен вернуть Вам хэш транзакции (txhash). Переходим в [эксплорер](https://testnet.itrocket.net/side/staking) и вставляем хэш транзакции в поиске. Вы увидете адрес Вашего валидатора, а также статус его работы. Обратите внимание, что валидатор запустится спустя небольшое время.

### Полезные команды

**Проверить синхронизацию:**

```
sided status 2>&1 | jq .SyncInfo
```

**Посмотреть логи:**

```
journalctl -fu sided -o cat
```

**Посмотреть информацию о ноде:**

```
sided status 2>&1 | jq .NodeInfo
```

**Перезагрузить сервис:**

```
sudo systemctl restart sided
```

**Добавить новый кошелек:**

```
sided keys add $WALLET
```

**Восстановить кошелек:**

```
sided keys add $WALLET --recover
```

**Просмотреть список кошельков:**

```
sided keys list
```

**Проверить баланс кошелька:**

```
sided q bank balances $(sided keys show $WALLET -a)
```

**Делегировать токены себе:**

```
sided tx staking delegate $(sided keys show $WALLET --bech val -a) 1000000uside --from $WALLET --chain-id side-testnet-3 --gas auto --fees 1000uside -y
```

**Делегировать токены другому валидатору. Замените <TO_VALOPER_ADDRESS> на адрес валидатора, которому Вы хотите делегировать токены:**

```
sided tx staking delegate <TO_VALOPER_ADDRESS> 1000000uside --from $WALLET --chain-id side-testnet-3 --gas auto --fees 1000uside -y
```

**Информация о тюрьме:**

```
sided q slashing signing-info $(sided tendermint show-validator)
```

**Освободить валидатора из тюрьмы:**

```
sided tx slashing unjail --from $WALLET --chain-id side-testnet-3 --gas auto --fees 1000uside -y
```

### Обязательно проведите собственный ресерч проектов перед тем как ставить ноду. Сообщество NodeRunner не несет ответственность за Ваши действия и средства. Помните, проводя свой ресёрч, Вы учитесь и развиваетесь.

### Связь со мной: [Telegram(@M0zgiii)](https://t.me/m0zgiii)

### Мои соц. сети: [Twitter](https://twitter.com/m0zgiii) 
