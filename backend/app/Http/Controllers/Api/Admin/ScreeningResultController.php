<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ScreeningResult;
use App\Models\User;
use Illuminate\Http\Request;

class ScreeningResultController extends Controller
{
    /**
     * Display a listing of all screening results.
     */
    public function index(Request $request)
    {
        $query = ScreeningResult::with('user');

        // Filter by user
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Filter by category
        if ($request->has('category')) {
            $query->where('result_category', $request->category);
        }

        // Filter by date range
        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }
        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        $results = $query->latest()->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => $results,
        ]);
    }

    /**
     * Display the specified screening result.
     */
    public function show($id)
    {
        $result = ScreeningResult::with('user')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }

    /**
     * Remove the specified screening result.
     */
    public function destroy($id)
    {
        $result = ScreeningResult::findOrFail($id);
        $result->delete();

        return response()->json([
            'success' => true,
            'message' => 'Hasil screening berhasil dihapus',
        ]);
    }

    /**
     * Get screening statistics
     */
    public function statistics()
    {
        $totalUsers = User::count();
        $totalScreenings = ScreeningResult::count();
        
        $categoryStats = ScreeningResult::selectRaw('result_category, COUNT(*) as count')
            ->groupBy('result_category')
            ->pluck('count', 'result_category');

        $monthlyStats = ScreeningResult::selectRaw('MONTH(created_at) as month, COUNT(*) as count')
            ->whereYear('created_at', date('Y'))
            ->groupBy('month')
            ->pluck('count', 'month');

        $recentResults = ScreeningResult::with('user')
            ->latest()
            ->take(10)
            ->get();

        $averageScore = ScreeningResult::avg('total_score');

        return response()->json([
            'success' => true,
            'data' => [
                'total_users' => $totalUsers,
                'total_screenings' => $totalScreenings,
                'category_stats' => $categoryStats,
                'monthly_stats' => $monthlyStats,
                'recent_results' => $recentResults,
                'average_score' => round($averageScore, 2),
            ],
        ]);
    }
}
