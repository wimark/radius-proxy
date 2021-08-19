#!/bin/sh

[ "$1" = "help" ] || [ -z $1 ] && \
printf "radproxy cli config utility\n\n\
available commands:\n\
	help - prints this help\n\
	client_add {alias} {ipaddr} {secret}	- add a client\n\
	client_del {alias}			- delete client with this alias\n\
	proxy_set {ipaddr} {port} {secret} 	- set proxy destination\n" && exit 0


[ "$1" = "client_add" ] && \
	[ ! -z $2 ] && [ ! -z $3 ] && [ ! -z $4 ] && \
		printf "adding client: $2 $3 $4\n" && \
		sudo sh -c 'printf "client '$2' {\n\tipaddr = '$3'\n\tsecret = '$4'\n}\n" >> clients.conf' && exit 0

[ "$1" = "client_del" ] && \
	[ ! -z $2 ] && \
		printf "deleting client: $2\n" && \
		sudo sh -c 'sed -i "/client '$2'/,+4d" clients.conf' && exit 0

[ "$1" = "proxy_set" ] && \
	[ ! -z $2 ] && [ ! -z $3 ] && [ ! -z $4 ] && \
		printf "setting radius $2 $3 $4\n" && \
		sudo sh -c 'sed -e "s/{ipaddr}/'$2'/;s/{port}/'$3'/;s/{secret}/'$4'/" proxy.conf.template > proxy.conf' && exit 0


printf "something went wrong\n" && exit 1

