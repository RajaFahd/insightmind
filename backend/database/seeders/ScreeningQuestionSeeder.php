<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ScreeningQuestion;

class ScreeningQuestionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Options with scores that can reach max 100 points (10 questions x 10 points each)
        $defaultOptions = [
            ['text' => 'Tidak pernah', 'score' => 0],
            ['text' => 'Jarang (1-2 kali)', 'score' => 3],
            ['text' => 'Kadang-kadang (3-4 kali)', 'score' => 5],
            ['text' => 'Sering (5-6 kali)', 'score' => 8],
            ['text' => 'Sangat sering/Setiap hari', 'score' => 10],
        ];

        $questions = [
            // Mental Health Questions (1-5)
            [
                'question_text' => 'Dalam 2 minggu terakhir, seberapa sering Anda merasa tidak bersemangat atau tidak tertarik melakukan aktivitas sehari-hari?',
                'category' => 'mental_health',
                'order' => 1,
            ],
            [
                'question_text' => 'Dalam 2 minggu terakhir, seberapa sering Anda merasa sedih, tertekan, atau putus asa tanpa alasan yang jelas?',
                'category' => 'mental_health',
                'order' => 2,
            ],
            [
                'question_text' => 'Dalam 2 minggu terakhir, seberapa sering Anda mengalami kesulitan tidur, tidur tidak nyenyak, atau tidur terlalu banyak?',
                'category' => 'mental_health',
                'order' => 3,
            ],
            [
                'question_text' => 'Dalam 2 minggu terakhir, seberapa sering Anda merasa lelah, tidak bertenaga, atau kekurangan energi?',
                'category' => 'mental_health',
                'order' => 4,
            ],
            [
                'question_text' => 'Dalam 2 minggu terakhir, seberapa sering Anda merasa buruk tentang diri sendiri atau merasa menjadi beban bagi orang lain?',
                'category' => 'mental_health',
                'order' => 5,
            ],

            // Anxiety Questions (6-8)
            [
                'question_text' => 'Seberapa sering Anda merasa gelisah, cemas, atau khawatir berlebihan tentang berbagai hal?',
                'category' => 'anxiety',
                'order' => 6,
            ],
            [
                'question_text' => 'Seberapa sering Anda mengalami gejala fisik kecemasan seperti jantung berdebar, berkeringat, atau gemetar?',
                'category' => 'anxiety',
                'order' => 7,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa sulit untuk rileks, tenang, atau mengendalikan kekhawatiran Anda?',
                'category' => 'anxiety',
                'order' => 8,
            ],

            // Stress Questions (9-10)
            [
                'question_text' => 'Seberapa sering Anda merasa kewalahan dengan tanggung jawab, pekerjaan, atau masalah sehari-hari?',
                'category' => 'stress',
                'order' => 9,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa mudah marah, tersinggung, atau tidak sabar terhadap orang lain?',
                'category' => 'stress',
                'order' => 10,
            ],

            // Additional Mental Health Questions (11-15)
            [
                'question_text' => 'Seberapa sering Anda kesulitan berkonsentrasi pada tugas atau pekerjaan Anda?',
                'category' => 'mental_health',
                'order' => 11,
            ],
            [
                'question_text' => 'Seberapa sering Anda mengalami perubahan nafsu makan (makan terlalu banyak atau terlalu sedikit)?',
                'category' => 'mental_health',
                'order' => 12,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa kesepian meskipun ada orang di sekitar Anda?',
                'category' => 'mental_health',
                'order' => 13,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa tidak puas dengan hidup Anda saat ini?',
                'category' => 'mental_health',
                'order' => 14,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa tidak ada yang peduli dengan Anda?',
                'category' => 'mental_health',
                'order' => 15,
            ],

            // Additional Anxiety Questions (16-20)
            [
                'question_text' => 'Seberapa sering Anda mengalami serangan panik atau ketakutan yang tiba-tiba dan intens?',
                'category' => 'anxiety',
                'order' => 16,
            ],
            [
                'question_text' => 'Seberapa sering Anda menghindari situasi atau tempat tertentu karena takut atau cemas?',
                'category' => 'anxiety',
                'order' => 17,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa tegang atau tidak bisa diam?',
                'category' => 'anxiety',
                'order' => 18,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa takut akan hal buruk yang mungkin terjadi?',
                'category' => 'anxiety',
                'order' => 19,
            ],
            [
                'question_text' => 'Seberapa sering pikiran negatif atau mengkhawatirkan mengganggu aktivitas Anda?',
                'category' => 'anxiety',
                'order' => 20,
            ],

            // Depression Questions (21-25)
            [
                'question_text' => 'Seberapa sering Anda merasa tidak ada harapan untuk masa depan?',
                'category' => 'depression',
                'order' => 21,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa tidak berharga atau memiliki rasa bersalah yang berlebihan?',
                'category' => 'depression',
                'order' => 22,
            ],
            [
                'question_text' => 'Seberapa sering Anda kehilangan minat pada hobi atau aktivitas yang biasanya Anda nikmati?',
                'category' => 'depression',
                'order' => 23,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa hidup tidak berarti atau tidak memiliki tujuan?',
                'category' => 'depression',
                'order' => 24,
            ],
            [
                'question_text' => 'Seberapa sering Anda menarik diri dari interaksi sosial atau menghindari bertemu orang lain?',
                'category' => 'depression',
                'order' => 25,
            ],

            // Additional Stress Questions (26-30)
            [
                'question_text' => 'Seberapa sering Anda mengalami sakit kepala, ketegangan otot, atau nyeri fisik akibat stres?',
                'category' => 'stress',
                'order' => 26,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa tidak mampu mengatasi masalah atau tantangan yang ada?',
                'category' => 'stress',
                'order' => 27,
            ],
            [
                'question_text' => 'Seberapa sering Anda mengalami kesulitan membuat keputusan bahkan untuk hal-hal kecil?',
                'category' => 'stress',
                'order' => 28,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa waktu yang Anda miliki tidak cukup untuk menyelesaikan semua tugas?',
                'category' => 'stress',
                'order' => 29,
            ],
            [
                'question_text' => 'Seberapa sering Anda merasa terbebani oleh ekspektasi orang lain terhadap Anda?',
                'category' => 'stress',
                'order' => 30,
            ],
        ];

        foreach ($questions as $question) {
            ScreeningQuestion::create([
                'question_text' => $question['question_text'],
                'category' => $question['category'],
                'options' => $defaultOptions,
                'order' => $question['order'],
                'is_active' => true,
            ]);
        }
    }
}
