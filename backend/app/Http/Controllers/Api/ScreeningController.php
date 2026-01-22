<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScreeningResult;
use App\Models\User;
use App\Models\Notification;
use Illuminate\Http\Request;

class ScreeningController extends Controller
{
    private function getUser(Request $request)
    {
        $token = $request->bearerToken();
        return User::where('remember_token', $token)->first();
    }

    /**
     * Store a new screening result
     */
    public function store(Request $request)
    {
        $user = $this->getUser($request);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $request->validate([
            'answers' => 'required|array',
            'result_category' => 'required|string',
            'result_description' => 'required|string',
            'total_score' => 'required|integer',
        ]);

        $screening = ScreeningResult::create([
            'user_id' => $user->id,
            'answers' => $request->answers,
            'result_category' => $request->result_category,
            'result_description' => $request->result_description,
            'total_score' => $request->total_score,
        ]);

        // Create notification for admin
        Notification::create([
            'type' => 'new_screening',
            'title' => 'Screening Baru',
            'message' => $user->name . ' telah menyelesaikan screening dengan hasil: ' . $request->result_category,
            'data' => json_encode([
                'user_id' => $user->id,
                'user_name' => $user->name,
                'screening_id' => $screening->id,
                'category' => $request->result_category,
                'score' => $request->total_score,
            ]),
            'is_read' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Screening result saved successfully',
            'data' => $screening,
        ], 201);
    }

    /**
     * Get screening history for authenticated user
     */
    public function history(Request $request)
    {
        $user = $this->getUser($request);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $results = ScreeningResult::where('user_id', $user->id)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $results,
        ]);
    }

    /**
     * Get a specific screening result
     */
    public function show(Request $request, $id)
    {
        $user = $this->getUser($request);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $screening = ScreeningResult::where('user_id', $user->id)->find($id);

        if (!$screening) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $screening,
        ]);
    }

    /**
     * Delete a screening result
     */
    public function destroy(Request $request, $id)
    {
        $user = $this->getUser($request);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $screening = ScreeningResult::where('user_id', $user->id)->find($id);

        if (!$screening) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }

        $screening->delete();

        return response()->json([
            'success' => true,
            'message' => 'Screening result deleted successfully',
        ]);
    }
}
