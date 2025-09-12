import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/api_service.dart';
import '/models/user.dart';
import '/models/debt.dart';

class HutangPage extends StatefulWidget {
  final ApiService backendService;
  final User currentUser;

  const HutangPage({
    super.key,
    required this.backendService,
    required this.currentUser,
  });

  @override
  State<HutangPage> createState() => _HutangPageState();
}

class _HutangPageState extends State<HutangPage> {
  late Future<Map<String, dynamic>> _debtDataFuture;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateTextController = TextEditingController();
  DateTime? _dueDate;
  String _selectedType = 'hutang';
  bool _isLoading = false;
  bool _isPaid = false;
  
  Debt? _debtToEdit;

  @override
  void initState() {
    super.initState();
    _fetchDebtData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dueDateTextController.dispose();
    super.dispose();
  }

  void _fetchDebtData() {
    setState(() {
      _debtDataFuture = _getDebtData();
    });
  }

  Future<Map<String, dynamic>> _getDebtData() async {
    try {
      final debtsResult = await ApiService.getDebts();
      final debts = debtsResult['success'] ? debtsResult['data'] : [];
      final totalDebts = debts
          .where((d) => d.type == 'hutang')
          .fold(0.0, (sum, d) => sum + d.amount);
      final totalCredits = debts
          .where((d) => d.type == 'piutang')
          .fold(0.0, (sum, d) => sum + d.amount);
      return {
        'totalDebts': totalDebts,
        'totalCredits': totalCredits,
        'debts': debts,
      };
    } catch (e) {
      print('Error fetching debt data: $e');
      return {
        'totalDebts': 0.0,
        'totalCredits': 0.0,
        'debts': [],
      };
    }
  }
  
  void _resetForm() {
    _titleController.clear();
    _amountController.clear();
    _descriptionController.clear();
    _selectedType = 'hutang';
    _dueDate = null;
    _dueDateTextController.text = 'Pilih tanggal';
    _debtToEdit = null;
    _isPaid = false;
  }

  void _confirmResetAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Hutang & Piutang'),
        content: const Text('Yakin ingin menghapus SEMUA data hutang & piutang? Tindakan ini tidak dapat dibatalkan!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final res = await ApiService.deleteAllDebts();
              Navigator.pop(context);
              if (!mounted) return;
              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Daftar hutang & piutang direset')),
                );
                _fetchDebtData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Gagal reset data')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }
  
  void _showAddDebtDialog({Debt? debt}) {
    if (debt == null) {
      _resetForm();
    } else {
      _debtToEdit = debt;
      _titleController.text = debt.name;
      // Format amount to remove .0 for whole numbers
      String amountText = NumberFormat.decimalPattern('id_ID').format(debt.amount);
      if (amountText.endsWith('.0')) {
        amountText = amountText.substring(0, amountText.length - 2);
      }
      _amountController.text = amountText;
      _descriptionController.text = debt.note ?? '';
      _selectedType = debt.type;
      _dueDate = debt.dueDate;
      _isPaid = debt.isPaid;
      _dueDateTextController.text = DateFormat('dd/MM/yyyy').format(debt.dueDate);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInDialog) {
          return AlertDialog(
            title: Text(debt == null ? 'Tambah Hutang/Piutang' : 'Edit Hutang/Piutang'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Jenis',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'hutang', child: Text('Hutang')),
                        DropdownMenuItem(value: 'piutang', child: Text('Piutang')),
                      ],
                      onChanged: (value) {
                        setStateInDialog(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul (Nama Pemberi/Penerima)',
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
                        final cleanValue = value.replaceAll('Rp ', '').replaceAll(',', '');
                        final amount = double.tryParse(cleanValue);
                        if (amount == null) {
                          return 'Jumlah harus berupa angka';
                        }
                        if (amount <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                        if (amount > 999999999999.99) {
                          return 'Jumlah terlalu besar (maksimal 999,999,999,999.99)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Tanggal',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setStateInDialog(() {
                                      _dueDate = date;
                                      _dueDateTextController.text = DateFormat('dd/MM/yyyy').format(date);
                                    });
                                  }
                                },
                              ),
                            ),
                            controller: _dueDateTextController,
                            validator: (value) {
                                if (_selectedType == 'hutang' && (value == null || value.isEmpty || value == 'Pilih tanggal')) {
                                  return 'Tanggal jatuh tempo tidak boleh kosong';
                                }
                                return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  await _addOrUpdateDebt();
                  Navigator.pop(context);
                },
                child: _isLoading ? const CircularProgressIndicator() : Text(debt == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _markAsPaid(Debt debt) async {
    try {
      final updatedDebt = debt.copyWith(isPaid: true);
      final result = await ApiService.updateDebt(debt.id!, updatedDebt);
      
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hutang/Piutang berhasil ditandai lunas!')),
          );
          _fetchDebtData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal menandai lunas')),
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

  Future<void> _markAsUnpaid(Debt debt) async {
    try {
      final updatedDebt = debt.copyWith(isPaid: false);
      final result = await ApiService.updateDebt(debt.id!, updatedDebt);
      
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hutang/Piutang berhasil ditandai belum lunas!')),
          );
          _fetchDebtData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal mengubah status')),
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

  Future<void> _addOrUpdateDebt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.tryParse(_amountController.text.replaceAll('Rp ', '').replaceAll(',', ''));
      final newDebt = Debt(
        id: _debtToEdit?.id,
        name: _titleController.text,
        amount: amount!,
        type: _selectedType.toLowerCase(),
        note: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        dueDate: _dueDate ?? DateTime.now(),
        isPaid: _isPaid,
      );

      final result = _debtToEdit == null ? await ApiService.createDebt(newDebt) : await ApiService.updateDebt(newDebt.id!, newDebt);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hutang/Piutang berhasil ${ _debtToEdit == null ? 'ditambahkan' : 'diperbarui'}!')),
          );
          _fetchDebtData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal ${ _debtToEdit == null ? 'menambahkan' : 'memperbarui'} hutang/piutang')),
          );
        }
      }
    } catch (e) {
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

  Widget _buildDebtCard(Debt debt) {
    final isDebt = debt.type == 'hutang';
    final amountColor = isDebt ? Colors.red : Colors.green;
    final icon = isDebt ? Icons.arrow_downward : Icons.arrow_upward;
    final displayAmount = NumberFormat.decimalPattern('id_ID').format(debt.amount);

    final hasDueDate = true;
    final dueDate = DateFormat('dd MMM yyyy').format(debt.dueDate);
    final statusText = debt.isPaid ? 'LUNAS' : 'BELUM LUNAS';
    final statusColor = debt.isPaid ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () => _showAddDebtDialog(debt: debt),
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(icon, color: amountColor),
        ),
        title: Text(
          debt.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(debt.note ?? 'Tidak ada deskripsi'),
            if (hasDueDate)
              Text(
                'Jatuh tempo: $dueDate',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp $displayAmount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                Text(
                  isDebt ? 'Hutang' : 'Piutang',
                  style: TextStyle(fontSize: 12, color: amountColor),
                ),
              ],
            ),
            const SizedBox(width: 8),
            if (!debt.isPaid)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                onPressed: () => _markAsPaid(debt),
                tooltip: 'Tandai Lunas',
              )
            else
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _markAsUnpaid(debt),
                tooltip: 'Tandai Belum Lunas',
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _debtDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          final totalDebts = data['totalDebts'] ?? 0.0;
          final totalCredits = data['totalCredits'] ?? 0.0;
          final debts = data['debts'] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: const Color(0xFF3AD0A2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Hutang',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${NumberFormat.decimalPattern('id_ID').format(totalDebts)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Piutang',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${NumberFormat.decimalPattern('id_ID').format(totalCredits)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Hutang & Piutang',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3AD0A2)),
                          onPressed: () => _showAddDebtDialog(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.red),
                          onPressed: () => _confirmResetAll(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: debts.isEmpty
                    ? const Center(child: Text('Tidak ada data hutang atau piutang'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: debts.length,
                        itemBuilder: (context, index) {
                          return _buildDebtCard(debts[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
