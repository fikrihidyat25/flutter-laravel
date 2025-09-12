<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Debt;
use Illuminate\Http\Request;

class DebtController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $debts = auth()->user()->debts()->latest()->get();
        return response()->json([
            'success' => true,
            'data' => $debts
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'type' => ['required', 'in:hutang,piutang'], // Perbaikan: Menambahkan type
            'note' => ['nullable', 'string'],
            'dueDate' => ['nullable', 'date'], // Perbaikan: Mengubah due_date menjadi dueDate
        ]);

        try {
            $debt = auth()->user()->debts()->create([
                'creditor_name' => $request->name,
                'amount' => $request->amount,
                'type' => $request->type, // Perbaikan: Menggunakan type
                'note' => $request->note,
                'due_date' => $request->dueDate, // Perbaikan: Mengubah dueDate menjadi due_date
                'status' => 'unpaid', // Menambahkan status default
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Hutang/Piutang berhasil ditambahkan',
                'data' => $debt
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan hutang/piutang: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(Debt $debt)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $debt = Debt::findOrFail($id);
        if ($debt->user_id !== auth()->id()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }
        
        \Log::info('Update Debt Request', [
            'id' => $id,
            'request_data' => $request->all(),
            'debt_before' => $debt->toArray()
        ]);
        
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'type' => ['required', 'in:hutang,piutang'],
            'note' => ['nullable', 'string'],
            'dueDate' => ['nullable', 'date'],
            'status' => ['sometimes', 'in:paid,unpaid'],
        ]);

        $updateData = [
            'creditor_name' => $request->name,
            'amount' => $request->amount,
            'type' => $request->type,
            'note' => $request->note,
            'due_date' => $request->dueDate,
        ];

        // Update status jika ada
        if ($request->has('status')) {
            $updateData['status'] = $request->status;
        }

        $debt->update($updateData);
        
        // Refresh data setelah update
        $debt->refresh();
        
        \Log::info('Update Debt Success', [
            'id' => $id,
            'debt_after' => $debt->toArray()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Hutang/Piutang berhasil diperbarui',
            'data' => $debt
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $debt = Debt::findOrFail($id);
        if ($debt->user_id !== auth()->id()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }
        
        $debt->delete();

        return response()->json([
            'success' => true,
            'message' => 'Hutang/Piutang berhasil dihapus'
        ], 200);
    }

    public function deleteAll()
    {
        auth()->user()->debts()->delete();
        return response()->json(['success' => true, 'message' => 'All debts deleted'], 200);
    }
    
    public function getTotal()
    {
        $total = auth()->user()->debts()->where('type', 'hutang')->where('status', 'unpaid')->sum('amount');
        return response()->json(['success' => true, 'total' => $total]);
    }
    
    public function getTotalCredits()
    {
        $total = auth()->user()->debts()->where('type', 'piutang')->where('status', 'unpaid')->sum('amount');
        return response()->json(['success' => true, 'total' => $total]);
    }
}
