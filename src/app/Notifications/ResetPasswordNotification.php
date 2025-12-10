<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordNotification extends Notification
{
    use Queueable;

    /**
     * Create a new notification instance. // EN
     * Cria uma nova instância da notificação. // PT-BR
     *
     * @param string $token The password reset token // EN
     * @param string $token O token de redefinição de senha // PT-BR
     */
    public function __construct(
        public string $token
    ) {
        //
    }

    /**
     * Get the notification's delivery channels. // EN
     * Obtém os canais de entrega da notificação. // PT-BR
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification. // EN
     * Obtém a representação de e-mail da notificação. // PT-BR
     *
     * Builds the password reset email with a link containing the token and user email. // EN
     * Constrói o e-mail de redefinição de senha com um link contendo o token e o e-mail do usuário. // PT-BR
     *
     * @param object $notifiable The user receiving the notification // EN
     * @param object $notifiable O usuário que receberá a notificação // PT-BR
     * @return MailMessage
     */
    public function toMail(object $notifiable): MailMessage
    {
        // Get frontend URL from config or environment variable // EN
        // Obtém a URL do frontend da configuração ou variável de ambiente // PT-BR
        $frontendUrl = config('app.frontend_url', env('FRONTEND_URL', 'http://localhost:3000'));
        
        // Get token expiration time from config (default 60 minutes) // EN
        // Obtém o tempo de expiração do token da configuração (padrão 60 minutos) // PT-BR
        $expireMinutes = config('auth.passwords.users.expire', 60);
        
        // Build the reset password URL with token and email as query parameters // EN
        // Constrói a URL de redefinição de senha com token e e-mail como parâmetros de query // PT-BR
        $url = $frontendUrl . '/reset-password?' . http_build_query([
            'token' => $this->token,
            'email' => $notifiable->email,
        ]);

        return (new MailMessage)
            ->subject('Redefinir sua senha')
            ->greeting('Olá ' . $notifiable->name . '!')
            ->line('Você está recebendo este e-mail porque recebemos uma solicitação de redefinição de senha para sua conta.')
            ->action('Redefinir Senha', $url)
            ->line('Este link de redefinição de senha expirará em ' . $expireMinutes . ' minutos.')
            ->line('Se você não solicitou uma redefinição de senha, nenhuma ação adicional é necessária.')
            ->salutation('Atenciosamente, ' . config('app.name'));
    }

    /**
     * Get the array representation of the notification. // EN
     * Obtém a representação em array da notificação. // PT-BR
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            //
        ];
    }
}

