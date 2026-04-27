import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String name,
    String email,
    String password,
  ) async {
    return await repository.register(name, email, password);
  }
}
