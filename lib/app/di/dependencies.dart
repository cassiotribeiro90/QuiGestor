import 'package:get_it/get_it.dart';
import '../../../shared/api/api_client.dart';
import '../modules/lojistas/services/lojista_service.dart';
import '../modules/lojistas/repositories/lojista_repository.dart';
import '../modules/lojistas/bloc/lojistas_cubit.dart';
import '../modules/lojistas/bloc/lojista_form_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Api Client
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton(() => ApiClient());
  }

  // Lojistas
  getIt.registerLazySingleton(() => LojistaService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => LojistaRepository(getIt<LojistaService>()));
  
  // Factory cubits to ensure fresh state when navigating
  getIt.registerFactory(() => LojistasCubit(getIt<LojistaRepository>()));
  getIt.registerFactory(() => LojistaFormCubit(getIt<LojistaRepository>()));
}
