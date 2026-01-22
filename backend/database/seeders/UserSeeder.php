<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\ScreeningResult;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create demo users
        $users = [
            [
                'name' => 'Rasyid Demo',
                'email' => 'rasyid@demo.com',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'User Test',
                'email' => 'user@test.com',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Ahmad Sehat',
                'email' => 'ahmad@demo.com',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Siti Aminah',
                'email' => 'siti@demo.com',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Budi Santoso',
                'email' => 'budi@demo.com',
                'password' => Hash::make('password123'),
            ],
        ];

        foreach ($users as $userData) {
            $user = User::create($userData);

            // Create screening history for each user
            $this->createScreeningHistory($user);
        }
    }

    /**
     * Create screening history for a user
     */
    private function createScreeningHistory(User $user): void
    {
        $descriptions = [
            'Normal' => 'Kondisi kesehatan mental Anda dalam keadaan baik. Terus jaga pola hidup sehat!',
            'Ringan' => 'Ada sedikit gejala yang perlu diperhatikan. Cobalah teknik relaksasi dan olahraga teratur.',
            'Sedang' => 'Disarankan untuk berkonsultasi dengan profesional kesehatan mental.',
            'Tinggi' => 'Sangat disarankan untuk segera mencari bantuan profesional.',
        ];

        // Create 3-5 screening results for each user
        $numResults = rand(3, 5);
        for ($i = 0; $i < $numResults; $i++) {
            $score = rand(5, 50);
            $category = $this->getCategoryByScore($score);

            ScreeningResult::create([
                'user_id' => $user->id,
                'total_score' => $score,
                'result_category' => $category,
                'result_description' => $descriptions[$category],
                'answers' => [
                    'q1' => rand(0, 3),
                    'q2' => rand(0, 3),
                    'q3' => rand(0, 3),
                    'q4' => rand(0, 3),
                    'q5' => rand(0, 3),
                    'q6' => rand(0, 3),
                ],
                'created_at' => now()->subDays(rand(1, 60)),
                'updated_at' => now()->subDays(rand(1, 60)),
            ]);
        }
    }

    /**
     * Get category based on score
     */
    private function getCategoryByScore(int $score): string
    {
        if ($score <= 10) {
            return 'Normal';
        } elseif ($score <= 25) {
            return 'Ringan';
        } elseif ($score <= 40) {
            return 'Sedang';
        } else {
            return 'Tinggi';
        }
    }
}
