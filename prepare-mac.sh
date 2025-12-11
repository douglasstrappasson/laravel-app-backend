#!/bin/bash
# Script de preparação para macOS
# Apenas instala dependências e prepara .env
# NÃO executa comandos PHP/artisan

echo "🔧 Preparando ambiente..."

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Testar se o Docker realmente funciona (não apenas se o comando existe)
if ! docker info &> /dev/null; then
    echo "❌ Docker encontrado mas não está funcionando."
    echo ""
    echo "Verifique se o Docker Desktop está rodando:"
    echo "  - Abra o Docker Desktop"
    echo "  - Aguarde ele inicializar completamente"
    exit 1
fi

echo "✓ Docker encontrado e funcionando"

# Copiar src/.env.example para src/.env se não existir
if [ ! -f "src/.env" ]; then
    if [ -f "src/.env.example" ]; then
        cp src/.env.example src/.env
        echo "✓ Arquivo src/.env criado a partir de src/.env.example"
    else
        echo "⚠️ Arquivo src/.env.example não encontrado"
    fi
else
    echo "✓ Arquivo src/.env já existe"
fi

# Garantir que bootstrap/cache existe localmente antes de instalar dependências
mkdir -p src/bootstrap/cache
chmod -R 775 src/bootstrap/cache

# Instalar dependências PHP via Composer dentro do container
echo "📦 Instalando dependências PHP..."
docker compose run --rm app sh -c "mkdir -p /var/www/bootstrap/cache && chmod -R 775 /var/www/bootstrap/cache && composer install"

echo "✅ Preparação concluída!"
echo "Agora você pode subir os containers com: docker compose up -d --build"

