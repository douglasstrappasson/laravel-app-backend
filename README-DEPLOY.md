# 🚀 Guia de Deploy - Produção

Este guia explica como fazer deploy da aplicação em ambiente de produção.

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Domínio configurado (opcional, mas recomendado)
- Certificados SSL/TLS (para HTTPS)

## 🔧 Configuração Inicial

### 1. Configurar Variáveis de Ambiente

Copie o arquivo de exemplo e configure:

```bash
cp .env.production.example src/.env
```

Edite `src/.env` e configure:

- **APP_KEY**: Gere com `php artisan key:generate`
- **APP_URL**: URL do seu domínio (ex: `https://api.seudominio.com`)
- **DB_PASSWORD**: Senha forte para o banco de dados
- **MAIL_***: Configurações de email
- **SANCTUM_STATEFUL_DOMAINS**: Domínios do frontend
- **FRONTEND_URL**: URL do frontend

### 2. Gerar APP_KEY

```bash
docker compose -f docker-compose.prod.yml run --rm app php artisan key:generate
```

## 🚀 Deploy

### Linux/macOS

```bash
chmod +x deploy-prod.sh
./deploy-prod.sh
```

### Windows (PowerShell)

```powershell
.\deploy-prod.ps1
```

### Manual

```bash
# Parar containers existentes
docker compose -f docker-compose.prod.yml down

# Construir imagens
docker compose -f docker-compose.prod.yml build --no-cache

# Iniciar containers
docker compose -f docker-compose.prod.yml up -d

# Verificar logs
docker compose -f docker-compose.prod.yml logs -f
```

## 🔒 Segurança em Produção

### Checklist de Segurança

- [ ] `APP_DEBUG=false` no `.env`
- [ ] `APP_ENV=production` no `.env`
- [ ] Senha forte no banco de dados
- [ ] APP_KEY única e segura
- [ ] Porta 5432 do PostgreSQL NÃO exposta
- [ ] SSL/HTTPS configurado
- [ ] CORS configurado corretamente
- [ ] Rate limiting ativo
- [ ] Backups automáticos do banco

### Configurar SSL/HTTPS

1. Obtenha certificados SSL (Let's Encrypt recomendado):

```bash
# Instalar certbot
apt-get install certbot

# Gerar certificados
certbot certonly --standalone -d seu-dominio.com
```

2. Configure no `nginx/prod.conf`:

Descomente e configure a seção SSL no arquivo `nginx/prod.conf`.

3. Monte os certificados no docker-compose:

Edite `docker-compose.prod.yml` e descomente as linhas de volumes SSL:

```yaml
volumes:
  - ./nginx/ssl:/etc/nginx/ssl:ro
```

## 📊 Monitoramento

### Ver Logs

```bash
# Todos os containers
docker compose -f docker-compose.prod.yml logs -f

# Container específico
docker compose -f docker-compose.prod.yml logs -f app
docker compose -f docker-compose.prod.yml logs -f nginx
```

### Verificar Status

```bash
docker compose -f docker-compose.prod.yml ps
```

### Health Check

```bash
curl http://seu-dominio.com/up
```

## 🔄 Atualizações

Para atualizar a aplicação:

```bash
# 1. Fazer pull das alterações
git pull

# 2. Reconstruir e reiniciar
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml build --no-cache
docker compose -f docker-compose.prod.yml up -d

# 3. Rodar migrations (se necessário)
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force

# 4. Limpar e recriar caches
docker compose -f docker-compose.prod.yml exec app php artisan optimize:clear
docker compose -f docker-compose.prod.yml exec app php artisan config:cache
docker compose -f docker-compose.prod.yml exec app php artisan route:cache
```

## 💾 Backups

### Backup do Banco de Dados

```bash
# Criar backup
docker compose -f docker-compose.prod.yml exec postgres pg_dump -U app app > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
docker compose -f docker-compose.prod.yml exec -T postgres psql -U app app < backup.sql
```

### Automatizar Backups

Crie um cron job ou use um serviço de backup automatizado.

## 🛑 Rollback

Se algo der errado:

```bash
# Parar containers
docker compose -f docker-compose.prod.yml down

# Restaurar código anterior
git checkout <commit-anterior>

# Reconstruir e subir
docker compose -f docker-compose.prod.yml build --no-cache
docker compose -f docker-compose.prod.yml up -d
```

## 🔍 Troubleshooting

### Container não inicia

```bash
docker compose -f docker-compose.prod.yml logs app
```

### Erro de permissões

```bash
docker compose -f docker-compose.prod.yml exec app chown -R laravel:laravel /var/www/storage /var/www/bootstrap/cache
```

### Cache desatualizado

```bash
docker compose -f docker-compose.prod.yml exec app php artisan optimize:clear
docker compose -f docker-compose.prod.yml exec app php artisan config:cache
docker compose -f docker-compose.prod.yml exec app php artisan route:cache
```

## 📝 Notas Importantes

1. **Nunca** exponha a porta do PostgreSQL (5432) em produção
2. **Sempre** use HTTPS em produção
3. **Nunca** deixe `APP_DEBUG=true` em produção
4. Configure **backups automáticos** do banco de dados
5. Monitore os **logs regularmente**
6. Mantenha o Docker e as imagens **atualizados**

