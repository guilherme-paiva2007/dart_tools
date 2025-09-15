final class Rule<T extends Object> {
  final List<RuleCondition<T>> conditions;

  const Rule(this.conditions);

  bool validate(T value) {
    for (var condition in conditions) {
      if (!condition.function(value)) return false;
    }
    return true;
  }

  String? firstError(T value) {
    for (var condition in conditions) {
      if (!condition.function(value)) return condition.errorMessage;
    }
    return null;
  }

  List<String> errors(T value) {
    final List<String> errors = [];
    for (var condition in conditions) {
      if (!condition.function(value)) errors.add(condition.errorMessage);
    }
    return errors;
  }
}

final class RuleCondition<T extends Object> {
  final bool Function(T value) function;
  final String errorMessage;

  const RuleCondition({
    required this.function,
    required this.errorMessage,
  });
}