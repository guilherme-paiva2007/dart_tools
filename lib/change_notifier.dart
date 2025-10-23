// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:dart_tools/utils/limited_time_use_class.dart';

typedef ListenerCallback<T> = void Function([T value]);

abstract base class Listenable<L extends Listener> {
  L get listener;
}

abstract base class Listener<T> with LimitedTimeUseClass implements Listenable<Listener<T>> {
  @override
  Listener<T> get listener => this;
  
  final Set<ListenerCallback<T>> _callbacks;

  Listener([this._callbacks = const {}]) {
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

base mixin PublicListener<T> on Listener<T> {
  void notifyListeners(T value) => active ? _notifyListeners(value) : throwIfNotActive();
}

base mixin _PrivateListener<T> on Listener<T> {
  ListenerController<T> get controller;
  
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

final class ListenerController<T> with LimitedTimeUseClass {
  final Set<_PrivateListener<T>> _listeners = {};

  void update(T v, [ dynamic key ]) {
    throwIfNotActive();
    for (var listener in _listeners) {
      listener._notifyListeners(v);
    }
  }
  
  ListenerController() {
    init();
  }

  void subscribe(Listener<T> listener) => active ?
    (listener is _PrivateListener<T> ? _listeners.add(listener) : null) :
    throwIfNotActive();

  void unsubscribe(Listener<T> listener) => active ? _listeners.remove(listener) : throwIfNotActive();

  @override
  void dispose() {
    _listeners.clear();
    super.dispose();
  }
}

final class KeyedListenerController<T> extends ListenerController<T> {
  final String _key;
  
  KeyedListenerController(this._key);

  @override
  void update(T v, [covariant String? key]) {
    if (key == _key) {
      super.update(v, key);
    } else {
      throw StateError('Key mismatch for KeyedListenerController');
    }
  }

  static final Random _random = Random.secure();

  static String get randomKey => List.generate(16, (_) => _random.nextInt(256))
    .map((e) => e.toRadixString(16).padLeft(2, '0')).join(); 
}



abstract base class ChangeNotifier<T> extends Listener<T> {
  @override
  ChangeNotifier<T> get listener => this;

  ChangeNotifier._();
}

abstract base class PublicChangeNotifier<T> extends ChangeNotifier<T> with PublicListener<T> {
  @override
  PublicChangeNotifier<T> get listener => this;

  PublicChangeNotifier(): super._();
}

/// To protect the controller, it's recommended to create an static private key.
abstract base class PrivateChangeNotifier<T> extends ChangeNotifier<T> with _PrivateListener<T> {
  @override
  PrivateChangeNotifier<T> get listener => this;

  @override
  final KeyedListenerController<T> controller;

  PrivateChangeNotifier(this.controller): super._();
}

sealed class ValueNotifier<T> extends Listener<T> {
  @override
  ValueNotifier<T> get listener => this;
  
  late T _value;
  T get value => _value;

  ValueNotifier._([T? initValue]) {
    if (initValue != null) {
      _value = initValue;
    }
  }

  factory ValueNotifier({
    T? initValue,
    ListenerController<T>? controller
  }) => controller == null ? PublicValueNotifier(initValue) : PrivateValueNotifier(controller, initValue);
}

final class PublicValueNotifier<T> extends ValueNotifier<T> with PublicListener<T> {
  @override 
  PublicValueNotifier<T> get listener => this;

  PublicValueNotifier([super.initValue]): super._();

  set value(T v) => _notifyListeners(_value = v);

  @override
  void notifyListeners(T value) => _notifyListeners(value);
}

final class PrivateValueNotifier<T> extends ValueNotifier<T> with _PrivateListener<T> {
  @override
  PrivateValueNotifier<T> get listener => this;

  @override
  final ListenerController<T> controller;
  
  @override
  void _notifyListeners(T value) {
    _value = value;
    super._notifyListeners(value);
  }

  PrivateValueNotifier(this.controller, [T? initValue]): super._(initValue);
}