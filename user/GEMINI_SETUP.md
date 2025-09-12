# Setup Gemini AI untuk Fitur Tips

## Langkah-langkah Setup

### 1. Dapatkan API Key Gemini
1. Kunjungi [Google AI Studio](https://ai.google.com/studio)
2. Login dengan akun Google Anda
3. Buat project baru atau pilih project yang sudah ada
4. Generate API key baru
5. Copy API key yang dihasilkan

### 2. Konfigurasi API Key
1. Buka file `lib/config/gemini_config.dart`
2. Ganti `YOUR_GEMINI_API_KEY_HERE` dengan API key yang Anda dapatkan
3. Simpan file

### 3. Install Dependencies
Jalankan perintah berikut di terminal:
```bash
flutter pub get
```

### 4. Test Fitur
1. Jalankan aplikasi
2. Buka halaman Home
3. Klik icon "Tips AI" di sebelah "Transaksi Terbaru"
4. Mulai chat dengan AI

## Fitur yang Tersedia

### 💡 Tips Keuangan Personal
- Klik icon lampu di header chat untuk mendapatkan tips keuangan
- Tips akan disesuaikan dengan data keuangan Anda

### 🤖 Chat dengan AI
- Tanyakan apapun tentang keuangan
- Dapatkan saran investasi
- Tips pengelolaan keuangan
- Analisis transaksi

### 📊 Analisis Transaksi
- AI akan menganalisis pola pengeluaran Anda
- Memberikan rekomendasi untuk optimasi keuangan

## Troubleshooting

### Error "API Key Invalid"
- Pastikan API key sudah benar di `gemini_config.dart`
- Cek apakah API key masih aktif di Google AI Studio

### Error "Quota Exceeded"
- Cek quota penggunaan di Google AI Studio
- Upgrade plan jika diperlukan

### Error "Network Error"
- Pastikan koneksi internet stabil
- Cek firewall atau proxy settings

## Konfigurasi Lanjutan

Anda dapat mengubah konfigurasi AI di `lib/config/gemini_config.dart`:

```dart
class GeminiConfig {
  static const String apiKey = 'YOUR_API_KEY';
  static const String model = 'gemini-1.5-flash'; // Model yang digunakan
  static const double temperature = 0.7; // Kreativitas AI (0.0 - 1.0)
  static const int topK = 40; // Jumlah token yang dipertimbangkan
  static const double topP = 0.95; // Probabilitas kumulatif
  static const int maxOutputTokens = 1024; // Maksimal token output
}
```

## Keamanan

- Jangan commit API key ke repository public
- Gunakan environment variables untuk production
- Rotate API key secara berkala












