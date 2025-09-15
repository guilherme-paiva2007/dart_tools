import 'package:meta/meta.dart';

mixin class LimitedTimeUseClass {
  bool _activeValue = false;
  bool _inited = false;
  bool _disposed = false;

  bool get inited => _inited;
  bool get disposed => _disposed;

  set _active(bool value) {
    if (value == _activeValue) return;
    if (value) {
      
      if (_inited) throw StateError('Model is already initialized');
      _inited = true;
      _activeValue = true;

    } else {

      if (_disposed) throw StateError('Model is already disposed');
      _disposed = true;
      _activeValue = false;

    }
  }

  bool get active => _activeValue;

  @mustCallSuper
  void init() {
    if (_inited) {
      throw StateError('Model is already initialized');
    }
    _active = true;
  }

  @mustCallSuper
  void dispose() {
    if (_disposed) {
      throw StateError('Model is already disposed');
    }
    _active = false;
  }
}