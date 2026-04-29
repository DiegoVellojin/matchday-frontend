import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../application/usecases/get_user_profile_usecase.dart';
import '../../application/usecases/get_my_teams_usecase.dart';
import '../../application/usecases/update_user_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetMyTeamsUseCase getMyTeamsUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final SecureStorageService secureStorageService;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.getMyTeamsUseCase,
    required this.updateUserProfileUseCase,
    required this.secureStorageService,
  }) : super(ProfileInitial()) {

    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      
      final profileResult = await getUserProfileUseCase();
      final teamsResult = await getMyTeamsUseCase();

      profileResult.fold(
        (failure) => emit(ProfileError(message: failure.message)),
        (profile) {
          teamsResult.fold(
            (failure) => emit(ProfileError(message: failure.message)),
            (teams) => emit(ProfileLoaded(profile: profile, teams: teams)),
          );
        },
      );
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileUpdating());
      final result = await updateUserProfileUseCase(
        name: event.name,
        phone: event.phone,
        photoUrl: event.photoUrl,
        password: event.password,
      );

      result.fold(
        (failure) => emit(ProfileError(message: failure.message)),
        (profile) {
          emit(ProfileUpdateSuccess(profile));
          add(LoadProfileEvent());
        },
      );
    });
    on<LogoutEvent>((event, emit) async {
      await secureStorageService.deleteToken();
      emit(LogoutSuccess());
    });
  }
}


