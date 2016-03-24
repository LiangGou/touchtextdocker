FROM ubuntu:14.04

MAINTAINER Liang Gou <lgou.psu@gmail.com>

#---------------------------------------------------------
# Install NodeJS, NPM & Git
#---------------------------------------------------------

# make sure apt is up to date
RUN apt-get update

RUN apt-get -y install curl  

# install nodejs and npm
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get install -y nodejs 
RUN apt-get install -y git git-core

#---------------------------------------------------------
#            Install & Conf postgre db
# example Dockerfile for https://docs.docker.com/examples/postgresql_service/
#---------------------------------------------------------

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.3
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``touchtext`` with ``touchtext`` as the password and
# then create a database `touchtext` owned by the ``touchtext`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER touchtext WITH SUPERUSER PASSWORD 'touchtext';" &&\
    createdb -O touchtext touchtext

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  password" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER root

# Set the default command to run when starting the container

# CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]

#RUN service postgresql restart

#--------------------------------------------
# install strongloop
#--------------------------------------------
RUN npm install -g strongloop

#--------------------------------------------
# setup dir
#--------------------------------------------

RUN cd /usr/src && mkdir app

WORKDIR /usr/src/app

#--------------------------------------------
# Get back-end API codes
#--------------------------------------------
	
RUN	git clone git@github.rtp.raleigh.ibm.com:systemt-tooling-research-project/touchtext-backend.git



