<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('screening_questions', function (Blueprint $table) {
            $table->id();
            $table->string('question_text');
            $table->string('category')->default('mental_health'); // mental_health, anxiety, depression, stress
            $table->json('options')->nullable(); // JSON array of answer options with scores
            $table->integer('order')->default(0); // Order of question in screening
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('screening_questions');
    }
};
