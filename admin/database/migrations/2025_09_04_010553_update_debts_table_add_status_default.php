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
        Schema::table('debts', function (Blueprint $table) {
            // Pastikan field status ada dan memiliki nilai default
            if (!Schema::hasColumn('debts', 'status')) {
                $table->enum('status', ['unpaid', 'paid'])->default('unpaid')->after('type');
            } else {
                // Update existing records yang tidak memiliki status
                DB::statement("UPDATE debts SET status = 'unpaid' WHERE status IS NULL OR status = ''");
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('debts', function (Blueprint $table) {
            if (Schema::hasColumn('debts', 'status')) {
                $table->dropColumn('status');
            }
        });
    }
};
