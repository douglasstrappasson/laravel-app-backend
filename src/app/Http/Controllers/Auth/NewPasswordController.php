<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules;
use Illuminate\Validation\ValidationException;

class NewPasswordController extends Controller
{
    /**
     * Handle an incoming new password request. // EN
     * Lida com uma solicitação de nova senha. // PT-BR
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): JsonResponse
    {
        // Rate limiting: máximo 5 tentativas por minuto por IP
        $key = 'reset-password:' . $request->ip();
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            throw ValidationException::withMessages([
                'email' => ['Muitas tentativas. Tente novamente em ' . ceil($seconds / 60) . ' minutos.'],
            ]);
        }
        
        RateLimiter::hit($key, 60); // 60 segundos de janela

        $request->validate([
            'token' => ['required'],
            'email' => ['required', 'email'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        // Buscar o registro de reset na tabela
        $passwordReset = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        // Mensagem genérica de erro (por segurança - não revela se email/token existe)
        $errorMessage = 'Token inválido ou expirado. Por favor, solicite um novo token.';

        // Verificar se o token existe e é válido
        if (!$passwordReset || !Hash::check($request->token, $passwordReset->token)) {
            // Simular processamento com delay aleatório (mitiga timing attacks)
            usleep(rand(100000, 500000)); // 100-500ms de delay aleatório
            
            throw ValidationException::withMessages([
                'email' => [$errorMessage],
            ]);
        }

        // Verificar se o token não expirou (60 minutos por padrão)
        $expireMinutes = config('auth.passwords.users.expire', 60);
        $tokenCreatedAt = \Carbon\Carbon::parse($passwordReset->created_at);
        $expiredAt = now()->subMinutes($expireMinutes);
        
        if ($tokenCreatedAt < $expiredAt) {
            // Token expirado - remover da tabela
            DB::table('password_reset_tokens')->where('email', $request->email)->delete();
            
            throw ValidationException::withMessages([
                'email' => [$errorMessage],
            ]);
        }

        // Buscar o usuário
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            // Por segurança, mesmo se usuário não existir, retornamos a mesma mensagem genérica
            throw ValidationException::withMessages([
                'email' => [$errorMessage],
            ]);
        }

        // Atualizar a senha do usuário
        $user->forceFill([
            'password' => Hash::make($request->password),
            'remember_token' => Str::random(60),
        ])->save();

        // Remover o token usado (não pode ser reutilizado)
        DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        return response()->json([
            'status' => __('passwords.reset'),
            'message' => 'Sua senha foi redefinida com sucesso.',
        ], 200);
    }
}

