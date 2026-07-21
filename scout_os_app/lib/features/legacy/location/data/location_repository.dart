import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

class LocationOption {
  final String id;
  final String name;
  final String? type;
  final String? code;

  LocationOption({required this.id, required this.name, this.type, this.code});

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      code: json['code'],
    );
  }
}

class LocationRepository {
  final Dio _dio;

  LocationRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  Future<List<LocationOption>> getCountries() async {
    try {
      final response = await _dio.get('/location/countries');
      final data = response.data['data'] as List;
      return data.map((e) => LocationOption.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar negara: $e');
    }
  }

  Future<List<LocationOption>> getProvinsi({String? countryId}) async {
    try {
      final params = <String, dynamic>{};
      if (countryId != null && countryId.isNotEmpty) {
        params['country_id'] = countryId;
      }
      final response = await _dio.get('/location/provinsi', queryParameters: params);
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

  Future<void> updateProfileCountry(String countryId) async {
    try {
      await _dio.patch('/me/profile', data: {'country_id': countryId});
    } catch (e) {
      throw Exception('Gagal menyimpan negara: $e');
    }
  }
}
