import '../datasources/os_remote_datasource.dart';
import '../models/home_data_model.dart';
import '../models/academy_tree_model.dart';

class OsRepository {
  final OsRemoteDataSource _remoteDataSource;

  OsRepository(this._remoteDataSource);

  Future<HomeDataModel> getHomeData() {
    return _remoteDataSource.getHomeData();
  }

  Future<AcademyTreeModel> getAcademyTree(String academyId) {
    return _remoteDataSource.getAcademyTree(academyId);
  }
}
