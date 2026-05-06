import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service_locator.dart';
import '../../network/network_robot.dart';
import '../../storage/secure_storage_service.dart';
import '../../storage/firebase_storage_service.dart';

Future<void> initCore() async {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(),
  );
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl()),
  );

  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<NetworkRobot>(() => NetworkRobot(sl(), sl()));
}
