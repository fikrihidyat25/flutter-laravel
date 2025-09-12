import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';

class GeminiService {
  static final GenerativeModel _model = GenerativeModel(
    model: GeminiConfig.model,
    apiKey: GeminiConfig.apiKey,
  );

  static Future<String> sendMessage(String message) async {
    try {
      return await _sendWithModel(GeminiConfig.model, message);
    } catch (e) {
      print('Primary model failed: $e');
      // Coba dengan model fallback
      try {
        final fallbackModel = GenerativeModel(
          model: GeminiConfig.fallbackModel,
          apiKey: GeminiConfig.apiKey,
        );
        return await _sendWithModel(GeminiConfig.fallbackModel, message, model: fallbackModel);
      } catch (e2) {
        print('Fallback model also failed: $e2');
        return _handleError(e2);
      }
    }
  }

  static Future<String> _sendWithModel(String modelName, String message, {GenerativeModel? model}) async {
    final modelToUse = model ?? _model;
    final content = [Content.text(message)];
    final response = await modelToUse.generateContent(
      content,
      generationConfig: GenerationConfig(
        temperature: GeminiConfig.temperature,
        topK: GeminiConfig.topK,
        topP: GeminiConfig.topP,
        maxOutputTokens: GeminiConfig.maxOutputTokens,
      ),
    );

    if (response.text != null) {
      return response.text!;
    } else {
      return 'Maaf, tidak dapat memproses permintaan Anda saat ini.';
    }
  }

  static String _handleError(dynamic e) {
    print('Error in GeminiService: $e');
    if (e.toString().contains('SocketException')) {
      return 'Koneksi internet bermasalah. Pastikan Anda terhubung ke internet dan coba lagi.';
    } else if (e.toString().contains('ClientException')) {
      return 'Gagal menghubungi server AI. Periksa koneksi internet Anda.';
    } else if (e.toString().contains('Failed host lookup')) {
      return 'Tidak dapat menghubungi server AI. Periksa koneksi internet dan DNS.';
    } else {
      return 'Terjadi kesalahan saat menghubungi AI. Silakan coba lagi.';
    }
  }

  /// Mendapatkan tips keuangan berdasarkan konteks pengguna
  static Future<String> getFinancialTips({
    double? balance,
    double? totalDebts,
    double? totalCredits,
    int? transactionCount,
  }) async {
    String context = '';
    
    if (balance != null) {
      context += 'Saldo saat ini: Rp ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}\n';
    }
    
    if (totalDebts != null && totalDebts > 0) {
      context += 'Total hutang: Rp ${totalDebts.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}\n';
    }
    
    if (totalCredits != null && totalCredits > 0) {
      context += 'Total piutang: Rp ${totalCredits.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}\n';
    }
    
    if (transactionCount != null) {
      context += 'Jumlah transaksi bulan ini: $transactionCount\n';
    }

    String prompt = '''
Anda adalah asisten keuangan yang ahli. Berikan tips keuangan yang praktis dan mudah dipahami dalam bahasa Indonesia berdasarkan data berikut:

$context

Berikan 3-5 tips keuangan yang relevan dan actionable. Fokus pada:
1. Manajemen keuangan pribadi
2. Strategi menabung
3. Pengelolaan hutang (jika ada)
4. Investasi sederhana
5. Perencanaan keuangan
''';

    return await sendMessage(prompt);
  }

  /// Mendapatkan analisis transaksi
  static Future<String> analyzeTransactions(List<dynamic> transactions) async {
    if (transactions.isEmpty) {
      return 'Belum ada transaksi untuk dianalisis. Mulai catat transaksi Anda untuk mendapatkan insight yang lebih baik!';
    }

    // Analisis sederhana transaksi
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, int> categoryCount = {};

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
      
      String category = transaction.category ?? 'Lainnya';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    String analysis = '''
Analisis Transaksi Anda:
- Total Pemasukan: Rp ${totalIncome.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}
- Total Pengeluaran: Rp ${totalExpense.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}
- Saldo Bersih: Rp ${(totalIncome - totalExpense).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}
- Kategori Pengeluaran Terbanyak: ${categoryCount.entries.isNotEmpty ? categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b).key : 'Tidak ada data'}
''';

    String prompt = '''
Berdasarkan analisis transaksi berikut, berikan insight dan rekomendasi keuangan:

$analysis

Berikan:
1. Evaluasi pola pengeluaran
2. Rekomendasi untuk mengoptimalkan keuangan
3. Tips untuk meningkatkan tabungan
4. Peringatan jika ada pola yang perlu diperhatikan
''';

    return await sendMessage(prompt);
  }

  /// Mendapatkan jawaban umum untuk pertanyaan keuangan
  static Future<String> askQuestion(String question) async {
    String prompt = '''
Anda adalah asisten keuangan yang ahli. Jawab pertanyaan berikut dengan bahasa Indonesia yang mudah dipahami:

$question
''';

    return await sendMessage(prompt);
  }
}
