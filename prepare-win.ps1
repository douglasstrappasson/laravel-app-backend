# Script de preparacao para Windows PowerShell
# Apenas instala dependencias e prepara .env
# NAO executa comandos PHP/artisan

Write-Host "Preparando ambiente..." -ForegroundColor Cyan

# Verificar se Docker esta instalado
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: Docker nao encontrado. Por favor, instale o Docker primeiro." -ForegroundColor Red
    exit 1
}

# Testar se o Docker realmente funciona (nao apenas se o comando existe)
$dockerTest = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO: Docker encontrado mas nao esta funcionando." -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifique se o Docker Desktop esta rodando:" -ForegroundColor Yellow
    Write-Host "  - Abra o Docker Desktop" -ForegroundColor Yellow
    Write-Host "  - Aguarde ele inicializar completamente" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Se estiver usando WSL 2, verifique a integracao:" -ForegroundColor Yellow
    Write-Host "  Docker Desktop -> Settings -> Resources -> WSL Integration -> Ative para sua distribuicao" -ForegroundColor Yellow
    exit 1
}

Write-Host "OK: Docker encontrado e funcionando" -ForegroundColor Green

# Copiar src/.env.example para src/.env se nao existir
if (-not (Test-Path "src\.env")) {
    if (Test-Path "src\.env.example") {
        Copy-Item "src\.env.example" "src\.env"
        Write-Host "OK: Arquivo src\.env criado a partir de src\.env.example" -ForegroundColor Green
    } else {
        Write-Host "AVISO: Arquivo src\.env.example nao encontrado" -ForegroundColor Yellow
    }
} else {
    Write-Host "OK: Arquivo src\.env ja existe" -ForegroundColor Green
}

# Garantir que bootstrap/cache existe localmente antes de instalar dependencias
if (-not (Test-Path "src\bootstrap\cache")) {
    New-Item -ItemType Directory -Path "src\bootstrap\cache" -Force | Out-Null
}
# No Windows, as permissoes sao gerenciadas pelo Docker

# Instalar dependencias PHP via Composer dentro do container
Write-Host "Instalando dependencias PHP..." -ForegroundColor Cyan
docker compose run --rm app sh -c "mkdir -p /var/www/bootstrap/cache && chmod -R 775 /var/www/bootstrap/cache && composer install"

Write-Host "Preparacao concluida!" -ForegroundColor Green
Write-Host "Agora voce pode subir os containers com: docker compose up -d --build" -ForegroundColor Cyan
