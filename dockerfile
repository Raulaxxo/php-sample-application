FROM php:7.1-apache

# Cambiar los repositorios por los archivados (Debian)
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org|http://archive.debian.org/|g' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip \
    && docker-php-ext-install pdo pdo_mysql

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Copiar vhost
COPY config-dev/vhost.conf /etc/apache2/sites-available/000-default.conf

# Copiar código fuente
COPY . /var/www/html

# Instalar composer (versión compatible)
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

# Establecer permisos y trabajar en la raíz del proyecto
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html && composer install

EXPOSE 80
CMD ["apache2-foreground"]


