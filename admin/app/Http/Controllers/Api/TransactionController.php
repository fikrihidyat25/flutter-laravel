<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index()
    {
        $transactions = auth()->user()->transactions()->latest()->get();
        return response()->json($transactions);
    }

    public function store(Request $request)
    {
        $request->validate([
            'type' => ['required', 'in:pemasukan,pengeluaran'],
            'category' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric'],
            'note' => ['nullable', 'string'],
            'date' => ['required', 'date'],
        ]);

        $transaction = auth()->user()->transactions()->create([
            'type' => $request->type,
            'category' => $request->category,
            'amount' => $request->amount,
            'note' => $request->note,
            'date' => $request->date,
        ]);

        return response()->json($transaction, 201);
    }

    public function update(Request $request, $id)
    {
        $transaction = auth()->user()->transactions()->findOrFail($id);
        
        $request->validate([
            'type' => ['required', 'in:pemasukan,pengeluaran'],
            'category' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric'],
            'note' => ['nullable', 'string'],
            'date' => ['required', 'date'],
        ]);

        $transaction->update([
            'type' => $request->type,
            'category' => $request->category,
            'amount' => $request->amount,
            'note' => $request->note,
            'date' => $request->date,
        ]);

        return response()->json($transaction);
    }

    public function destroy($id)
    {
        $transaction = auth()->user()->transactions()->findOrFail($id);
        $transaction->delete();
        
        return response()->json(['message' => 'Transaction deleted successfully']);
    }

    public function deleteAll()
    {
        auth()->user()->transactions()->delete();
        return response()->json(['message' => 'All transactions deleted'], 200);
    }

    public function getBalance()
    {
        $income = auth()->user()->transactions()
            ->where('type', 'pemasukan')
            ->sum('amount');
        $expense = auth()->user()->transactions()
            ->where('type', 'pengeluaran')
            ->sum('amount');
        
        $balance = $income - $expense;
        
        return response()->json(['balance' => $balance]);
    }

    public function getCredits()
    {
        $credits = auth()->user()->debts()
            ->where('status', 'unpaid')
            ->sum('amount');
        
        return response()->json(['total' => $credits]);
    }
}