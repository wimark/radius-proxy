# RADIUS proxy

## Описание

Docker ready решение для разворачивания простого прокси RADIUS auth запросов.  
Внутри есть простой скрипт для настройки доступа к конечному радиус серверу, а также простейший менеджмент клиентов.

## Утилита (raddock/radproxy.sh)

Из зависимостей - sudo, sed  
Редактирует clients.conf, а также proxy.conf

```
radproxy cli config utility

available commands:
	help - prints this help
	client_add {alias} {ipaddr} {secret}	- add a client
	client_del {alias}						- delete client with this alias
	proxy_set {ipaddr} {port} {secret} 		- set proxy destination
```

## Запуск
в корневой директории с помощью `docker-compose up -d`

## Теория

В основе всего лежит конфиг `default`:
```
server default {

listen {
    type = auth
    ipaddr = *
    port = 0
}

authorize {
    preprocess
    files
    update control {
        Proxy-to-Realm := "network.example"
    }
    pap
}

}
```

Здесь происходит объявление сервера, который слушает отовсюду и в authorize запросах меняет [realm](https://networkradius.com/doc/current/raddb/mods-available/realm.html) для текущего пользователя на объявленный в proxy.conf прокси realm.

`proxy.conf`:
```
home_server remoteradius1 {
    type = auth
    ipaddr = ipaddr
    port = port
    secret = secret
}

home_server_pool remote_radius_failover {
    type = fail-over
    home_server = remoteradius1
}

realm network.example {
    auth_pool = remote_radius_failover
}
```
Тут realm'у с которым ассоциируются запросы назначается auth_pool - remote_radius_failover, который в свою очередь ссылается на home_server - целевой сервер для проксирования запросов.  
Все конфиги здесь взяты "с википедии", и как видно, тут есть задаток на расширение функционала, то есть в remote_radius_failover по failover логике можно напихать кучу различных home_server'ов, а также локальный фоллбек сервер, чтобы, например, сохранять запросы которые не удалось обработать из-за недоступности home_server'ов, и, через какое-то время попробовать обработать их снова.  

В home_server'e утилитой как раз настраивается целевой ip адрес, порт, и секрет.


### Подмена/добавление аттрибутов

Данная логика так и не была реализована по ненадобности, но в основном все достигается с помощью мощного [Unlang](https://networkradius.com/doc/current/unlang/home.html), что лежит в основе FreeRadius, а именно через директиву [update](https://networkradius.com/doc/current/unlang/update.html).  
Используя возможность выстраивать логику привычными стейтментами можно подменять/добавлять аттрибуты не прибегая к сторонним языковым прослойкам почти в любом кейсе.

## Copyrights

Затюнено [mintyleaf](https://github.com/mintyleaf) в 2021 для Wimark. 