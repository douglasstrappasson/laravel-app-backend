#!/bin/bash
# Script para fazer deploy em produção

set -e

echo "🚀 Preparando deploy para PRODUÇÃO..."

# Verificar se o arquivo .env existe
if [ ! -f "src/.env" ]; then
    echo "❌ ERRO: Arquivo src/.env não encontrado!"
    echo "📝 Copie o arquivo .env.production.example para src/.env e configure:"
    echo "   cp .env.production.example src/.env"
    echo "   # Edite src/.env com suas configurações"
    exit 1
fi

# Verificar se APP_KEY está configurada
if ! grep -q "^APP_KEY=base64:" src/.env; then
    echo "⚠️  AVISO: APP_KEY não encontrada no .env"
    echo "🔑 Gerando APP_KEY..."
    docker compose -f docker-compose.prod.yml run --rm app php artisan key:generate --force
fi

# Verificar se APP_DEBUG está como false
if grep -q "APP_DEBUG=true" src/.env; then
    echo "⚠️  AVISO: APP_DEBUG está como 'true'! Isso não é recomendado para produção."
    read -p "Deseja continuar mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

# Parar containers antigos (se existirem)
echo "🛑 Parando containers antigos..."
docker compose -f docker-compose.prod.yml down

# Construir e iniciar containers
echo "🔨 Construindo imagens..."
docker compose -f docker-compose.prod.yml build --no-cache

echo "🚀 Iniciando containers..."
docker compose -f docker-compose.prod.yml up -d

# Aguardar containers iniciarem
echo "⏳ Aguardando serviços iniciarem..."
sleep 10

# Verificar saúde dos containers
echo "🏥 Verificando saúde dos containers..."
docker compose -f docker-compose.prod.yml ps

echo "✅ Deploy concluído!"
echo ""
echo "📋 Próximos passos:"
echo "   1. Verifique os logs: docker compose -f docker-compose.prod.yml logs -f"
echo "   2. Teste a aplicação: curl http://localhost"
echo "   3. Configure SSL/HTTPS se necessário"
echo ""

