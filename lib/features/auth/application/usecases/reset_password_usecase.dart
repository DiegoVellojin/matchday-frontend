import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final IAuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String token, String newPassword) async {
    return await repository.resetPassword(token, newPassword);
  }
}
