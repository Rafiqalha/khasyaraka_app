import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore, size: 72, color: Color(0xFF00695C)),
              const SizedBox(height: 16),
              const Text(
                'Scout OS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk atau buat akun lokal untuk mulai belajar.',
                style: TextStyle(color: Colors.blueGrey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                  ),
                  child: const Text('Masuk'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
