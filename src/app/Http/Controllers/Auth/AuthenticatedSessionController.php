<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class AuthenticatedSessionController extends Controller
{
    /**
     * Handle an incoming authentication request. // EN
     * Lida com uma solicitação de autenticação recebida. // PT-BR
     */
    public function store(LoginRequest $request)
    {
        $request->authenticate();

        $user = $request->user();
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    /**
     * Destroy an authenticated session. // EN
     * Destrói uma sessão autenticada. // PT-BR
     */
    public function destroy(Request $request): Response
    {
        /**
         * Revoke the current user's token. // EN
         * Revogar o token atual do usuário. // PT-BR
         */
        $request->user()->currentAccessToken()->delete();

        return response()->noContent();
    }
}

