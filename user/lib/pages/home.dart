import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/services/api_service.dart';
import '/pages/riwayat.dart';
import '/pages/hutang.dart';
import '/pages/transaksi.dart';
import '/pages/profile.dart';
import '/pages/calculator.dart';
import 'aiChat.dart';
import '/models/user.dart';
import '/models/transaction.dart';
import '/models/debt.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Future<Map<String, dynamic>>? _dashboardDataFuture;
  final GlobalKey<AiChatPageState> _aiChatKey = GlobalKey<AiChatPageState>();

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchDashboardData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Refresh dashboard when switching to home page
    if (index == 0) {
      _refreshDashboard();
    }
  }

  void _openCalculatorMini() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return CalculatorPage(
            onUse: (value) {
              Navigator.pop(context);
              _openAddTransactionWithAmount(value);
            },
          );
        },
      ),
    );
  }

  void _openAddTransactionWithAmount(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransaksiPage(
        initialAmount: amount,
        backendService: ApiService(),
        onAddTransaction: (_, _, _, _, _) {
          _refreshDashboard();
        },
      ),
    );
  }

  void _openAddTransaction() {
    _openAddTransactionWithAmount(0.0);
  }
  void _confirmResetAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Transaksi'),
        content: const Text
        ('Yakin ingin menghapus SEMUA data transaksi? Tindakan ini tidak dapat dibatalkan!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Transaksi'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    try {
      await ApiService.deleteAllUserTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua transaksi berhasil direset!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _refreshDashboard();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal reset transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Makanan': return Icons.fastfood;
      case 'Transportasi': return Icons.local_gas_station;
      case 'Belanja': return Icons.shopping_bag;
      case 'Tagihan': return Icons.receipt;
      case 'Hiburan': return Icons.movie;
      case 'Kesehatan': return Icons.medical_services;
      case 'Pendidikan': return Icons.school;
      case 'Lainnya': return Icons.more_horiz;
      case 'Gaji': return Icons.money;
      case 'Bonus': return Icons.attach_money;
      case 'Investasi': return Icons.trending_up;
      default: return Icons.category;
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final isIncome = transaction.type == 'pemasukan';
    final amountColor = isIncome ? Colors.green : Colors.red;
    final displayAmount = (isIncome ? '+ ' : '- ') +
        NumberFormat.decimalPattern('id_ID').format(transaction.amount);
    final transactionDate = transaction.date;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(_getIconForCategory(transaction.category), color: amountColor),
        ),
        title: Text(
          transaction.note ?? 'No note',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.category} - ${DateFormat('dd MMMM yyyy').format(transactionDate)}',
        ),
        trailing: Text(
          displayAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      final transactionsResult = await ApiService.getTransactions();
      final debtsResult = await ApiService.getDebts();
      
      final transactions = transactionsResult['success'] ? (transactionsResult['data'] as List).cast<Transaction>() : <Transaction>[];
      final debts = debtsResult['success'] ? (debtsResult['data'] as List).cast<Debt>() : <Debt>[];
      
      final totalPemasukan = transactions.where((t) => t.type == 'pemasukan').fold(0.0, (sum, t) => sum + t.amount);
      final totalPengeluaran = transactions.where((t) => t.type == 'pengeluaran').fold(0.0, (sum, t) => sum + t.amount);
      final totalBalance = totalPemasukan - totalPengeluaran;

      final totalDebts = debts.where((d) => d.type == 'hutang').fold(0.0, (sum, d) => sum + d.amount);
      final totalCredits = debts.where((d) => d.type == 'piutang').fold(0.0, (sum, d) => sum + d.amount);
      
      return {
        'totalBalance': totalBalance,
        'totalDebts': totalDebts,
        'totalCredits': totalCredits,
        'totalPengeluaran': totalPengeluaran,
        'transactions': transactions,
      };
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return {};
    }
  }
  
  void _refreshDashboard() {
    setState(() {
      _dashboardDataFuture = _fetchDashboardData();
    });
  }

  Widget _buildHomePage(User? user) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};
        final totalBalance = data['totalBalance'] as double? ?? 0.0;
        final totalDebts = data['totalDebts'] as double? ?? 0.0;
        final totalCredits = data['totalCredits'] as double? ?? 0.0;
        final totalPengeluaran = data['totalPengeluaran'] as double? ?? 0.0;
        final transactions = data['transactions'] as List<Transaction>? ?? [];
        final totalTransactions = transactions.length;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF3AD0A2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${NumberFormat.decimalPattern('id_ID').format(totalBalance)}',
                      style: const TextStyle(
                        color: Colors.white, // Pastikan warnanya putih
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statistik',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Kalkulator',
                              icon: const Icon(Icons.calculate),
                              color: const Color(0xFF3AD0A2),
                              onPressed: _openCalculatorMini,
                            ),
                            IconButton(
                              tooltip: 'Reset Semua Data',
                              icon: const Icon(Icons.refresh),
                              color: Colors.red,
                              onPressed: _confirmResetAll,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.receipt_long,
                          title: 'Total Transaksi',
                          value: totalTransactions.toString(),
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Total Hutang',
                          value: 'Rp ${NumberFormat.decimalPattern('id_ID').format(totalDebts)}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.trending_up,
                          title: 'Total Piutang',
                          value: 'Rp ${NumberFormat.decimalPattern('id_ID').format(totalCredits)}',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.account_balance_wallet,
                          title: 'Saldo Keluar',
                          value: 'Rp ${NumberFormat.decimalPattern('id_ID').format(totalPengeluaran)}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionTile(transaction);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final List<Widget> widgetOptions = [
          _buildHomePage(user),
          HutangPage(
            backendService: ApiService(),
            currentUser: user,
          ),
          AiChatPage(key: _aiChatKey),
          RiwayatPage(
            backendService: ApiService(),
            onDataChanged: _refreshDashboard,
          ),
          const ProfilePage(),
        ];

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              _selectedIndex == 0
                  ? 'Hallo, ${user.name}!'
                  : _selectedIndex == 1
                      ? 'Manajemen Hutang'
                      : _selectedIndex == 2
                          ? 'Assistant Keuangan'
                          : _selectedIndex == 3
                              ? 'Riwayat Transaksi'
                              : 'Profil',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF3AD0A2),
            elevation: 0,
            actions: _selectedIndex == 2
                ? [
                    IconButton(
                      icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                      tooltip: 'Dapatkan Tips Keuangan',
                      onPressed: () => _aiChatKey.currentState?.requestTips(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Reset Chat',
                      onPressed: () => _aiChatKey.currentState?.confirmResetChat(),
                    ),
                  ]
                : null,
          ),
          body: widgetOptions[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Hutang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline),
                label: 'Tips',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF3AD0A2),
            onTap: _onItemTapped,
          ),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton(
                  onPressed: _openAddTransaction,
                  backgroundColor: const Color(0xFF3AD0A2),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }
}