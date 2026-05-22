import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../application/usecases/get_user_profile_usecase.dart';
import '../../application/usecases/update_user_profile_usecase.dart';

import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC responsable de gestionar la información y acciones del perfil del usuario.
///
/// Interviene en la visualización, actualización de datos y el cierre de sesión,
/// delegando la persistencia y la lógica a los Casos de Uso.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final SecureStorageService secureStorageService;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.secureStorageService,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());

      final profileResult = await getUserProfileUseCase();

      await profileResult.fold((failure) async {
        if (_shouldForceLogout(failure.message)) {
          await secureStorageService.deleteToken();
          emit(LogoutSuccess());
          return;
        }
        emit(ProfileError(message: failure.message));
      }, (profile) async => emit(ProfileLoaded(profile: profile)));
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileUpdating());
      final result = await updateUserProfileUseCase(
        name: event.name,
        phone: event.phone,
        photoUrl: event.photoUrl,
        password: event.password,
      );

      await result.fold(
        (failure) async {
          if (_shouldForceLogout(failure.message)) {
            await secureStorageService.deleteToken();
            emit(LogoutSuccess());
            return;
          }
          emit(ProfileError(message: failure.message));
        },
        (profile) async {
          emit(ProfileUpdateSuccess(profile));
          add(LoadProfileEvent());
        },
      );
    });
    on<LogoutEvent>((event, emit) async {
      await secureStorageService.deleteToken();
      emit(ProfileInitial()); // Limpiamos el estado del perfil
      emit(LogoutSuccess());
    });
  }

  bool _shouldForceLogout(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('token expirado') ||
        normalized.contains('expired token') ||
        normalized.contains('token expired') ||
        normalized.contains('401');
  }
}
