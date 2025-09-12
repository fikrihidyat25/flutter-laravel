import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/api_service.dart';
import '/models/transaction.dart';

class TransaksiPage extends StatefulWidget {
  final Function(String, double, String, String, DateTime) onAddTransaction;
  final double? initialAmount;
  
  // ApiService tidak perlu di final
  final ApiService backendService;

  const TransaksiPage({
    super.key,
    required this.onAddTransaction,
    required this.backendService,
    this.initialAmount,
  });

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'Pengeluaran';
  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  final List<String> _expenseCategories = [
    'Makanan', 'Transportasi', 'Belanja', 'Tagihan', 'Hiburan', 'Kesehatan', 'Pendidikan', 'Lainnya'
  ];
  final List<String> _incomeCategories = [
    'Gaji', 'Bonus', 'Investasi', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = (widget.initialAmount != null && widget.initialAmount! > 0)
        ? NumberFormat.decimalPattern('id_ID').format(widget.initialAmount)
        : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addTransaction() async {
    print('_addTransaction called');
    
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    print('Form validation passed, setting loading state');
    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d]'), ''));
      print('Parsed amount: $amount');
      
      final newTransaction = Transaction(
        amount: amount!,
        category: _selectedCategory,
        note: _titleController.text.trim(),
        type: _selectedType.toLowerCase(),
        date: _selectedDate,
      );

      print('Created transaction: ${newTransaction.toJson()}');
      print('Calling ApiService.createTransaction...');

      final result = await ApiService.createTransaction(newTransaction);
      print('API result: $result');

      if (mounted) {
        if (result['success']) {
          print('Transaction created successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
          );
          widget.onAddTransaction(
            newTransaction.note ?? '',
            newTransaction.amount,
            newTransaction.type,
            newTransaction.category,
            newTransaction.date,
          );
          Navigator.pop(context);
        } else {
          print('Transaction creation failed: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal menambahkan transaksi')),
          );
        }
      }
    } catch (e) {
      print('Error in _addTransaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Transaksi Baru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['Pengeluaran', 'Pemasukan'].map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Tipe Transaksi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                    _selectedCategory = newValue == 'Pengeluaran' ? 'Makanan' : 'Gaji';
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: (_selectedType == 'Pengeluaran' ? _expenseCategories : _incomeCategories)
                    .map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Transaksi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3AD0A2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3AD0A2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
