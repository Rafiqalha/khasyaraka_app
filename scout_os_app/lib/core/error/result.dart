/// A functional approach to error handling to replace try-catch in UI logic.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => isSuccess ? (this as Success<T>).value : null;
  Exception? get errorOrNull => isFailure ? (this as Failure<T>).error : null;

  R fold<R>(
    R Function(T value) onSuccess,
    R Function(Exception error, StackTrace? stackTrace) onFailure,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).value);
    } else if (this is Failure<T>) {
      final failure = this as Failure<T>;
      return onFailure(failure.error, failure.stackTrace);
    }
    throw StateError('Unknown Result type');
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final Exception error;
  final StackTrace? stackTrace;
  const Failure(this.error, [this.stackTrace]);
}
