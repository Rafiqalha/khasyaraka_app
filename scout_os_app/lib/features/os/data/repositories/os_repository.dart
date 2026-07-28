import '../datasources/os_remote_datasource.dart';
import '../models/home_data_model.dart';
import '../models/academy_tree_model.dart';
import '../models/os_models.dart';

class OsRepository {
  final OsRemoteDataSource _remoteDataSource;

  OsRepository(this._remoteDataSource);

  Future<HomeDataModel> getHomeData() {
    return _remoteDataSource.getHomeData();
  }

  Future<List<RegistryDomainModel>> getRegistry() {
    return _remoteDataSource.getRegistry();
  }

  Future<PortfolioDataModel> getPortfolio() {
    return _remoteDataSource.getPortfolio();
  }

  Future<ProfileDataModel> getProfile() {
    return _remoteDataSource.getProfile();
  }

  Future<AcademyTreeModel> getAcademyTree(String academyId) {
    return _remoteDataSource.getAcademyTree(academyId);
  }
}

