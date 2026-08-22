import 'package:get_it/get_it.dart';
import '../../../shared/api/api_client.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/repository/auth_repository.dart';
import '../modules/lojistas/services/lojista_service.dart';
import '../modules/lojistas/repositories/lojista_repository.dart';
import '../modules/lojistas/bloc/lojistas_cubit.dart';
import '../modules/lojistas/bloc/lojista_form_cubit.dart';
import '../modules/subcategorias/services/subcategoria_service.dart';
import '../modules/subcategorias/bloc/subcategoria_cubit.dart';
import '../core/services/device_service.dart';
import '../core/services/fcm_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Device & FCM Services
  if (!getIt.isRegistered<DeviceService>()) {
    getIt.registerLazySingleton(() => DeviceService());
  }
  if (!getIt.isRegistered<FcmService>()) {
    getIt.registerLazySingleton(() => FcmService());
  }

  // Api Client
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton(() => ApiClient());
  }

  // Auth
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton(() => AuthRepository(
      getIt<ApiClient>(),
      getIt<DeviceService>(),
    ));
  }
  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory(() => AuthCubit(
      getIt<AuthRepository>(),
      getIt<ApiClient>(),
    ));
  }

  // Lojistas
  getIt.registerLazySingleton(() => LojistaService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => LojistaRepository(getIt<LojistaService>()));
  
  // Subcategorias
  getIt.registerLazySingleton(() => SubcategoriaService(getIt<ApiClient>()));
  
  // Factory cubits to ensure fresh state when navigating
  getIt.registerFactory(() => LojistasCubit(getIt<LojistaRepository>()));
  getIt.registerFactory(() => LojistaFormCubit(getIt<LojistaRepository>()));
  getIt.registerFactory(() => SubcategoriaCubit(getIt<SubcategoriaService>()));
}
