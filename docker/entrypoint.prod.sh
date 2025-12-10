#!/bin/bash
set -e

echo "🚀 Iniciando aplicação em modo PRODUÇÃO..."

# Aguardar o PostgreSQL estar pronto
echo "⏳ Aguardando PostgreSQL ficar disponível..."
until php artisan db:show &> /dev/null || php -r "try { \$pdo = new PDO('pgsql:host=postgres;port=5432;dbname='.getenv('DB_DATABASE'), getenv('DB_USERNAME'), getenv('DB_PASSWORD')); echo 'OK'; } catch (Exception \$e) { exit(1); }" 2>/dev/null; do
    echo "Aguardando PostgreSQL..."
    sleep 2
done

echo "✅ PostgreSQL está pronto!"

# Verificar se APP_KEY existe
if ! grep -q "^APP_KEY=base64:" /var/www/.env 2>/dev/null; then
    echo "❌ ERRO: APP_KEY não encontrada! Configure no .env antes de iniciar."
    exit 1
fi

# Rodar migrations (apenas se necessário - não força)
echo "📦 Verificando migrations..."
php artisan migrate --force || {
    echo "⚠️  Aviso: Erro ao rodar migrations"
}

# Garantir permissões corretas
echo "🔒 Ajustando permissões..."
# Ensure views directory exists (needed for email compilation, even in API-only) // EN
# Garantir que o diretório de views existe (necessário para compilar e-mails, mesmo em API-only) // PT-BR
mkdir -p /var/www/storage/framework/views
chown -R laravel:laravel /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Otimizações de produção
echo "⚡ Otimizando Laravel para produção..."

# Limpar caches antigos
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Recriar caches otimizados
php artisan config:cache
php artisan route:cache
php artisan view:cache || true
php artisan event:cache || true

# Otimizar autoloader
composer dump-autoload --optimize --classmap-authoritative --no-dev

echo "✅ Aplicação otimizada e pronta para produção!"

# Executar PHP-FPM
echo "🚀 Iniciando PHP-FPM..."
exec "$@"

