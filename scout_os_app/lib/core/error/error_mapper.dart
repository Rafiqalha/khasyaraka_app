import 'package:dio/dio.dart';
import 'failures.dart';

class ErrorMapper {
  static Failure mapDioExceptionToFailure(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure();
    }
    
    if (exception.type == DioExceptionType.connectionError) {
      return const OfflineFailure();
    }

    if (exception.response != null) {
      final statusCode = exception.response!.statusCode;
      switch (statusCode) {
        case 400:
          return const ValidationFailure();
        case 401:
          return const AuthenticationFailure();
        case 403:
          return const PermissionFailure();
        case 404:
          return const NotFoundFailure();
        case 409:
          return const ConflictFailure();
        case 422:
          return const SubmissionFailure();
        case 429:
          return const RateLimitFailure();
        case 500:
        case 502:
        case 503:
        case 504:
          return const ServerFailure();
        default:
          return const ServerFailure("Unknown error occurred");
      }
    }

    return const ServerFailure("Unknown error occurred");
  }
}
