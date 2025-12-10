FROM php:8.3-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libicu-dev \
    libpq-dev \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensões PHP necessárias
RUN docker-php-ext-install \
    pdo_pgsql \
    mbstring \
    intl \
    pcntl \
    opcache

# Instalar extensão Redis
RUN pecl install redis && docker-php-ext-enable redis

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Definir diretório de trabalho
WORKDIR /var/www

# Copiar arquivos do projeto
COPY src/ /var/www/

# Instalar dependências do Composer (incluindo dev dependencies para desenvolvimento)
RUN composer install --no-interaction --prefer-dist \
    && composer dump-autoload

# Copiar e configurar script de entrada
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copiar configuração customizada do PHP-FPM
COPY docker/php-fpm-custom.conf /usr/local/etc/php-fpm.d/zzz-custom.conf

# Copiar e habilitar configuração do OPcache para DESENVOLVIMENTO
# (validação de timestamps ativada para detectar mudanças no código)
COPY docker/php-opcache-dev.ini /usr/local/etc/php/conf.d/opcache.ini

# --- INÍCIO DO TRECHO OBRIGATÓRIO ---
# Criar usuário sem privilégios para rodar o Laravel
RUN addgroup --system laravel \
&& adduser --system --ingroup laravel laravel

# Ajustar permissões necessárias do Laravel
RUN mkdir -p /var/www/storage/logs /var/www/bootstrap/cache \
&& touch /var/www/storage/logs/php-fpm.log \
&& chown -R laravel:laravel /var/www/storage /var/www/bootstrap/cache

# Não definir USER aqui - o entrypoint vai gerenciar a mudança de usuário
# --- FIM DO TRECHO OBRIGATÓRIO ---

# Expor porta do PHP-FPM
EXPOSE 9000

# Usar entrypoint (vai rodar como root primeiro, depois muda para laravel)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]

