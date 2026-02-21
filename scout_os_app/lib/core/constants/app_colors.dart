import 'package:flutter/material.dart';

class AppColors {
  // --- 1. IDENTITAS KHAS PRAMUKA PENEGAK ---

  // KUNING PENEGAK (Wajib untuk aksen Penegak/Bantara/Laksana)
  static const Color penegakYellow = Color(
    0xFFFFD600,
  ); // Kuning Tegas (Epaulet)

  // COKLAT MUDA (Warna Baju Seragam - Background Aplikasi)
  static const Color scoutLightBrown = Color(0xFFF0E6D2); // Krem Seragam

  // COKLAT TUA (Warna Celana/Rok - Teks & Header)
  static const Color scoutDarkBrown = Color(0xFF4E342E); // Coklat Kopi

  // MERAH HASDUK (Aksen, Error, Notifikasi)
  static const Color hasdukRed = Color(0xFFD32F2F); // Merah Darah

  // PUTIH HASDUK (Card Background, Teks di atas Gelap)
  static const Color hasdukWhite = Color(0xFFFFFFFF); // Putih Bersih

  // HITAM PEKAT (Outline, Shadow, Teks Kontras)
  static const Color pitchBlack = Color(0xFF000000); // Hitam Tinta

  // --- 2. ALIAS UNTUK KOMPATIBILITAS (Agar kode lama tidak error) ---
  static const Color scoutBg = scoutLightBrown;
  static const Color scoutBrown = scoutDarkBrown;
  static const Color scoutRed = hasdukRed;
  static const Color textDark = pitchBlack;
  static const Color textGrey = Color(
    0xFF795548,
  ); // Coklat pudar untuk teks sekunder

  // Warna Tambahan Fungsional
  static const Color successGreen = Color(
    0xFF388E3C,
  ); // Tetap butuh hijau untuk "Benar"
  static const Color actionOrange = Color(0xFFE65100); // Variasi semangat
  static const Color goldBadge =
      penegakYellow; // Mapping Emas ke Kuning Penegak

  // Warna Tambahan untuk Kompatibilitas (digunakan di berbagai file)
  static const Color forestGreen = Color(
    0xFF2E7D32,
  ); // Hijau hutan (untuk success/completed)
  static const Color scoutWhite = hasdukWhite; // Alias untuk putih
  static const Color scoutKhaki = Color(0xFFC9B037); // Khaki pramuka
  static const Color alertRed = hasdukRed; // Alias untuk error/alert
  static const Color wosmPurple = Color(
    0xFF6A1B9A,
  ); // Ungu WOSM (World Organization of the Scout Movement)

  // --- 3. DUOLINGO-STYLE GAMIFIED UI COLORS ---

  // Success (Correct Answer)
  static const Color duoSuccess = Color(0xFF58CC02); // Hijau Duolingo
  static const Color duoSuccessShadow = Color(0xFF46A302); // Shadow hijau
  static const Color duoSuccessLight = Color(
    0xFFD7FFB8,
  ); // Background hijau muda

  // Error (Wrong Answer)
  static const Color duoError = Color(0xFFFF4B4B); // Merah Duolingo
  static const Color duoErrorShadow = Color(0xFFEA2B2B); // Shadow merah
  static const Color duoErrorLight = Color(0xFFFFDFE0); // Background merah muda

  // Neutral & Selection
  static const Color duoNeutralBorder = Color(
    0xFFE5E5E5,
  ); // Border abu-abu default
  static const Color duoSelectedBorder = Color(
    0xFF84D8FF,
  ); // Border biru selected
  static const Color duoSelectedBg = Color(0xFFDDF4FF); // Background biru muda

  // Button Effects
  static const Color duoButtonShadow = Color(0xFFCECECE); // Shadow 3D button
}
