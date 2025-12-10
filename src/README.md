# Laravel API Backend

Backend API-only em Laravel 11 com Breeze API + Sanctum, PostgreSQL e Docker.

## 📋 Requisitos

- Docker
- Docker Compose

**Nota para usuários WSL 2:** Certifique-se de que a integração WSL está habilitada no Docker Desktop:
- Docker Desktop → Settings → Resources → WSL Integration → Ative para sua distribuição

## 🚀 Instalação

### Windows

```powershell
.\prepare-win.ps1
```

### Linux

```bash
chmod +x prepare-linux.sh
./prepare-linux.sh
```

### macOS

```bash
chmod +x prepare-mac.sh
./prepare-mac.sh
```

Os scripts de preparação irão:
- Verificar se o Docker está instalado e funcionando
- Criar o arquivo `.env` a partir de `.env.example` (se não existir)
- Instalar as dependências PHP via Composer

## 🐳 Subir o Ambiente

```bash
docker compose up -d --build
```

Isso irá:
- Construir e iniciar os containers (Laravel App, Nginx, PostgreSQL)
- Executar migrations automaticamente
- Gerar APP_KEY automaticamente (se necessário)
- Configurar permissões e otimizações

## 🌐 API

A API estará disponível em: **`http://localhost:8000`**

### Listar Todas as Rotas

Para ver todas as rotas disponíveis:

```bash
docker compose exec app php artisan route:list
```

Para filtrar apenas rotas da API:

```bash
docker compose exec app php artisan route:list --path=api
```

## 📡 Rotas da API

### Rotas Públicas (sem autenticação)

#### Registrar Usuário
```
POST /api/register
Content-Type: application/json

{
  "name": "João Silva",
  "email": "joao@example.com",
  "password": "senha123",
  "password_confirmation": "senha123"
}
```

**Resposta (201):**
```json
{
  "user": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@example.com",
    ...
  },
  "token": "1|xxxxxxxxxxxxxxxxxxxxx"
}
```

#### Login
```
POST /api/login
Content-Type: application/json

{
  "email": "joao@example.com",
  "password": "senha123"
}
```

**Resposta (200):**
```json
{
  "user": { ... },
  "token": "2|xxxxxxxxxxxxxxxxxxxxx"
}
```

#### Solicitar Reset de Senha
```
POST /api/forgot-password
Content-Type: application/json

{
  "email": "joao@example.com"
}
```

**Resposta (200):**
```json
{
  "status": "Enviamos por e-mail o link para redefinir sua senha."
}
```

#### Resetar Senha
```
POST /api/reset-password
Content-Type: application/json

{
  "token": "token_recebido_por_email",
  "email": "joao@example.com",
  "password": "novaSenha123",
  "password_confirmation": "novaSenha123"
}
```

**Resposta (200):**
```json
{
  "status": "Sua senha foi redefinida."
}
```

### Rotas Protegidas (requerem autenticação)

Todas as rotas protegidas precisam do header:
```
Authorization: Bearer {token}
```

#### Obter Usuário Autenticado
```
GET /api/user
Authorization: Bearer {token}
```

**Resposta (200):**
```json
{
  "id": 1,
  "name": "João Silva",
  "email": "joao@example.com",
  ...
}
```

#### Logout
```
POST /api/logout
Authorization: Bearer {token}
```

**Resposta (204):** Sem conteúdo

## 🧪 Testando a API

### Usando Postman

Uma collection do Postman está disponível no projeto. Para importar:

1. Abra o Postman
2. Clique em "Import"
3. Importe o arquivo `Laravel-API.postman_collection.json`
4. Configure um ambiente com a variável `base_url = http://localhost:8000`

As rotas de Login e Register automaticamente salvam o token nas variáveis de ambiente.

### Usando cURL

```bash
# Registrar usuário
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "João Silva",
    "email": "joao@example.com",
    "password": "senha123",
    "password_confirmation": "senha123"
  }'

# Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "joao@example.com",
    "password": "senha123"
  }'

# Obter usuário (substitua {token} pelo token recebido)
curl -X GET http://localhost:8000/api/user \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

## 🗄️ Banco de Dados

### Credenciais Padrão

- **Host:** `postgres` (dentro da network Docker) ou `localhost:5432` (fora)
- **Database:** `app`
- **User:** `app`
- **Password:** `app`

### Acessar o PostgreSQL

Via Docker:
```bash
docker compose exec postgres psql -U app -d app
```

Via cliente externo:
```
Host: localhost
Port: 5432
Database: app
User: app
Password: app
```

### Executar Migrations Manualmente

```bash
docker compose exec app php artisan migrate
```

### Executar Seeders

```bash
docker compose exec app php artisan db:seed
```

## 🔧 Comandos Úteis

### Limpar Cache

```bash
# Limpar todos os caches
docker compose exec app php artisan optimize:clear

# Limpar apenas cache de configuração
docker compose exec app php artisan config:clear

# Limpar apenas cache de rotas
docker compose exec app php artisan route:clear
```

### Ver Logs

```bash
# Logs do Laravel
docker compose exec app tail -f storage/logs/laravel.log

# Logs de todos os containers
docker compose logs -f

# Logs de um container específico
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f postgres
```

### Executar Comandos Artisan

```bash
docker compose exec app php artisan {comando}
```

Exemplos:
```bash
docker compose exec app php artisan tinker
docker compose exec app php artisan make:controller NomeController
docker compose exec app php artisan route:list
```

## 🌍 Tradução

O projeto está configurado para português brasileiro (pt_BR):

- **Locale:** `pt_BR`
- **Fallback:** `en`
- **Arquivo de traduções:** `src/lang/pt_BR.json`

Todas as mensagens de validação e erros são exibidas em português.

Para alterar o locale, edite `src/config/app.php` ou as variáveis no `.env`:
```env
APP_LOCALE=pt_BR
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=pt_BR
```

## 📁 Estrutura do Projeto

```
laravel-app/
├── docker/              # Scripts e configurações Docker
│   ├── entrypoint.sh   # Script de inicialização do container
│   ├── php-fpm-custom.conf
│   └── php-opcache.ini
├── nginx/              # Configuração do Nginx
│   └── default.conf
├── src/                # Código fonte do Laravel
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── lang/          # Traduções (pt_BR.json)
│   ├── routes/
│   └── ...
├── docker-compose.yml
├── Dockerfile
├── prepare-linux.sh
├── prepare-win.ps1
└── prepare-mac.sh
```

## 🐛 Troubleshooting

### Erro: Docker não encontrado no WSL 2

Se você receber o erro "The command 'docker' could not be found in this WSL 2 distro":
1. Abra o Docker Desktop no Windows
2. Vá em Settings → Resources → WSL Integration
3. Ative a integração para sua distribuição WSL
4. Clique em "Apply & Restart"

### Erro: Container não inicia

Verifique os logs:
```bash
docker compose logs app
```

### Erro: Permissão negada

```bash
docker compose exec app chown -R laravel:laravel /var/www/storage /var/www/bootstrap/cache
```

### Erro: Cache desatualizado

Após alterar configurações, limpe o cache:
```bash
docker compose exec app php artisan optimize:clear
```

### Resetar ambiente completo

```bash
# Parar e remover containers, volumes e networks
docker compose down -v

# Reconstruir tudo do zero
docker compose up -d --build
```

## 🔒 Segurança

- Tokens de autenticação são gerenciados pelo Laravel Sanctum
- Senhas são hashadas usando bcrypt
- Validação de requisições em todas as rotas
- Rate limiting configurado para login (5 tentativas)

## 🚀 Deploy em Produção

Este projeto está configurado para **desenvolvimento** por padrão. Para fazer deploy em produção, consulte o guia completo:

📖 **[README-DEPLOY.md](../README-DEPLOY.md)** - Guia completo de deploy em produção

### Resumo Rápido

```bash
# 1. Configure o .env de produção
cp ../.env.production.example src/.env
# Edite src/.env com suas configurações

# 2. Deploy
./deploy-prod.sh  # Linux/macOS
# ou
.\deploy-prod.ps1  # Windows

# Ou manualmente:
docker compose -f ../docker-compose.prod.yml build --no-cache
docker compose -f ../docker-compose.prod.yml up -d
```

**Diferenças entre Dev e Prod:**
- **Dev**: Volumes montados, hot reload, portas expostas, `APP_DEBUG=true`
- **Prod**: Código na imagem, otimizado, sem volumes, `APP_DEBUG=false`, SSL/HTTPS

## 📝 Licença

Este projeto é open-source e está disponível sob a [licença MIT](LICENSE).
