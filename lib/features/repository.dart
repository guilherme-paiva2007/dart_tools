part of '../features.dart';

abstract base class Repository<M extends Model<M>> with LimitedTimeUseClass {
  final HashMap<Id, _RepositoryItem<M>> _instances = HashMap();
  final HashSet<Provider<M>> _providers = HashSet();
  final HashSet<Service<M>> _services = HashSet();

  Repository() {
    init();
  }

  @override
  void dispose() {
    super.dispose();
    for (var provider in _providers) {
      provider._repositories.remove(this);
    }
    _providers.clear();
    for (var item in _instances.values) {
      item.instance._$repositories.remove(this);
    }
    _instances.clear();
    for (var service in _services) {
      service._repositories.remove(this);
    }
    _services.clear();
  }

  @mustCallSuper
  M? get(Id id) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    final item = _instances[id];
    if (item != null) {
      item.reuse();
      return item.instance;
    }
    return null;
  }

  @mustCallSuper
  void add(M instance) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    if (_instances.containsKey(instance.$id)) {
      throw StateError('Instance with id ${instance.$id} already exists');
    }
    if (!instance.inited) {
      throw StateError('Cannot add uninitialized instance with id ${instance.$id}');
    }
    if (instance.disposed) {
      throw StateError('Cannot add disposed instance with id ${instance.$id}');
    }
    _saveInstance(instance);
    _callAddProviders(instance);
  }

  @mustCallSuper
  void _saveInstance(M instance) {
    _instances[instance.$id] = _RepositoryItem(instance);
    instance._$repositories.add(this);
  }

  @mustCallSuper
  void _callAddProviders(M instance) {
    for (var provider in _providers) {
      for (var callback in provider._listeners.addCallbacks) {
        callback(instance);
      }
    }
  }

  @mustCallSuper
  void remove(M instance) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    if (!_instances.containsKey(instance.$id)) {
      throw StateError('Instance with id ${instance.$id} does not exist');
    }
    _removeInstance(instance);
    _callRemoveProviders(instance);
  }

  @mustCallSuper
  void removeId(Id id) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    final item = _instances[id];
    if (item == null) {
      throw StateError('Instance with id $id does not exist');
    }
    _removeInstance(item.instance);
    _callRemoveProviders(item.instance);
  }

  @mustCallSuper
  void _removeInstance(M instance) {
    _instances.remove(instance.$id);
    instance._$repositories.remove(this);
  }

  @mustCallSuper
  void _removeMultipleInstances(
    bool Function(Id, _RepositoryItem<M>) verifier,
    [bool callRemoveOnProviders = false]
  ) {
    final removed = <M>[];
    _instances.removeWhere((id, item) {
      if (verifier(id, item)) {
        removed.add(item.instance);
        item.instance._$repositories.remove(this);
        return true;
      }
      return false;
    });
    if (callRemoveOnProviders) {
      for (var instance in removed) {
        _callRemoveProviders(instance);
      }
    }
  }

  @mustCallSuper
  void _callRemoveProviders(M instance) {
    for (var provider in _providers) {
      for (var callback in provider._listeners.removeCallbacks) {
        callback(instance);
      }
    }
  }

  @mustCallSuper
  void addProvider(Provider<M> provider) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    if (!provider.active) {
      throw StateError('Cannot add inactive provider');
    }
    _providers.add(provider);
    provider._repositories.add(this);
  }

  @mustCallSuper
  void removeProvider(Provider<M> provider) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    _providers.remove(provider);
    provider._repositories.remove(this);
  }

  @mustCallSuper
  void subscribe(Service<M> service) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    _services.add(service);
    service._repositories.add(this);
  }

  @mustCallSuper
  void unsubscribe(Service<M> service) {
    if (!active) {
      throw StateError('Repository is not active');
    }
    _services.remove(service);
    service._repositories.remove(this);
  }
}

final class _RepositoryItem<M extends Model<M>> {
  final M instance;
  DateTime lastUse;

  _RepositoryItem(this.instance) : lastUse = DateTime.now();

  void reuse() => lastUse = DateTime.now();
}