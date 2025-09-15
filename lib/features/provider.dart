part of '../features.dart';

abstract base class Provider<M extends Model<M>> with LimitedTimeUseClass {
  final ProviderListeners<M> _listeners = ProviderListeners._();
  final HashSet<Repository<M>> _repositories = HashSet();

  Provider() {
    init();
  }

  @override
  void dispose() {
    super.dispose();
    _listeners._addCallbacks.clear();
    _listeners._removeCallbacks.clear();
    _listeners._updateCallbacks.clear();
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
        _listeners._addCallbacks.add(callback);
        break;
      case InstanceEvent.remove:
        _listeners._removeCallbacks.add(callback);
        break;
      case InstanceEvent.update:
        _listeners._updateCallbacks.add(callback);
        break;
    }
  }

  @mustCallSuper
  void removeListener(InstanceEvent event, ProviderListenerCallback<M> callback) {
    if (!active) {
      throw StateError('Provider is not active');
    }
    switch (event) {
      case InstanceEvent.add:
        _listeners._addCallbacks.remove(callback);
        break;
      case InstanceEvent.remove:
        _listeners._removeCallbacks.remove(callback);
        break;
      case InstanceEvent.update:
        _listeners._updateCallbacks.remove(callback);
        break;
    }
  }
}

enum InstanceEvent {
  add,
  remove,
  update;
}

final class ProviderListeners<M extends Model<M>> {
  final HashSet<ProviderListenerCallback<M>> _addCallbacks = HashSet();
  final HashSet<ProviderListenerCallback<M>> _removeCallbacks = HashSet();
  final HashSet<ProviderListenerCallback<M>> _updateCallbacks = HashSet();

  ProviderListeners._();
}

typedef ProviderListenerCallback<M extends Model<M>> = void Function(M instance);