<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ScreeningQuestion;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ScreeningQuestionController extends Controller
{
    /**
     * Display a listing of the questions.
     */
    public function index(Request $request)
    {
        $query = ScreeningQuestion::query();

        // Filter by category
        if ($request->has('category')) {
            $query->byCategory($request->category);
        }

        // Filter by active status
        if ($request->has('active')) {
            $query->where('is_active', $request->boolean('active'));
        }

        $questions = $query->ordered()->get();

        return response()->json([
            'success' => true,
            'data' => $questions,
        ]);
    }

    /**
     * Store a newly created question.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'question_text' => 'required|string|max:500',
            'category' => 'required|string|in:mental_health,anxiety,depression,stress',
            'options' => 'nullable|array',
            'options.*.text' => 'required_with:options|string',
            'options.*.score' => 'required_with:options|integer|min:0|max:10',
            'order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Set default order to last position
        $maxOrder = ScreeningQuestion::max('order') ?? 0;
        
        $question = ScreeningQuestion::create([
            'question_text' => $request->question_text,
            'category' => $request->category,
            'options' => $request->options ?? $this->getDefaultOptions(),
            'order' => $request->order ?? ($maxOrder + 1),
            'is_active' => $request->is_active ?? true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pertanyaan berhasil ditambahkan',
            'data' => $question,
        ], 201);
    }

    /**
     * Display the specified question.
     */
    public function show(ScreeningQuestion $screeningQuestion)
    {
        return response()->json([
            'success' => true,
            'data' => $screeningQuestion,
        ]);
    }

    /**
     * Update the specified question.
     */
    public function update(Request $request, ScreeningQuestion $screeningQuestion)
    {
        $validator = Validator::make($request->all(), [
            'question_text' => 'sometimes|required|string|max:500',
            'category' => 'sometimes|required|string|in:mental_health,anxiety,depression,stress',
            'options' => 'nullable|array',
            'options.*.text' => 'required_with:options|string',
            'options.*.score' => 'required_with:options|integer|min:0|max:10',
            'order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $screeningQuestion->update($request->only([
            'question_text',
            'category',
            'options',
            'order',
            'is_active',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Pertanyaan berhasil diperbarui',
            'data' => $screeningQuestion,
        ]);
    }

    /**
     * Remove the specified question.
     */
    public function destroy(ScreeningQuestion $screeningQuestion)
    {
        $screeningQuestion->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pertanyaan berhasil dihapus',
        ]);
    }

    /**
     * Reorder questions
     */
    public function reorder(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'questions' => 'required|array',
            'questions.*.id' => 'required|exists:screening_questions,id',
            'questions.*.order' => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        foreach ($request->questions as $item) {
            ScreeningQuestion::where('id', $item['id'])->update(['order' => $item['order']]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Urutan pertanyaan berhasil diubah',
        ]);
    }

    /**
     * Toggle question active status
     */
    public function toggleActive(ScreeningQuestion $screeningQuestion)
    {
        $screeningQuestion->update([
            'is_active' => !$screeningQuestion->is_active,
        ]);

        return response()->json([
            'success' => true,
            'message' => $screeningQuestion->is_active ? 'Pertanyaan diaktifkan' : 'Pertanyaan dinonaktifkan',
            'data' => $screeningQuestion,
        ]);
    }

    /**
     * Get default options for screening questions
     */
    private function getDefaultOptions(): array
    {
        return [
            ['text' => 'Tidak pernah', 'score' => 0],
            ['text' => 'Kadang-kadang', 'score' => 1],
            ['text' => 'Sering', 'score' => 2],
            ['text' => 'Sangat sering', 'score' => 3],
        ];
    }
}
