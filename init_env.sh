#!/bin/sh

# Script per la gestione delle varibaili d'ambiente: le salva nel file ".env" e tiene traccia dello storico
# nella directory ".env.history/".
# Se eseguito senza argomenti, crea le varibaili d'ambiente per l'ambiente in produzione.
# Se invece è specificato come primo argomento la stringa "dev", crea le variabili d'ambiente per l'ambiente di sviluppo.

INPUT=$1

# Creo la directory dell'history se non esiste. Se esiste non fa niente
DIR_HISTORY_ENV=.env.history/
mkdir -p $DIR_HISTORY_ENV

# Creo il file .env se non esiste. Se esiste non fa niente.
FILE_ENV=.env
touch $FILE_ENV

# Mi salvo il contenuto del .env : se è vuoto è come avere una stringa vuota.
# Dopo lo elimino perchè ogni volta che lo script è lanciato ne creo uno nuovo con le eventuali nuove variabili.
CONTENT_FILE_ENV="$(cat $FILE_ENV)"
rm -f $FILE_ENV

# Questo script gestisce le variabili di ambiente e ci sono 2 situazioni:
#   - ALL' INIZIO: non esiste il file .env e lanciando lo script lo popola con le variabili specificate
#   - QUANDO MODIFICO:
#       - Se modifico una variabile nello script che esiste già nel file .env
#           --> di default non vedo variazioni nel file .env
#           --> devo specificare UPDATE per poterle vedere
#           --> Perchè? Così ad es. non genero una pwd nuova ogni volta che eseguo lo script
#                       (se ne voglio generare una nuova basta aggiungere UPDATE)
#       - Se aggiungo o elimino variabili nello script, vedo queste aggiunte / rimozioni di default nel .env
#
# Dettagli Regex:
#   -) echo ha bisogno degli "" perchè così mette una riga sotto all'altra se no tutto su una riga
#   -) .* perchè il match è riga per riga (non devo controllare newline)
#   -) cut -c 2- per eliminare il primo carattere ("=")
add_var(){
  NAME=$1
  VALUE=$2
  MODE=${3:-NOT_UPDATE}

  if [ "$MODE" = "NOT_UPDATE" ]; then
    if [[ $CONTENT_FILE_ENV =~ $NAME"=" ]]; then
      VALUE=$(echo "$CONTENT_FILE_ENV" | grep -o "$NAME=.*" | grep -o "=.*" | cut -c 2-) # prendo il valore esistente
    fi
  fi

  echo $NAME"="$VALUE >> $FILE_ENV
}

# Se il file .env appena creato è diverso dal file più recente presente nell'history, allora faccio una copia
# del mio .env nell'history specificando nel nome la data e l'orario di creazione.
# Come trovo il file più recente nell'history (ls):
#   -) se ci sono problemi reindirizzo in dev/null
#   -) -1 per selezionare il nome del file
#   -) -t per riordinarli in ordine di tempo
#   -) $FILE_ENV* seleziono solo i file che iniziano con .env
#
# Se "LAST_IN_HISTORY" è vuoto (non c'è ancora niente nell' history) allora cmp --silent ritorna false e quindi
# vado a scrivere nell'history
update_history(){
  cd $DIR_HISTORY_ENV

  LAST_IN_HISTORY=$(ls -1 -t $FILE_ENV* 2> /dev/null | head -1)

  if ! cmp --silent -- "../$FILE_ENV" "$LAST_IN_HISTORY"; then
    echo "Env variable changed! History has been updated."
    cp ../$FILE_ENV $FILE_ENV.$(date | tr " " -)
  fi

  cd ../
}


######################## Definisco variabili di ambiente #########################

# dev e prod
add_var SECRET_KEY $(echo $RANDOM | md5sum | head -c 25; echo;)

# solo dev
if [ "$INPUT" = "dev" ]; then
  add_var DJANGO_SETTINGS_MODULE django_project.settings UPDATE
  add_var DEBUG True UPDATE

# solo prod
else
  add_var DJANGO_SETTINGS_MODULE django_project.production_settings UPDATE
  add_var DEBUG False UPDATE

  add_var MARIADB_ROOT_PASSWORD $(echo $RANDOM | md5sum | head -c 25; echo;)
  add_var MARIADB_PASSWORD $(echo $RANDOM | md5sum | head -c 25; echo;)
  add_var MARIADB_DATABASE DB_Progetto_cloud
  add_var MARIADB_USER DB_User
  add_var MARIADB_HOST db
  add_var MARIADB_PORT 3306

fi

# aggiorno la history (se necessario)
update_history