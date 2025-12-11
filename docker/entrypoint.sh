#!/bin/bash
# Não usar set -e para não parar em erros não críticos
set +e

echo "Iniciando entrypoint..."

# Aguardar o PostgreSQL estar pronto
echo "Aguardando PostgreSQL ficar disponível..."
until php artisan db:show &> /dev/null || php -r "try { \$pdo = new PDO('pgsql:host=postgres;port=5432;dbname=app', 'app', 'app'); echo 'OK'; } catch (Exception \$e) { exit(1); }" 2>/dev/null; do
    echo "Aguardando PostgreSQL..."
    sleep 2
done

echo "PostgreSQL está pronto!"

# Garantir que bootstrap/cache existe e tem permissões corretas
mkdir -p /var/www/bootstrap/cache
chmod -R 775 /var/www/bootstrap/cache

# Verificar se vendor existe (necessário para comandos artisan)
if [ ! -d "/var/www/vendor" ]; then
    echo "⚠️ Diretório vendor não encontrado. Instalando dependências..."
    composer install --no-interaction --prefer-dist
fi

# Verificar se APP_KEY existe, se não, gerar
if ! grep -q "^APP_KEY=base64:" /var/www/.env 2>/dev/null; then
    echo "APP_KEY não encontrada. Gerando..."
    php artisan key:generate --force
    echo "APP_KEY gerada com sucesso!"
else
    echo "APP_KEY já existe."
fi

# Rodar migrations automaticamente
echo "Rodando migrations..."
php artisan migrate --force
if [ $? -ne 0 ]; then
    echo "Aviso: Erro ao rodar migrations (pode ser normal se já foram executadas)"
fi

# Garantir que os arquivos de log do PHP-FPM existem e têm permissões corretas
mkdir -p /var/www/storage/logs
touch /var/www/storage/logs/php-fpm.log
touch /var/www/storage/logs/php-fpm-access.log
chown -R laravel:laravel /var/www/storage/logs
chmod -R 775 /var/www/storage/logs

# Garantir que o diretório de views existe e tem permissões corretas
# (necessário para compilar views de e-mail, mesmo em API-only) // EN
# (necessário para compilar views de e-mail, mesmo em API-only) // PT-BR
mkdir -p /var/www/storage/framework/views
chown -R laravel:laravel /var/www/storage/framework
chmod -R 775 /var/www/storage/framework

# Detectar ambiente (dev ou prod)
APP_ENV_VALUE=${APP_ENV:-local}
if [ "$APP_ENV_VALUE" = "local" ] || [ "$APP_ENV_VALUE" = "development" ] || [ "$APP_ENV_VALUE" = "dev" ]; then
    echo "🔧 Ambiente de DESENVOLVIMENTO detectado"
    echo "🧹 Limpando caches para desenvolvimento..."
    php artisan config:clear || true
    php artisan route:clear || true
    php artisan view:clear || true
    echo "✅ Caches limpos - mudanças no código serão detectadas imediatamente"
else
    echo "🚀 Ambiente de PRODUÇÃO detectado"
    echo "⚡ Otimizando Laravel (cache)..."
    php artisan config:cache || echo "Aviso: Erro ao fazer cache de config"
    php artisan route:cache || echo "Aviso: Erro ao fazer cache de rotas"
fi

# Executar o comando original (PHP-FPM vai mudar para laravel automaticamente via config)
echo "Iniciando PHP-FPM (vai rodar como laravel via configuração)..."
exec "$@"

