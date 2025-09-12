import 'package:flutter/material.dart';
import '../services/aiService.dart';
import '../services/storage_service.dart';
import 'dart:convert';
import '/services/api_service.dart';
import '/models/transaction.dart';
import '/models/debt.dart';

class AiChatPage extends StatefulWidget {
  final bool showAppBar;
  const AiChatPage({super.key, this.showAppBar = false});

  @override
  State<AiChatPage> createState() => AiChatPageState();
}

class AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  String _formatAiText(String input) {
    String text = input.replaceAll('**', '');
    final lines = text.split('\n');
    int listIndex = 1;
    final List<String> formatted = [];

    for (final originalLine in lines) {
      final line = originalLine.trimRight();
      final bulletRegex = RegExp(r'^\s*[-*•]\s+');
      if (bulletRegex.hasMatch(line)) {
        final content = line.replaceFirst(bulletRegex, '');
        formatted.add('${listIndex++}. $content');
      } else {
        formatted.add(line);
      }
    }

    return formatted.join('\n');
  }

  Future<_FinancialStats> _fetchFinancialStats() async {
    try {
      final transactionsResult = await ApiService.getTransactions();
      final debtsResult = await ApiService.getDebts();

      final transactions = transactionsResult['success']
          ? (transactionsResult['data'] as List).cast<Transaction>()
          : <Transaction>[];
      final debts = debtsResult['success']
          ? (debtsResult['data'] as List).cast<Debt>()
          : <Debt>[];

      final double totalIncome = transactions
          .where((t) => t.type == 'pemasukan')
          .fold(0.0, (sum, t) => sum + t.amount);
      final double totalExpense = transactions
          .where((t) => t.type == 'pengeluaran')
          .fold(0.0, (sum, t) => sum + t.amount);
      final double balance = totalIncome - totalExpense;

      final double totalDebts = debts
          .where((d) => d.type == 'hutang')
          .fold(0.0, (sum, d) => sum + d.amount);
      final double totalCredits = debts
          .where((d) => d.type == 'piutang')
          .fold(0.0, (sum, d) => sum + d.amount);

      return _FinancialStats(
        balance: balance,
        totalDebts: totalDebts,
        totalCredits: totalCredits,
        transactionCount: transactions.length,
      );
    } catch (_) {
      return _FinancialStats.zero();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final saved = await StorageService.getAiChatMessages();
    if (saved != null && saved.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(saved);
        final restored = list
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _messages.clear();
          _messages.addAll(restored);
        });
        return;
      } catch (_) {
        // fall through to welcome if parsing fails
      }
    }
    _addWelcomeMessage();
    await _saveMessages();
  }

  Future<void> _saveMessages() async {
    final data = _messages.map((m) => m.toJson()).toList();
    await StorageService.saveAiChatMessages(jsonEncode(data));
  }

  Future<void> resetChat() async {
    setState(() {
      _messages.clear();
    });
    _addWelcomeMessage();
    await StorageService.clearAiChatMessages();
    await _saveMessages();
  }

  void confirmResetChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Chat'),
        content: const Text('Yakin ingin menghapus seluruh riwayat chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await resetChat();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Riwayat chat direset.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: "Halo! Saya adalah asisten keuangan AI Anda. Saya dapat membantu dengan:\n\n"
          "💡 Tips keuangan pribadi\n"
          "📊 Analisis transaksi\n"
          "💰 Strategi menabung\n"
          "📈 Perencanaan investasi\n"
          "❓ Pertanyaan keuangan umum\n\n"
          "Silakan tanyakan apa saja tentang keuangan Anda!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    await _saveMessages();

    _scrollToBottom();

    try {
      final stats = await _fetchFinancialStats();
      final contextPrefix =
          'Konteks pengguna: saldo Rp ${stats.balance.toStringAsFixed(0)}, total hutang Rp ${stats.totalDebts.toStringAsFixed(0)}, total piutang Rp ${stats.totalCredits.toStringAsFixed(0)}, jumlah transaksi ${stats.transactionCount}.\n\nPertanyaan: ';
      String response = await GeminiService.askQuestion(contextPrefix + userMessage);
      
      setState(() {
        _messages.add(ChatMessage(
          text: _formatAiText(response),
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      await _saveMessages();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Maaf, terjadi kesalahan. Silakan coba lagi.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      await _saveMessages();
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _getFinancialTips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _fetchFinancialStats();
      String tips = await GeminiService.getFinancialTips(
        balance: stats.balance,
        totalDebts: stats.totalDebts,
        totalCredits: stats.totalCredits,
        transactionCount: stats.transactionCount,
      );

      setState(() {
        _messages.add(ChatMessage(
          text: "💡 Tips Keuangan Personal:\n\n${_formatAiText(tips)}",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      await _saveMessages();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "maaf bro, sedang mager",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      await _saveMessages();
    }

    _scrollToBottom();
  }

  //
  void requestTips() {
    _getFinancialTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Assistant Keuangan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF3AD0A2),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                  onPressed: _getFinancialTips,
                  tooltip: 'Tips Keuangan',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: confirmResetChat,
                  tooltip: 'Reset Chat',
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const _LoadingIndicator();
                }
                
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tanyakan tentang keuangan Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF3AD0A2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF3AD0A2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFF3AD0A2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white70 
                          : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h yang lalu';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF3AD0A2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3AD0A2)),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'bentar bro',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialStats {
  final double balance;
  final double totalDebts;
  final double totalCredits;
  final int transactionCount;

  const _FinancialStats({
    required this.balance,
    required this.totalDebts,
    required this.totalCredits,
    required this.transactionCount,
  });

  factory _FinancialStats.zero() => const _FinancialStats(
        balance: 0.0,
        totalDebts: 0.0,
        totalCredits: 0.0,
        transactionCount: 0,
      );
}
