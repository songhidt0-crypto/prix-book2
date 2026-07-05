import 'package:equatable/equatable.dart';

/// Base failure class for all domain errors
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Validation failures (user input errors)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Database constraint failures (unique, FK violations)
class DatabaseConstraintFailure extends Failure {
  const DatabaseConstraintFailure(super.message);
}

/// Database I/O failures (write errors, disk full)
class DatabaseWriteFailure extends Failure {
  const DatabaseWriteFailure(super.message);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Generic unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// App exception — used in data layer
class AppException implements Exception {
  final String message;
  final AppExceptionType type;

  const AppException({
    required this.message,
    this.type = AppExceptionType.unexpected,
  });

  @override
  String toString() => 'AppException[$type]: $message';
}

enum AppExceptionType {
  validation,
  dbConstraint,
  dbWrite,
  notFound,
  unexpected,
}

extension AppExceptionToFailure on AppException {
  Failure toFailure() {
    switch (type) {
      case AppExceptionType.validation:
        return ValidationFailure(message);
      case AppExceptionType.dbConstraint:
        return DatabaseConstraintFailure(message);
      case AppExceptionType.dbWrite:
        return DatabaseWriteFailure(message);
      case AppExceptionType.notFound:
        return NotFoundFailure(message);
      case AppExceptionType.unexpected:
        return UnexpectedFailure(message);
    }
  }
}
