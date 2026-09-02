// lib/app/di/injection.dart

import 'package:get_it/get_it.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/services/token_service.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/repository/auth_repository.dart';
import '../modules/lojistas/services/lojista_service.dart';
import '../modules/lojistas/repositories/lojista_repository.dart';
import '../modules/lojistas/bloc/lojistas_cubit.dart';
import '../modules/lojistas/bloc/lojista_form_cubit.dart';
import '../modules/avaliacoes/services/avaliacao_service.dart';
import '../modules/avaliacoes/bloc/avaliacoes_cubit.dart';
import '../../shared/services/upload_service.dart';
import '../modules/subcategorias/services/subcategoria_service.dart';
import '../modules/subcategorias/bloc/subcategoria_cubit.dart';
import '../modules/clientes/bloc/clientes_cubit.dart';
import '../core/services/device_service.dart';
import '../core/services/fcm_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Token Service
  if (!getIt.isRegistered<TokenService>()) {
    getIt.registerLazySingleton(() => TokenService());
  }

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

  // 🔥 NOVO: Upload Service (depende do ApiClient)
  if (!getIt.isRegistered<UploadService>()) {
    getIt.registerLazySingleton(
          () => UploadService(getIt<ApiClient>()),
    );
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
      getIt<TokenService>(),
    ));
  }

  // Lojistas
  getIt.registerLazySingleton(() => LojistaService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => LojistaRepository(getIt<LojistaService>()));

  // Avaliações
  getIt.registerLazySingleton(() => AvaliacaoService(getIt<ApiClient>()));

  // Subcategorias
  getIt.registerLazySingleton(() => SubcategoriaService(getIt<ApiClient>()));

  // Factory cubits to ensure fresh state when navigating
  getIt.registerFactory(() => LojistasCubit(getIt<LojistaRepository>()));
  getIt.registerFactory(() => LojistaFormCubit(getIt<LojistaRepository>()));
  getIt.registerFactory(() => AvaliacoesCubit(getIt<AvaliacaoService>()));
  getIt.registerFactory(() => SubcategoriaCubit(getIt<SubcategoriaService>()));
  getIt.registerFactory(() => ClientesCubit(getIt<ApiClient>()));
}