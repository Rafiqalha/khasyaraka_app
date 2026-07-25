sealed class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class RetryableFailure extends Failure {
  const RetryableFailure(super.message);
}

class FatalFailure extends Failure {
  const FatalFailure(super.message);
}

class OfflineFailure extends Failure {
  const OfflineFailure([String message = "No internet connection"]) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = "Invalid request"]);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = "Session expired"]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = "Access denied"]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = "Resource not found"]);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = "Resource conflict"]);
}

class SubmissionFailure extends Failure {
  const SubmissionFailure([super.message = "Unprocessable entity"]);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = "Too many requests"]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = "Internal server error"]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "Network connection timeout or failure"]);
}
