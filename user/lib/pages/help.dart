import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'Bagaimana cara menambah transaksi?',
      'answer': 'Klik tombol + di halaman utama, kemudian isi form transaksi dengan detail yang diperlukan.',
    },
    {
      'question': 'Bagaimana cara mengedit transaksi?',
      'answer': 'Pergi ke halaman riwayat, klik tombol edit pada transaksi yang ingin diedit.',
    },
    {
      'question': 'Bagaimana cara menghapus transaksi?',
      'answer': 'Di halaman riwayat, klik tombol hapus atau geser transaksi ke kiri untuk hapus cepat.',
    },
    {
      'question': 'Bagaimana cara menambah hutang?',
      'answer': 'Pergi ke halaman hutang, klik tombol + untuk menambah hutang baru.',
    },
    {
      'question': 'Bagaimana cara melihat statistik keuangan?',
      'answer': 'Statistik keuangan ditampilkan di halaman utama, termasuk saldo, pemasukan, dan pengeluaran.',
    },
    {
      'question': 'Bagaimana cara logout?',
      'answer': 'Pergi ke halaman profil, klik menu "Keluar" untuk logout dari aplikasi.',
    },
  ];

  final List<Map<String, dynamic>> _contactInfo = [
    {
      'title': 'Email Support',
      'subtitle': 'projectsfikri@gmail.com',
      'icon': Icons.email,
    },
    {
      'title': 'WhatsApp',
      'subtitle': '+62 823-8733-7572',
      'icon': Icons.phone,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: const Color(0xFF3AD0A2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 48,
                      color: const Color(0xFF3AD0A2),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pusat Bantuan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Temukan jawaban untuk pertanyaan umum Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'Pertanyaan Umum',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _buildFAQCard(faq)).toList(),
            const SizedBox(height: 24),

            // Contact Section
            const Text(
              'Hubungi Kami',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ..._contactInfo.map((contact) => _buildContactCard(contact)).toList(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActionCard(
              icon: Icons.feedback,
              title: 'Kirim Feedback',
              subtitle: 'Berikan saran untuk aplikasi',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur feedback akan segera hadir')),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              faq['answer'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: ListTile(
        leading: Icon(contact['icon'], color: const Color(0xFF3AD0A2)),
        title: Text(
          contact['title'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          contact['subtitle'],
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Membuka ${contact['title']}')),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF3AD0A2)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}


































