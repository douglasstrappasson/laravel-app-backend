# Configuração de E-mail - Instruções

## Atualizar .env.example

Adicione ou atualize as seguintes variáveis no arquivo `src/.env.example`:

```env
# Configuração de E-mail (Gmail)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-de-app
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=seu-email@gmail.com
MAIL_FROM_NAME="${APP_NAME}"

# URL do Frontend (fictício por enquanto, para testes)
FRONTEND_URL=http://localhost:3000
```

## Configuração do Gmail

Para usar Gmail SMTP, você precisa:

1. Ativar "Verificação em duas etapas" na sua conta Google
2. Gerar uma "Senha de App" em: https://myaccount.google.com/apppasswords
3. Usar essa senha de app no `MAIL_PASSWORD` (NÃO use a senha normal da conta)

## Aplicar no .env

Depois de atualizar o `.env.example`, copie essas variáveis para o seu arquivo `.env` e configure com seus dados reais.

