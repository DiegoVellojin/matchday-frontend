abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class LogoutEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? phone;
  final String? photoUrl;
  final String? password;

  UpdateProfileEvent({this.name, this.phone, this.photoUrl, this.password});
}


