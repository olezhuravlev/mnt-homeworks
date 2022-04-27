#!/bin/bash

up() {
  docker-compose up -d
}

stop() {
  docker-compose stop
}

down() {
  docker-compose down
}

ps() {
  docker-compose ps
}

play() {
  ansible-playbook -i $1 $2
}

play_pass() {
  ansible-playbook -i $1 $2 --ask-vault-pass
}

help() {
	printf "Available commands:\nup:\nstop:\ndown:\nps\nplay [INVENTORY_FILE] [PLAYBOOK_FILE]:\nplay_pass [INVENTORY_FILE] [PLAYBOOK_FILE]:\n"
}

case $1 in
	up) up; exit;;
	stop) stop; exit;;
	down) down; exit;;
	ps) ps; exit;;
	play) play $2 $3; exit;;
	play_pass) play_pass $2 $3; exit;;
	help) help; exit;;
	*) echo "Unknown command '$1'! Type 'help'";;
esac
