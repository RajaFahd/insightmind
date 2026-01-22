<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!session('admin_id')) {
            return redirect()->route('admin.login')->withErrors([
                'message' => 'Silakan login terlebih dahulu.'
            ]);
        }

        return $next($request);
    }
}
