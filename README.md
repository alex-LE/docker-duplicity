# docker-duplicity

Basic docker image for running duplicity to copy the contents of the volume out to DreamObjects, (Dreamhost s3 clone)

## Required Environment

  * ACCESS_KEY - set this to the s3 accesskey
  * SECRET_KEY - The secret key
  * PASSPHRASE - Passphrase for encrypting the backups

## Hostname Caveat

  Duplicity uses the hostname in part of it's verification process, and by default docker will give each new instance of a container a different hostname. If you intend the containers to sync to the same folder they need the --allow-mismatch option or if there is only one container then you can use the -h option to docker run to set the hostname to something static.

