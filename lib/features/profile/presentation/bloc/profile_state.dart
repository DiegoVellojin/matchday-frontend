import '../../domain/entities/profile_entity.dart';

abstract class ProfileState {}


class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;

  ProfileLoaded({required this.profile});
}


class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}

class LogoutSuccess extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final UserProfileEntity profile;
  ProfileUpdateSuccess(this.profile);
}

