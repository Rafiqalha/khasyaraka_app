import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';
import '../models/home_data_model.dart';
import '../models/academy_tree_model.dart';

class OsRemoteDataSource {
  final _dio = ApiDioProvider.getDio();

  String get _host => Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');

  Future<HomeDataModel> getHomeData() async {
    final res = await _dio.get('$_host/api/v2/os/home');
    return HomeDataModel.fromJson(res.data);
  }

  Future<AcademyTreeModel> getAcademyTree(String academyId) async {
    final response = await _dio.get('$_host/api/v2/academies/$academyId/tree');
    return AcademyTreeModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> startMission({String? packId, String? academyId}) async {
    final response = await _dio.post(
      '$_host/api/v2/os/mission/start',
      data: {
        'pack_id': packId ?? 'python-fundamental.pack',
        'academy_id': academyId ?? 'ai_academy',
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
