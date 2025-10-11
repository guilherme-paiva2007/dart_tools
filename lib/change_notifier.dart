// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:dart_tools/utils/limited_time_use_class.dart';

typedef ListenerCallback<T> = void Function([T value]);

abstract class Listenable<T> with LimitedTimeUseClass {
  final Set<ListenerCallback<T>> _callbacks;

  Listenable([this._callbacks = const {}]) {
    init();
  }

  void addCallback(ListenerCallback<T> callback) {
    throwIfNotActive();
    _callbacks.add(callback);
  }

  void removeCallback(ListenerCallback<T> callback) {
    throwIfNotActive();
    _callbacks.add(callback);
  }

  void _notifyListeners(T value) {
    for (var callback in _callbacks) {
      callback(value);
    }
  }

  @override
  void dispose() {
    _callbacks.clear();
    super.dispose();
  }
}

mixin PublicListenable<T> on Listenable<T> {
  void notifyListeners(T value) => active ? _notifyListeners(value) : throwIfNotActive();
}

mixin _PrivateListenable<T> on Listenable<T> {
  ListenableController<T> get controller;
  
  @override
  void init() {
    controller.subscribe(this);
    super.init();
  }

  @override
  void dispose() {
    controller.unsubscribe(this);
    super.dispose();
  }
}

final class ListenableController<T> with LimitedTimeUseClass {
  final Set<_PrivateListenable<T>> _listenables = {};

  void update(T v, [ dynamic key ]) {
    throwIfNotActive();
    for (var listenable in _listenables) {
      listenable._notifyListeners(v);
    }
  }
  
  ListenableController() {
    init();
  }

  void subscribe(Listenable<T> listenable) => active ?
    (listenable is _PrivateListenable<T> ? _listenables.add(listenable) : null) :
    throwIfNotActive();

  void unsubscribe(Listenable<T> listenable) => active ? _listenables.remove(listenable) : throwIfNotActive();

  @override
  void dispose() {
    _listenables.clear();
    super.dispose();
  }
}

final class KeyedListenableController<T> extends ListenableController<T> {
  final String _key;
  
  KeyedListenableController(this._key);

  @override
  void update(T v, [covariant String? key]) {
    if (key == _key) {
      super.update(v, key);
    } else {
      throw StateError('Key mismatch for KeyedListenableController');
    }
  }

  static final Random _random = Random.secure();

  static String get randomKey => List.generate(16, (_) => _random.nextInt(256))
    .map((e) => e.toRadixString(16).padLeft(2, '0')).join(); 
}



abstract class ChangeNotifier<T> extends Listenable<T> {
  ChangeNotifier._();
}

abstract class PublicChangeNotifier<T> extends ChangeNotifier<T> with PublicListenable<T> {
  PublicChangeNotifier(): super._();
}

/// To protect the controller, it's recommended to create an static private key.
abstract class PrivateChangeNotifier<T> extends ChangeNotifier<T> with _PrivateListenable<T> {
  @override
  final KeyedListenableController<T> controller;

  PrivateChangeNotifier(this.controller): super._();
}

abstract final class ValueNotifier<T> extends Listenable<T> {
  late T _value;
  T get value => _value;

  ValueNotifier._([T? initValue]) {
    if (initValue != null) {
      _value = initValue;
    }
  }

  factory ValueNotifier({
    T? initValue,
    ListenableController<T>? controller
  }) => controller == null ? PublicValueNotifier(initValue) : PrivateValueNotifier(controller, initValue);
}

final class PublicValueNotifier<T> extends ValueNotifier<T> with PublicListenable<T> {
  PublicValueNotifier([super.initValue]): super._();

  set value(T v) => _notifyListeners(_value = v);

  @override
  void notifyListeners(T value) => _notifyListeners(value);
}

final class PrivateValueNotifier<T> extends ValueNotifier<T> with _PrivateListenable<T> {
  @override
  final ListenableController<T> controller;
  
  @override
  void _notifyListeners(T value) {
    _value = value;
    super._notifyListeners(value);
  }

  PrivateValueNotifier(this.controller, [T? initValue]): super._(initValue);
}