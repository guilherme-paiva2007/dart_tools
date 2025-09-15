import 'dart:collection';

final class Warning<C extends WarningCode> {
  final String? message;
  final C code;

  const Warning(this.code, [this.message]);

  String _baseToString() => "$code ${message ?? code.explanation}";

  @override
  String toString() => "Warning(${_baseToString()})";
}

abstract interface class WarningCode {
  String get explanation;
}

final class WarningList<C extends WarningCode> extends Warning<C> with ListMixin<Warning> {
  final List<Warning> subWarnings;

  WarningList(super.code, this.subWarnings, [super.message]): super();

  @override
  int get length => subWarnings.length;
  @override
  set length(int newLength) {
    subWarnings.length = newLength;
  }
  @override
  Warning operator [](int index) => subWarnings[index];
  @override
  void operator []=(int index, Warning value) {
    subWarnings[index] = value;
  }

  @override String toString() => "WarningList(${_baseToString()}: [${join(", ")}])";
}

final class WarningMap<C extends WarningCode, K> extends Warning<C> with MapMixin<K, Warning> {
  final Map<K, Warning> subWarnings;

  WarningMap(super.code, this.subWarnings, [super.message]): super();

  @override
  Warning? operator [](Object? key) => subWarnings[key];
  @override
  void operator []=(K key, Warning value) {
    subWarnings[key] = value;
  }
  @override
  void clear() => subWarnings.clear();
  @override
  Iterable<K> get keys => subWarnings.keys;
  @override
  Warning? remove(Object? key) => subWarnings.remove(key);

  @override String toString() => "WarningMap(${_baseToString()}: {${entries.map(_map).join(", ")}})";

  static String _map<K, C extends WarningCode>(MapEntry<K, Warning<C>> e) => "${e.key}: ${e.value}";
}