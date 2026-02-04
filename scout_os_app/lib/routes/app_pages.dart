import 'package:get/get.dart';
import 'package:scout_os_app/features/home/presentation/pages/training_map_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_map_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';

/// GetX Pages Configuration
/// 
/// File ini mendefinisikan semua routes menggunakan GetX.
/// Untuk menggunakan GetX routing, ubah MaterialApp menjadi GetMaterialApp di main.dart.
class AppPages {
  // Route names
  static const String trainingMap = '/training-map';
  static const String skuMap = '/sku-map';

  // Pages list
  static final List<GetPage> pages = [
    GetPage(
      name: trainingMap,
      page: () => const TrainingMapPage(),
    ),
    GetPage(
      name: skuMap,
      page: () => const SkuMapPage(),
      binding: BindingsBuilder(() {
        // Initialize controller saat route dipanggil
        Get.lazyPut(() => SkuController());
      }),
    ),
  ];
}
