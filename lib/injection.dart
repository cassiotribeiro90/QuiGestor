import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'features/loja/bloc/loja_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'shared/api/api_client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  
  // API Client
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Theme Cubit
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(getIt<SharedPreferences>()));
  
  // Auth Cubit
  getIt.registerSingleton<AuthCubit>(AuthCubit(
    getIt<ApiClient>(),
    getIt<SharedPreferences>(),
  ));

  // Loja Cubit
  getIt.registerFactory<LojaCubit>(() => LojaCubit(
    getIt<ApiClient>(),
  ));
}
