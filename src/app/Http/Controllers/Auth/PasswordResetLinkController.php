<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Notifications\ResetPasswordNotification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class PasswordResetLinkController extends Controller
{
    /**
     * Handle an incoming password reset link request. // EN
     * Lida com uma solicitação de envio de link de redefinição de senha. // PT-BR
     * 
     * Sends an email with password reset link to the user. // EN
     * Envia um e-mail com link de redefinição de senha para o usuário. // PT-BR
     * 
     * For security, always returns the same message regardless of whether the email exists. // EN
     * Por segurança, sempre retorna a mesma mensagem, independente de o email existir ou não. // PT-BR
     *
     * @param Request $request The incoming request // EN
     * @param Request $request A requisição recebida // PT-BR
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        // Rate limiting: maximum 5 requests per hour per IP/email // EN
        // Rate limiting: máximo 5 solicitações por hora por IP/email // PT-BR
        $key = 'forgot-password:' . $request->ip() . ':' . strtolower($request->email);
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            throw ValidationException::withMessages([
                'email' => ['Muitas solicitações. Tente novamente em ' . ceil($seconds / 60) . ' minutos.'],
            ]);
        }
        
        // Record the attempt with 1 hour window // EN
        // Registra a tentativa com janela de 1 hora // PT-BR
        RateLimiter::hit($key, 3600);

        $request->validate([
            'email' => ['required', 'email'],
        ]);

        // Check if user exists // EN
        // Verificar se o usuário existe // PT-BR
        $user = User::where('email', $request->email)->first();

        // ALWAYS generate a token (for security - doesn't reveal if email exists or not) // EN
        // SEMPRE gerar um token (por segurança - não revela se email existe ou não) // PT-BR
        $token = Str::random(64);

        if ($user) {
            // Email exists: save token in database and send email // EN
            // Email existe: salvar token no banco e enviar e-mail // PT-BR
            DB::table('password_reset_tokens')->updateOrInsert(
                ['email' => $user->email],
                [
                    'token' => Hash::make($token),
                    'created_at' => now(),
                ]
            );

            // Send email with reset link // EN
            // Enviar e-mail com link de reset // PT-BR
            $user->notify(new ResetPasswordNotification($token));
        } else {
            // Email doesn't exist: simulate processing with random delay // EN
            // Email não existe: simular processamento com delay aleatório // PT-BR
            // (mitigates timing attacks - attacker can't measure response time) // EN
            // (mitiga timing attacks - atacante não consegue medir tempo de resposta) // PT-BR
            usleep(rand(100000, 500000)); // 100-500ms random delay // EN
            // 100-500ms de delay aleatório // PT-BR
            
            // DON'T save token in database - it won't work for reset // EN
            // NÃO salvar token no banco - ele não funcionará no reset // PT-BR
            // DON'T send email - but we return anyway to not reveal that email doesn't exist // EN
            // NÃO enviar e-mail - mas retornamos mesmo assim para não revelar que email não existe // PT-BR
        }

        // ALWAYS return the same message, regardless of whether email exists or not // EN
        // SEMPRE retornar a mesma mensagem, independente de o email existir ou não // PT-BR
        // This prevents email enumeration (email harvesting) // EN
        // Isso previne enumeração de emails (email harvesting) // PT-BR
        return response()->json([
            'message' => 'Se o email estiver cadastrado, um link de redefinição foi enviado.',
        ], 200);
    }
}

