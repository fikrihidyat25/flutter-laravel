<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Debt;
use Illuminate\Support\Facades\DB;

class UpdateDebtsStatus extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'debts:update-status';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update status debts yang tidak memiliki status menjadi unpaid';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Memulai update status debts...');
        
        // Update debts yang tidak memiliki status
        $updatedCount = DB::table('debts')
            ->whereNull('status')
            ->orWhere('status', '')
            ->update(['status' => 'unpaid']);
            
        $this->info("Berhasil mengupdate {$updatedCount} debts dengan status 'unpaid'");
        
        // Tampilkan total debts
        $totalDebts = Debt::count();
        $this->info("Total debts dalam database: {$totalDebts}");
        
        // Tampilkan breakdown status
        $statusBreakdown = Debt::selectRaw('status, count(*) as count')
            ->groupBy('status')
            ->get();
            
        foreach ($statusBreakdown as $status) {
            $statusLabel = $status->status === 'paid' ? 'Lunas' : 'Belum Lunas';
            $this->info("- {$statusLabel}: {$status->count}");
        }
        
        $this->info('Update status debts selesai!');
    }
}
