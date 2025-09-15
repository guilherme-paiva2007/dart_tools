sealed class Result<S,F> {
  S? get result;
  F? get failure;

  const Result();
}

final class Success<S,F> extends Result<S,F> {
  @override
  final S result;
  @override
  Null get failure => null;

  const Success(this.result);
}

final class Failure<S,F> extends Result<S,F> {
  @override
  Null get result => null;
  @override
  final F failure;

  const Failure(this.failure);
}