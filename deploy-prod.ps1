# Script PowerShell para fazer deploy em produção no Windows

Write-Host "🚀 Preparando deploy para PRODUÇÃO..." -ForegroundColor Cyan

# Verificar se o arquivo .env existe
if (-not (Test-Path "src\.env")) {
    Write-Host "❌ ERRO: Arquivo src\.env não encontrado!" -ForegroundColor Red
    Write-Host "📝 Copie o arquivo .env.production.example para src\.env e configure:" -ForegroundColor Yellow
    Write-Host "   Copy-Item .env.production.example src\.env"
    Write-Host "   # Edite src\.env com suas configurações"
    exit 1
}

# Verificar se APP_KEY está configurada
$envContent = Get-Content "src\.env" -Raw
if ($envContent -notmatch "APP_KEY=base64:") {
    Write-Host "⚠️  AVISO: APP_KEY não encontrada no .env" -ForegroundColor Yellow
    Write-Host "🔑 Gerando APP_KEY..." -ForegroundColor Cyan
    docker compose -f docker-compose.prod.yml run --rm app php artisan key:generate --force
}

# Verificar se APP_DEBUG está como false
if ($envContent -match "APP_DEBUG=true") {
    Write-Host "⚠️  AVISO: APP_DEBUG está como 'true'! Isso não é recomendado para produção." -ForegroundColor Yellow
    $response = Read-Host "Deseja continuar mesmo assim? (s/N)"
    if ($response -ne "s" -and $response -ne "S") {
        exit 1
    }
}

# Parar containers antigos (se existirem)
Write-Host "🛑 Parando containers antigos..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml down

# Construir e iniciar containers
Write-Host "🔨 Construindo imagens..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml build --no-cache

Write-Host "🚀 Iniciando containers..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml up -d

# Aguardar containers iniciarem
Write-Host "⏳ Aguardando serviços iniciarem..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Verificar saúde dos containers
Write-Host "🏥 Verificando saúde dos containers..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml ps

Write-Host "✅ Deploy concluído!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Verifique os logs: docker compose -f docker-compose.prod.yml logs -f"
Write-Host "   2. Teste a aplicação: curl http://localhost"
Write-Host "   3. Configure SSL/HTTPS se necessário"
Write-Host ""

