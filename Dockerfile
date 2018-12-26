# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.2-apache
#commenting the below, to avoid redirection issue
RUN echo "Creating NSE India Drupal Image"

# install the PHP extensions we need
RUN set -ex; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/drupal

ENV DRUPAL_VERSION 8.5.6
#ENV DRUPAL_MD5 1e789adb03cf2a82a9c3bced67c02328 //todo: not correct md5

RUN { \
		echo '<VirtualHost *:80>\n'; \
		echo 'DocumentRoot /var/www/drupal/web\n'; \
		#echo 'ErrorLog $${APACHE_LOG_DIR}/error.log\n'; \
		#echo 'CustomLog $${APACHE_LOG_DIR}/access.log combined\n'; \
        echo '</VirtualHost>\n'; \
    } > /etc/apache2/sites-enabled/000-default.conf

VOLUME /var/www/drupal
RUN apt-get update && apt-get install -y nano
