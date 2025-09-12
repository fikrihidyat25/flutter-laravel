import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/api_service.dart';
import '/models/transaction.dart';
import '/pages/edit_transaction.dart';

class RiwayatPage extends StatefulWidget {
  final ApiService backendService;
  final VoidCallback? onDataChanged;

  const RiwayatPage({
    super.key,
    required this.backendService,
    this.onDataChanged,
  });

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() {
    setState(() {
      _transactionsFuture = _getTransactionsFromApi();
    });
  }

  Future<List<Transaction>> _getTransactionsFromApi() async {
    final result = await ApiService.getTransactions();
    if (result['success']) {
      return result['data'] as List<Transaction>;
    } else {
      throw Exception(result['message'] ?? 'Gagal memuat transaksi');
    }
  }

  Color _getColorForType(String type) {
    return type == 'pemasukan' ? Colors.green : Colors.red;
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.fastfood;
      case 'Transportasi':
        return Icons.local_gas_station;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Tagihan':
        return Icons.receipt;
      case 'Hiburan':
        return Icons.movie;
      case 'Kesehatan':
        return Icons.medical_services;
      case 'Pendidikan':
        return Icons.school;
      case 'Gaji':
        return Icons.money;
      case 'Bonus':
        return Icons.attach_money;
      case 'Investasi':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      final result = await ApiService.deleteTransaction(id);
      if (mounted) {
        if (result['success']) {
          _fetchTransactions();
          widget.onDataChanged?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result['message'] ?? 'Gagal menghapus transaksi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
              'Apakah Anda yakin ingin menghapus transaksi "${transaction.note}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransaction(transaction.id!);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(Transaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: transaction),
      ),
    );

    if (result == true) {
      _fetchTransactions();
      widget.onDataChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _fetchTransactions();
                },
                child: FutureBuilder<List<Transaction>>(
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final transactions = snapshot.data ?? [];
                    if (transactions.isEmpty) {
                      return const Center(
                          child: Text('Riwayat transaksi kosong'));
                    }
                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final isIncome = transaction.type == 'pemasukan';
                        final amountColor = _getColorForType(transaction.type);
                        final displayAmount = (isIncome ? '+ ' : '- ') +
                            NumberFormat.decimalPattern('id_ID')
                                .format(transaction.amount);
                        return Dismissible(
                          key: ValueKey(transaction.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) =>
                              _deleteTransaction(transaction.id!),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            amountColor.withOpacity(0.1),
                                        child: Icon(
                                          _getIconForCategory(
                                              transaction.category),
                                          color: amountColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction.note ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${transaction.category} - ${DateFormat('dd MMMM yyyy').format(transaction.date)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        displayAmount,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: amountColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _editTransaction(transaction),
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Edit'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showDeleteConfirmation(transaction),
                                        icon:
                                            const Icon(Icons.delete, size: 18),
                                        label: const Text('Hapus'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}