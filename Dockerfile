FROM debian:jessie
MAINTAINER John Gedeon <js1@gedeons.com>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&\
    apt-get -y upgrade &&\
    apt-get install -yq --no-install-recommends \
      duplicity inotify-tools \
      python-boto s3cmd

RUN apt-get clean &&\
    rm -rf /tmp/* /var/tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup

USER root
ENV HOME=/root
WORKDIR /root

COPY boto /root/.boto
COPY s3cfg /root/.s3cfg
COPY init.sh /usr/local/bin/init.sh
RUN chmod a+x /usr/local/bin/init.sh

VOLUME /backups
ENV ACCESS_KEY fill_in
ENV SECRET_KEY fill_in
ENV PASSPHRASE fill_in
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["backup"]
