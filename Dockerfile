FROM 207448669309.dkr.ecr.ap-south-1.amazonaws.com/drupal-base-image

RUN rm -rf /var/www/html/* && rm -rf /var/www/html/.htaccess
WORKDIR /var/www/html/
COPY . .

RUN chown www-data:www-data /var/www/html
RUN chown www-data:www-data /var/www/html/modules/ -R && 	chown www-data:www-data /var/www/html/sites/ -R && 	chown www-data:www-data /var/www/html/themes/ -R

