import 'package:flutter/material.dart';

class SubscriptionTier {
  final String id;
  final String name;
  final String subtitle;
  final String priceLabel;
  final double priceValue;
  final String anchorText;
  final List<String> benefits;
  final Color primaryColor;
  final Color lipColor;
  final Color glowColor;
  final IconData icon;
  final bool isRecommended;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.priceValue,
    required this.anchorText,
    required this.benefits,
    required this.primaryColor,
    required this.lipColor,
    required this.glowColor,
    required this.icon,
    this.isRecommended = false,
  });

  static List<SubscriptionTier> get tiers => [
    const SubscriptionTier(
      id: 'free',
      name: 'Pejuang',
      subtitle: 'Mulai Perjalananmu',
      priceLabel: 'Gratis',
      priceValue: 0,
      anchorText: 'Selamanya',
      primaryColor: Color(0xFF455A64), // Blue Grey
      lipColor: Color(0xFF263238),
      glowColor: Color(0xFF78909C),
      icon: Icons.shield_outlined,
      benefits: [
        'Akses Materi PUK',
        'Panduan PPGD Dasar',
        'Teknik Tali Temali',
        'Leaderboard Nasional',
        'Profil Dasar',
      ],
    ),
    const SubscriptionTier(
      id: 'mid',
      name: 'Penjelajah',
      subtitle: 'Jelajahi Lebih Jauh',
      priceLabel: 'Rp14.900',
      priceValue: 14900,
      anchorText: 'Seharga Segelas Kopi ☕',
      primaryColor: Color(0xFF7C4DFF), // Deep Purple Accent
      lipColor: Color(0xFF4A148C),
      glowColor: Color(0xFFB388FF),
      icon: Icons.explore_rounded,
      benefits: [
        'Semua Fitur Pejuang',
        'Materi Sandi Lengkap',
        'Navigasi & Kompas',
        'Modul SKU Digital',
        '15+ Alat Cyber Sandi',
      ],
    ),
    const SubscriptionTier(
      id: 'pro',
      name: 'Pramuka Utama',
      subtitle: 'Penguasa Segala Materi',
      priceLabel: 'Rp49.900',
      priceValue: 49900,
      anchorText: 'Seharga Sekali Makan Siang 🍛',
      primaryColor: Color(0xFFFFD600), // Penegak Yellow
      lipColor: Color(0xFFF57F17),
      glowColor: Color(0xFFFFFF8D),
      icon: Icons.auto_awesome_rounded,
      isRecommended: true,
      benefits: [
        'Semua Fitur Penjelajah',
        'Ujian TKK Spesialis',
        'Panduan Hiking Pro',
        'Teknik Survival Hutan',
        'Sertifikat Digital Utama',
      ],
    ),
  ];
}
