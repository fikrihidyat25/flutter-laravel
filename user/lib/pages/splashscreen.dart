import 'package:flutter/material.dart';
import '/pages/login.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/pages/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.checkAuthStatus();
      if (!mounted) return;
      if (auth.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('Auth check error: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk penempatan elemen responsif.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Lingkaran Hijau di Kiri
          Positioned(
            left: -screenWidth * 0.25,
            top: screenHeight * 0.2,
            child: Container(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              decoration: const BoxDecoration(
                color: Color(0xFF3AD0A2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Lingkaran Hijau di Kanan Atas
          Positioned(
            right: -screenWidth * 0.1,
            top: -screenWidth * 0.1,
            child: Container(
              width: screenWidth * 0.4,
              height: screenWidth * 0.4,
              decoration: const BoxDecoration(
                color: Color(0xFF3AD0A2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Lingkaran Hijau di Kanan Bawah
          Positioned(
            right: -screenWidth * 0.25,
            bottom: -screenWidth * 0.25,
            child: Container(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              decoration: const BoxDecoration(
                color: Color(0xFF3AD0A2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Konten Utama di Tengah
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Finote dari gambar yang diunggah
                Image.asset(
                  'assets/images/finote_logo.png', // Sesuaikan path ini
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                
                // Nama Aplikasi "Finote"
                const Text(
                  'Finote',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 14, 14, 14), // Mengubah warna teks menjadi hitam
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3AD0A2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
