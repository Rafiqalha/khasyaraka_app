/// Hardcoded Sandi Pramuka Data
///
/// 15 Sandi types - 100% OFFLINE, NO API
/// Data ini digunakan untuk kegiatan outdoor pramuka
class SandiData {
  /// Get all 15 Sandi Pramuka types (hardcoded)
  static List<Map<String, dynamic>> get allSandi => [
    {
      'id': 1,
      'codename': 'morse',
      'name': 'Morse',
      'description':
          'Sandi Morse menggunakan titik (.) dan garis (-) untuk menyandikan huruf dan angka.',
      'difficulty': 1,
      'category': 'encoding',
    },
    {
      'id': 2,
      'codename': 'semaphore',
      'name': 'Semaphore',
      'description':
          'Sandi Semaphore menggunakan bendera untuk menyampaikan pesan dengan posisi tangan.',
      'difficulty': 2,
      'category': 'visual',
    },
    {
      'id': 3,
      'codename': 'rumput',
      'name': 'Rumput',
      'description':
          'Sandi Rumput menggunakan bentuk huruf yang menyerupai rumput untuk menyembunyikan pesan.',
      'difficulty': 2,
      'category': 'visual',
    },
    {
      'id': 4,
      'codename': 'kimia',
      'name': 'Kimia',
      'description':
          'Sandi Kimia menggunakan simbol-simbol kimia untuk menyandikan pesan.',
      'difficulty': 3,
      'category': 'substitution',
    },
    {
      'id': 5,
      'codename': 'angka',
      'name': 'Angka',
      'description':
          'Sandi Angka menggantikan huruf dengan angka sesuai urutan alfabet.',
      'difficulty': 1,
      'category': 'substitution',
    },
    {
      'id': 6,
      'codename': 'an',
      'name': 'AN (ROT13)',
      'description':
          'Sandi AN atau ROT13 menggeser setiap huruf 13 posisi dalam alfabet (Caesar cipher).',
      'difficulty': 1,
      'category': 'substitution',
    },
    {
      'id': 7,
      'codename': 'az_atbash',
      'name': 'AZ (Atbash)',
      'description':
          'Sandi AZ atau Atbash membalikkan alfabet (A=Z, B=Y, C=X, dst).',
      'difficulty': 1,
      'category': 'substitution',
    },
    {
      'id': 8,
      'codename': 'kotak_1',
      'name': 'Kotak 1',
      'description':
          'Sandi Kotak 1 menggunakan grid 5x5 untuk menyandikan pesan.',
      'difficulty': 2,
      'category': 'transposition',
    },
    {
      'id': 9,
      'codename': 'kotak_2',
      'name': 'Kotak 2',
      'description':
          'Sandi Kotak 2 menggunakan variasi grid untuk menyandikan pesan.',
      'difficulty': 2,
      'category': 'transposition',
    },
    {
      'id': 10,
      'codename': 'kotak_3',
      'name': 'Kotak 3',
      'description':
          'Sandi Kotak 3 menggunakan grid kompleks untuk menyandikan pesan.',
      'difficulty': 3,
      'category': 'transposition',
    },
    {
      'id': 11,
      'codename': 'jam',
      'name': 'Jam',
      'description':
          'Sandi Jam menggunakan posisi jarum jam untuk menyandikan huruf.',
      'difficulty': 2,
      'category': 'visual',
    },
    {
      'id': 12,
      'codename': 'koordinat',
      'name': 'Koordinat',
      'description':
          'Sandi Koordinat menggunakan sistem koordinat (baris, kolom) untuk menyandikan pesan.',
      'difficulty': 2,
      'category': 'substitution',
    },
    {
      'id': 13,
      'codename': 'and',
      'name': 'AND',
      'description':
          'Sandi AND menggunakan operasi logika AND untuk menyandikan pesan.',
      'difficulty': 3,
      'category': 'substitution',
    },
    {
      'id': 14,
      'codename': 'ular',
      'name': 'Ular',
      'description':
          'Sandi Ular menggunakan pola zigzag seperti ular untuk menyandikan pesan.',
      'difficulty': 2,
      'category': 'transposition',
    },
    {
      'id': 15,
      'codename': 'napoleon',
      'name': 'Napoleon',
      'description':
          'Sandi Napoleon menggunakan metode enkripsi yang dikembangkan pada era Napoleon.',
      'difficulty': 3,
      'category': 'transposition',
    },
  ];
}
