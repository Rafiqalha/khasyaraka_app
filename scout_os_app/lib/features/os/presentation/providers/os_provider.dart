import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/os_remote_datasource.dart';
import '../../data/repositories/os_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/core/services/secure_storage_service.dart';
import '../../data/models/home_data_model.dart';
import '../../data/models/academy_tree_model.dart';
import '../../data/models/os_models.dart';

final osRemoteDataSourceProvider = Provider<OsRemoteDataSource>((ref) {
  return OsRemoteDataSource();
});

final osRepositoryProvider = Provider<OsRepository>((ref) {
  final remoteDataSource = ref.watch(osRemoteDataSourceProvider);
  return OsRepository(remoteDataSource);
});

final homeDataProvider = FutureProvider<HomeDataModel>((ref) async {
  final repository = ref.watch(osRepositoryProvider);
  return repository.getHomeData();
});

final osRegistryProvider = FutureProvider<List<RegistryDomainModel>>((ref) async {
  final repository = ref.watch(osRepositoryProvider);
  return repository.getRegistry();
});

final osPortfolioProvider = FutureProvider<PortfolioDataModel>((ref) async {
  final repository = ref.watch(osRepositoryProvider);
  return repository.getPortfolio();
});

final osProfileProvider = FutureProvider<ProfileDataModel>((ref) async {
  final repository = ref.watch(osRepositoryProvider);
  return repository.getProfile();
});

final academyTreeProvider = FutureProvider.family<AcademyTreeModel, String>((ref, academyId) async {
  final repository = ref.watch(osRepositoryProvider);
  return repository.getAcademyTree(academyId);
});


final homeSseProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) async* {
  final request = http.Request('GET', Uri.parse('${Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '')}/api/v2/os/stream'));
  
  final token = await SecureStorageService.getToken();
  if (token != null && token.isNotEmpty) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  final response = await request.send();
  
  if (response.statusCode != 200) {
    throw Exception('Failed to connect to SSE');
  }

  await for (var line in response.stream.transform(utf8.decoder)) {
    if (line.startsWith('data: ')) {
      final dataStr = line.substring(6);
      try {
        final data = jsonDecode(dataStr);
        yield data;
      } catch (e) {
        // ignore JSON parse error
      }
    }
  }
});
