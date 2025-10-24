part of '../features.dart';

base class Provider<M extends Model<M>> with LimitedTimeUseClass {
  final _ProviderListeners<M> _listeners = _ProviderListeners._();
  final HashSet<Repository<M>> _repositories = HashSet();

  Provider() {
    init();
  }

  @override
  void dispose() {
    super.dispose();
    _listeners.clear();
    for (var repo in _repositories) {
      repo._providers.remove(this);
    }
  }

  @mustCallSuper
  void addListener(InstanceEvent event, ProviderListenerCallback<M> callback) {
    if (!active) {
      throw StateError('Provider is not active');
    }
    switch (event) {
      case InstanceEvent.add:
        _listeners.addCallbacks.add(callback);
        break;
      case InstanceEvent.remove:
        _listeners.removeCallbacks.add(callback);
        break;
      case InstanceEvent.update:
        _listeners.updateCallbacks.add(callback);
        break;
    }
  }

  @mustCallSuper
  void addAllListener(ProviderListenerCallback<M> callback) {
    if (!active) {
      throw StateError('Provider is not active');
    }
    _listeners.addCallbacks.add(callback);
    _listeners.removeCallbacks.add(callback);
    _listeners.updateCallbacks.add(callback);
  }

  @mustCallSuper
  void removeListener(InstanceEvent event, ProviderListenerCallback<M> callback) {
    if (!active) {
      throw StateError('Provider is not active');
    }
    switch (event) {
      case InstanceEvent.add:
        _listeners.addCallbacks.remove(callback);
        break;
      case InstanceEvent.remove:
        _listeners.removeCallbacks.remove(callback);
        break;
      case InstanceEvent.update:
        _listeners.updateCallbacks.remove(callback);
        break;
    }
  }

  @mustCallSuper
  void removeAllListener(ProviderListenerCallback<M> callback) {
    if (!active) {
      throw StateError('Provider is not active');
    }
    _listeners.addCallbacks.remove(callback);
    _listeners.removeCallbacks.remove(callback);
    _listeners.updateCallbacks.remove(callback);
  }
}

enum InstanceEvent {
  add,
  remove,
  update;
}

final class _ProviderListeners<M extends Model<M>> {
  final HashSet<ProviderListenerCallback<M>> addCallbacks = HashSet();
  final HashSet<ProviderListenerCallback<M>> removeCallbacks = HashSet();
  final HashSet<ProviderListenerCallback<M>> updateCallbacks = HashSet();

  _ProviderListeners._();

  void clear() {
    addCallbacks.clear();
    removeCallbacks.clear();
    updateCallbacks.clear();
  }
}

typedef ProviderListenerCallback<M extends Model<M>> = void Function(M instance);