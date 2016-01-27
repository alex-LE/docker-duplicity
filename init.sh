#!/bin/bash

# un-official strict mode
set -euo pipefail

export INTERVAL_PERIOD=${INTERVAL_PERIOD:-43200} # 12 hours
export QUIET_PERIOD=${QUIET_PERIOD:-30}
export BACKUP_PATH=${BACKUP_PATH:-/backups}
export REMOTE_PATH=${REMOTE_PATH:-/backups/$HOSTNAME}

if [[ ${PASSPHRASE} = "fill_in" || ${ACCESS_KEY} = "fill_in" || ${SECRET_KEY} = "fill_in" ]] ; then
  echo "PASSPHRASE, ACCESS_KEY, and SECRET_KEY environment variables MUST be set"
  exit 1
else
  echo "access_key = $ACCESS_KEY" >> /root/.s3cfg
  echo "secret_key = $SECRET_KEY" >> /root/.s3cfg
  echo "aws_access_key_id = $ACCESS_KEY" >> /root/.boto
  echo "aws_secret_access_key = $SECRET_KEY" >> /root/.boto
fi

if [[ "$1" == backup* ]]; then
  /usr/bin/duplicity --full-if-older-than 1W --rsync-options='--partial-dir=.rsync-partial' --gpg-options='--compress-algo=bzip2 --bzip2-compress-level=9' --asynchronous-upload $BACKUP_PATH s3://objects.dreamhost.com/$REMOTE_PATH &> /dev/stdout
  # Remove old backups
  /usr/bin/duplicity remove-all-but-n-full 4 --force s3://objects.dreamhost.com/$REMOTE_PATH &> /dev/stdout
  inotifywait_events="modify,attrib,move,create,delete"
  echo "watching for changes..."
  while inotifywait -r -t $INTERVAL_PERIOD -e $inotifywait_events $BACKUP_PATH ; do
    echo "Change detected..."
    while inotifywait -r -t $QUIET_PERIOD -e $inotifywait_events $BACKUP_PATH ; do
      echo "waiting for quiet period..."
    done

    echo "starting backup..."
    /usr/bin/duplicity --full-if-older-than 1W --rsync-options='--partial-dir=.rsync-partial' --gpg-options='--compress-algo=bzip2 --bzip2-compress-level=9' --asynchronous-upload $BACKUP_PATH s3://objects.dreamhost.com/$REMOTE_PATH &> /dev/stdout
    # Remove old backups
    /usr/bin/duplicity remove-all-but-n-full 4 --force s3://objects.dreamhost.com/$REMOTE_PATH &> /dev/stdout
    echo "backup complete."
  done
else
  exec $@
fi
