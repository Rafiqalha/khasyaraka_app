import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

class LocationOption {
  final String id;
  final String name;
  final String? type;

  LocationOption({required this.id, required this.name, this.type});

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }
}

class LocationRepository {
  final Dio _dio;

  LocationRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  Future<List<LocationOption>> getProvinsi() async {
    try {
      final response = await _dio.get('/location/provinsi');
      final data = response.data['data'] as List;
      return data.map((e) => LocationOption.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar provinsi: $e');
    }
  }

  Future<List<LocationOption>> getKabupaten(String provinsiId) async {
    try {
      final response = await _dio.get('/location/kabupaten', queryParameters: {'provinsi_id': provinsiId});
      final data = response.data['data'] as List;
      return data.map((e) => LocationOption.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar kabupaten: $e');
    }
  }

  Future<List<LocationOption>> getKecamatan(String kabupatenId) async {
    try {
      final response = await _dio.get('/location/kecamatan', queryParameters: {'kabupaten_id': kabupatenId});
      final data = response.data['data'] as List;
      return data.map((e) => LocationOption.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar kecamatan: $e');
    }
  }

  Future<void> setLocation(String kecamatanId) async {
    try {
      await _dio.post('/location/set', data: {'kecamatan_id': kecamatanId});
    } catch (e) {
      throw Exception('Gagal menyimpan lokasi: $e');
    }
  }
}
