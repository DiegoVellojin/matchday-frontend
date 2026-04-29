import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';

class UpdateUserProfileUseCase {
  final IProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call({
    String? name,
    String? phone,
    String? photoUrl,
    String? password,
  }) async {
    return await repository.updateUserProfile(
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      password: password,
    );
  }

}
