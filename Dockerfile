FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive


# Sources.
RUN \
  echo "deb http://ftp.de.debian.org/debian/ stretch main non-free contrib" > /etc/apt/sources.list && \
  echo "deb-src http://ftp.de.debian.org/debian/ stretch main non-free contrib" >> /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb-src http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
  apt-get -qq update && apt-get -qqy upgrade


# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d


# Tools.
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg \
    mariadb-client \
    nano && \
    rm -rf /var/lib/apt/lists/*


# Apache.
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    apache2 && \
    rm -rf /var/lib/apt/lists/*


# Configure Apache.
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod proxy_fcgi rewrite


# PHP.
RUN curl https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo 'deb https://packages.sury.org/php/ stretch main' > /etc/apt/sources.list.d/deb.sury.org.list

# Install PHP 7.2
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    php7.2 \
    php7.2-cli \
    php7.2-curl \
    php7.2-fpm \
    php7.2-gd \
    php7.2-mbstring \
    php7.2-intl \
    php7.2-mysqlnd \
    php7.2-soap \
    php7.2-zip \
    php7.2-xml && \
    rm -rf /var/lib/apt/lists/*

# Install PHP 7.1
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    php7.1 \
    php7.1-cli \
    php7.1-curl \
    php7.1-fpm \
    php7.1-gd \
    php7.1-mbstring \
    php7.1-mcrypt \
    php7.1-mysqlnd \
    php7.1-soap \
    php7.1-zip \
    php7.1-xml && \
    rm -rf /var/lib/apt/lists/*


# Install PHP 5.6
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    php5.6 \
    php5.6-cli \
    php5.6-curl \
    php5.6-fpm \
    php5.6-gd \
    php5.6-mbstring \
    php5.6-mcrypt \
    php5.6-mysqlnd \
    php5.6-soap \
    php5.6-zip \
    php5.6-xml && \
    rm -rf /var/lib/apt/lists/*


# You can switch the default version using update-alternatives:
# $ update-alternatives --config php
RUN update-alternatives --set php /usr/bin/php7.1


# Composer.
RUN \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require hirak/prestissimo

#SSH
#    RUN apt-get update && apt-get install -y openssh-server
#    RUN mkdir /var/run/sshd
#    RUN echo 'root:root' | chpasswd
#    RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

    # SSH login fix. Otherwise user is kicked off after login
#    RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

 #   ENV NOTVISIBLE "in users profile"
#    RUN echo "export VISIBLE=now" >> /etc/profile

 #   EXPOSE 22
 #   CMD ["/usr/sbin/sshd", "-D"]

# npm
RUN \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    build-essential && \
    rm -rf /var/lib/apt/lists/*
RUN \
    npm i -g gulp && \
    npm i -g npm@next && \
    npm i -g npm-cache-install


# (Docker-specific) install supervisor so we can run everything together
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    supervisor && \
    rm -rf /var/lib/apt/lists/*
COPY supervisor.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /run/php


# Cleanup.
RUN \
    apt-get -q autoclean && \
    rm -rf /var/lib/apt/lists/*


EXPOSE 8871 8856
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
