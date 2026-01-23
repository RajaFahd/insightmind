<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\User;
use App\Models\ScreeningResult;
use App\Models\ScreeningQuestion;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    /**
     * Show admin login form
     */
    public function showLogin()
    {
        return view('admin.login');
    }

    /**
     * Handle admin login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $admin = Admin::where('email', $request->email)->first();

        if (!$admin || !Hash::check($request->password, $admin->password)) {
            return back()->withErrors([
                'email' => 'Email atau password salah.',
            ])->withInput();
        }

        session(['admin_id' => $admin->id, 'admin_name' => $admin->name]);

        return redirect()->route('admin.dashboard');
    }

    /**
     * Show admin dashboard
     */
    public function dashboard()
    {
        $totalUsers = User::count();
        $totalScreenings = ScreeningResult::count();
        $recentUsers = User::latest()->take(5)->get();
        $recentScreenings = ScreeningResult::with('user')->latest()->take(5)->get();
        
        // Get notifications
        $notifications = Notification::where('is_read', false)->latest()->take(10)->get();
        $unreadCount = Notification::where('is_read', false)->count();
        
        // Get daily screening data for last 7 days
        $dailyData = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = ScreeningResult::whereDate('created_at', $date->toDateString())->count();
            $dailyData[] = [
                'date' => $date->format('d M'),
                'day' => $date->format('D'),
                'count' => $count,
            ];
        }

        return view('admin.dashboard', compact(
            'totalUsers', 
            'totalScreenings', 
            'recentUsers', 
            'recentScreenings',
            'notifications',
            'unreadCount',
            'dailyData'
        ));
    }

    /**
     * Mark notification as read
     */
    public function markNotificationRead($id)
    {
        $notification = Notification::find($id);
        if ($notification) {
            $notification->is_read = true;
            $notification->save();
        }
        return redirect()->back();
    }

    /**
     * Mark all notifications as read
     */
    public function markAllNotificationsRead()
    {
        Notification::where('is_read', false)->update(['is_read' => true]);
        return redirect()->back()->with('success', 'Semua notifikasi telah dibaca.');
    }

    /**
     * Get notifications JSON for AJAX
     */
    public function getNotifications()
    {
        $notifications = Notification::where('is_read', false)->latest()->take(10)->get();
        $unreadCount = Notification::where('is_read', false)->count();
        
        return response()->json([
            'notifications' => $notifications,
            'unread_count' => $unreadCount,
        ]);
    }

    /**
     * Show all users
     */
    public function users()
    {
        $users = User::with('screeningResults')->latest()->get();
        return view('admin.users', compact('users'));
    }

    /**
     * Show user detail
     */
    public function userDetail($id)
    {
        $user = User::with('screeningResults')->findOrFail($id);
        return view('admin.user-detail', compact('user'));
    }

    /**
     * Delete user
     */
    public function deleteUser($id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        return redirect()->route('admin.users')->with('success', 'User berhasil dihapus.');
    }

    /**
     * Show all screening results
     */
    public function screenings()
    {
        $screenings = ScreeningResult::with('user')->latest()->get();
        return view('admin.screenings', compact('screenings'));
    }

    /**
     * Admin logout
     */
    public function logout()
    {
        session()->forget(['admin_id', 'admin_name']);
        return redirect()->route('admin.login');
    }

    /**
     * Show all screening questions
     */
    public function questions()
    {
        $questions = ScreeningQuestion::orderBy('order')->get();
        $notifications = Notification::where('is_read', false)->latest()->take(10)->get();
        $unreadCount = Notification::where('is_read', false)->count();
        return view('admin.questions', compact('questions', 'notifications', 'unreadCount'));
    }

    /**
     * Store a new question
     */
    public function storeQuestion(Request $request)
    {
        $request->validate([
            'question_text' => 'required|string|max:500',
            'category' => 'required|string|in:mental_health,anxiety,depression,stress',
        ]);

        $maxOrder = ScreeningQuestion::max('order') ?? 0;
        
        $options = [
            ['text' => 'Tidak pernah', 'score' => 0],
            ['text' => 'Jarang (1-2 kali)', 'score' => 3],
            ['text' => 'Kadang-kadang (3-4 kali)', 'score' => 5],
            ['text' => 'Sering (5-6 kali)', 'score' => 8],
            ['text' => 'Sangat sering/Setiap hari', 'score' => 10],
        ];

        ScreeningQuestion::create([
            'question_text' => $request->question_text,
            'category' => $request->category,
            'options' => $options,
            'order' => $maxOrder + 1,
            'is_active' => true,
        ]);

        return redirect()->route('admin.questions')->with('success', 'Pertanyaan berhasil ditambahkan.');
    }

    /**
     * Update a question
     */
    public function updateQuestion(Request $request, $id)
    {
        $request->validate([
            'question_text' => 'required|string|max:500',
            'category' => 'required|string|in:mental_health,anxiety,depression,stress',
        ]);

        $question = ScreeningQuestion::findOrFail($id);
        
        // Parse options from request
        $options = [];
        if ($request->has('options')) {
            foreach ($request->options as $opt) {
                $options[] = [
                    'text' => $opt['text'],
                    'score' => (int) $opt['score'],
                ];
            }
        }

        $question->update([
            'question_text' => $request->question_text,
            'category' => $request->category,
            'options' => !empty($options) ? $options : $question->options,
        ]);

        return redirect()->route('admin.questions')->with('success', 'Pertanyaan berhasil diperbarui.');
    }

    /**
     * Delete a question
     */
    public function deleteQuestion($id)
    {
        $question = ScreeningQuestion::findOrFail($id);
        $question->delete();

        return redirect()->route('admin.questions')->with('success', 'Pertanyaan berhasil dihapus.');
    }

    /**
     * Toggle question active status
     */
    public function toggleQuestion($id)
    {
        $question = ScreeningQuestion::findOrFail($id);
        $question->is_active = !$question->is_active;
        $question->save();

        return redirect()->route('admin.questions')->with('success', 'Status pertanyaan berhasil diubah.');
    }
}
