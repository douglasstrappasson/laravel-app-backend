# Laravel API Backend

Backend API-only em Laravel 11 com Breeze API + Sanctum, PostgreSQL e Docker.

## 📁 Estrutura do Projeto

```
laravel-app/
├── src/              # Código fonte do Laravel
│   └── README.md    # Documentação detalhada do backend
├── docker/          # Scripts e configurações Docker
├── nginx/           # Configurações do Nginx
├── docker-compose.yml          # Configuração DEV
├── docker-compose.prod.yml     # Configuração PRODUÇÃO
├── Dockerfile                  # Dockerfile DEV
├── Dockerfile.prod             # Dockerfile PRODUÇÃO
├── prepare-*.sh/.ps1           # Scripts de preparação
├── deploy-prod.sh/.ps1         # Scripts de deploy
├── README-DEPLOY.md            # Guia de deploy em produção
└── .env.production.example     # Exemplo de variáveis para produção
```

## 🚀 Início Rápido

### Desenvolvimento

```bash
# Windows
.\prepare-win.ps1

# Linux
chmod +x prepare-linux.sh && ./prepare-linux.sh

# macOS
chmod +x prepare-mac.sh && ./prepare-mac.sh

# Subir ambiente
docker compose up -d --build
```

### Produção

Veja o guia completo: **[README-DEPLOY.md](README-DEPLOY.md)**

## 📚 Documentação

- **[src/README.md](src/README.md)** - Documentação completa do backend (rotas, comandos, troubleshooting)
- **[README-DEPLOY.md](README-DEPLOY.md)** - Guia de deploy em produção

## 🔄 Ambientes

### Desenvolvimento
- Arquivos montados via volumes (hot reload)
- `APP_DEBUG=true`
- Portas expostas para debug
- Dependências de desenvolvimento incluídas

**Comando:**
```bash
docker compose up -d
```

### Produção
- Código copiado na imagem (otimizado)
- `APP_DEBUG=false`
- Sem volumes montados
- Apenas dependências de produção
- SSL/HTTPS configurável
- Sem exposição de portas desnecessárias

**Comando:**
```bash
docker compose -f docker-compose.prod.yml up -d
```

## 🛠️ Tecnologias

- Laravel 11
- PHP 8.3
- PostgreSQL 16
- Nginx
- Docker & Docker Compose
- Laravel Sanctum (Autenticação)

## 📝 Licença

Este projeto é open-source e está disponível sob a [licença MIT](LICENSE).

