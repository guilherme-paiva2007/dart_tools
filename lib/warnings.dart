import 'dart:collection';

import 'package:dart_tools/change_notifier.dart';

final class Warning<C extends WarningCode> {
  final StackTrace stackTrace;
  final String? message;
  final C code;

  Warning(this.code, [this.message]): stackTrace = StackTrace.current;

  String _baseToString() => "$code ${message ?? code.explanation}";

  @override
  String toString() => "Warning(${_baseToString()})";

  static final GlobalWarningNotifier global = GlobalWarningNotifier();
}

abstract interface class WarningCode {
  String get explanation;
}

final class WarningList<C extends WarningCode> extends Warning<C> with ListMixin<Warning<C>> {
  late final List<Warning<C>> subWarnings;

  WarningList(super.code, Iterable<Warning<C>> subWarnings, [super.message]): super() {
    this.subWarnings = List<Warning<C>>.from(subWarnings);
  }

  @override
  int get length => subWarnings.length;
  @override
  set length(int newLength) {
    subWarnings.length = newLength;
  }
  @override
  Warning<C> operator [](int index) => subWarnings[index];
  @override
  void operator []=(int index, Warning<C> value) {
    subWarnings[index] = value;
  }

  @override
  void add(Warning<C> element) => subWarnings.add(element);
  @override
  Warning<C> removeAt(int index) => subWarnings.removeAt(index);

  @override String toString() => "WarningList(${_baseToString()}: [${join(", ")}])";
}

final class WarningMap<C extends WarningCode, K> extends Warning<C> with MapMixin<K, Warning<C>> {
  final Map<K, Warning<C>> subWarnings;

  WarningMap(super.code, this.subWarnings, [super.message]): super();

  @override
  Warning<C>? operator [](Object? key) => subWarnings[key];
  @override
  void operator []=(K key, Warning<C> value) {
    subWarnings[key] = value;
  }
  @override
  void clear() => subWarnings.clear();
  @override
  Iterable<K> get keys => subWarnings.keys;
  @override
  Warning<C>? remove(Object? key) => subWarnings.remove(key);

  @override String toString() => "WarningMap(${_baseToString()}: {${entries.map(_map).join(", ")}})";

  static String _map<K, C extends WarningCode>(MapEntry<K, Warning<C>> e) => "${e.key}: ${e.value}";
}

sealed class WarningNotifier<C extends WarningCode> {
  factory WarningNotifier() = _PrivateWarningNotifier;

  void log(Warning<C> warning);
}

final class GlobalWarningNotifier<C extends WarningCode> extends PublicChangeNotifier<Warning<C>> implements WarningNotifier<C> {
  final List<Warning<C>> _warnings = [];
  late final List<Warning<C>> warnings;

  GlobalWarningNotifier() {
    warnings = UnmodifiableListView(_warnings);
  }

  @override
  void log(Warning<C> warning) {
    _warnings.add(warning);
    notifyListeners(warning);
  }
}

final class _PrivateWarningNotifier<C extends WarningCode> extends PrivateChangeNotifier<Warning<C>> implements WarningNotifier<C> {
  final List<Warning<C>> _warnings = [];
  late final List<Warning<C>> warnings;

  _PrivateWarningNotifier(): super( KeyedListenerController(_key) ) {
    warnings = UnmodifiableListView(_warnings);
  }

  @override
  void log(Warning<C> warning) {
    _warnings.add(warning);
    controller.update(warning, _key);
  }

  static final String _key = KeyedListenerController.randomKey;
}