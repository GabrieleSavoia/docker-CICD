#!/bin/sh

# Script per l'esecuzione dell'applicazione.
# Se il primo argomento è "dev" allora saranno generate le variabili d'ambiente per l'ambiente di development e
# poi è fatto partire il docker compose con le configurazioni di development (senza MariaDB e con il codice settato
# come volume).
# Se invece non si specifica niente verrà settato l'ambiente di produzione: le immagini saranno pullate dal Docker Hub
# e poi il Docker Compose è fatto partire con le configurazioni di deploy.

INPUT=$1
INPUT_2=$2

chmod +x ./init_env.sh

if [ "$INPUT" = "dev" ]; then
  ./init_env.sh dev

  if [ "$INPUT_2" = "build" ]; then
    docker compose -f docker-compose.yml -f docker-compose.dev.yml build
  fi

  docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

else
  ./init_env.sh
  docker compose pull       # come dire: "docker compose -f docker-compose.yml -f docker-compose.override.yml pull"
  docker compose up -d

fi