import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/talhao_repository.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/auth_firebase_service.dart';
import '../data/services/talhao_service.dart';
import '../data/services/weather_service.dart';
import '../presentation/view_models/login_view_model.dart';
import '../presentation/view_models/registration_view_model.dart';
import '../presentation/view_models/home_view_model.dart';

final getIt = GetIt.instance;

void setupDependencyInjections() {
  // Firebase Instances
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Services
  getIt.registerLazySingleton(() => AuthFirebaseService(getIt<FirebaseAuth>()));
  getIt.registerLazySingleton(() => TalhaoService(getIt<FirebaseFirestore>()));
  getIt.registerLazySingleton(() => WeatherService());

  // Repositories
  getIt.registerLazySingleton(() => AuthRepository(getIt<AuthFirebaseService>()));
  getIt.registerLazySingleton(() => TalhaoRepository(getIt<TalhaoService>()));
  getIt.registerLazySingleton(() => WeatherRepository(getIt<WeatherService>()));

  // ViewModels
  getIt.registerFactory(() => LoginViewModel(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegistrationViewModel(getIt<AuthRepository>()));
  getIt.registerFactory(() => HomeViewModel(
        getIt<TalhaoRepository>(),
        getIt<WeatherRepository>(),
        getIt<FirebaseAuth>(),
      ));
}
