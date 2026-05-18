import 'package:get/get.dart';

import '../../features/admin/data/repositories/admin_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/farmer_application/data/application_repository.dart';
import '../../features/farmer_application/providers/application_provider.dart';
import '../../features/farmer_panel/dashboard/data/dashboard_repository.dart';
import '../../features/farmer_panel/dashboard/providers/dashboard_provider.dart';
import '../../features/farmer_panel/invitations/data/invitation_repository.dart';
import '../../features/farmer_panel/invitations/providers/invitation_provider.dart';
import '../../features/farmer_panel/products/data/farmer_product_repository.dart';
import '../../features/farmer_panel/products/providers/my_products_provider.dart';
import '../../features/farmer_panel/products/providers/product_form_provider.dart';
import '../../features/farmer_panel/profile/data/farmer_profile_repository.dart';
import '../../features/farmer_panel/profile/providers/farmer_profile_provider.dart';
import '../../features/otp/data/otp_repository.dart';
import '../../features/public/categories/data/category_repository.dart';
import '../../features/public/categories/providers/category_provider.dart';
import '../../features/public/farmers/data/farmer_repository.dart';
import '../../features/public/home/providers/home_provider.dart';
import '../../features/public/products/data/product_repository.dart';
import '../../features/public/products/providers/product_list_provider.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../storage/secure_storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core infra
    final storage = SecureStorageService();
    Get.put<SecureStorageService>(storage, permanent: true);

    final authService = AuthService(storage);
    Get.put<AuthService>(authService, permanent: true);

    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);

    Get.put<ApiClient>(
      ApiClient(
        storage,
        onUnauthorized: () {
          // ignore: discarded_futures
          Get.find<AuthService>().handleUnauthorized();
        },
      ),
      permanent: true,
    );

    // Repositories (lazy + fenix so they re-create after Get.delete)
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<FarmerRepository>(
      () => FarmerRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<OtpRepository>(
      () => OtpRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<FarmerProductRepository>(
      () => FarmerProductRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<FarmerProfileRepository>(
      () => FarmerProfileRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(
        api: Get.find<ApiClient>(),
        products: Get.find<FarmerProductRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ApplicationRepository>(
      () => ApplicationRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<InvitationRepository>(
      () => InvitationRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<AdminRepository>(
      () => AdminRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    // Global controllers (lazy + fenix; initialized on first access)
    Get.lazyPut<CategoryController>(
      () => CategoryController(Get.find<CategoryRepository>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<ProductRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProductListController>(
      () => ProductListController(Get.find<ProductRepository>()),
      fenix: true,
    );
    Get.lazyPut<FarmerProfileController>(
      () => FarmerProfileController(
        profileRepo: Get.find<FarmerProfileRepository>(),
        productRepo: Get.find<FarmerProductRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<DashboardRepository>()),
      fenix: true,
    );
    Get.lazyPut<InvitationController>(
      () => InvitationController(Get.find<InvitationRepository>()),
      fenix: true,
    );
    Get.lazyPut<MyProductsController>(
      () => MyProductsController(Get.find<FarmerProductRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProductFormController>(
      () => ProductFormController(Get.find<FarmerProductRepository>()),
      fenix: true,
    );
    Get.lazyPut<ApplicationFormController>(
      () => ApplicationFormController(Get.find<ApplicationRepository>()),
      fenix: true,
    );
  }
}
