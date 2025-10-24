part of '../features.dart';

base class Repository<M extends Model<M>> with LimitedTimeUseClass {
  final HashMap<int, RepositoryItem<M>> _instances = HashMap();
  final HashSet<Provider<M>> _providers = HashSet();
  final HashSet<Service<M>> _services = HashSet();

  late final RepositoryView<M> instances;

  Repository() {
    init();
    instances = RepositoryView<M>(this);
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
    final item = _instances[id._hashCode];
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
    if (_instances.containsKey(instance.$id._hashCode)) {
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
    _instances[instance.$id._hashCode] = RepositoryItem._(instance);
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
    if (!_instances.containsKey(instance.$id._hashCode)) {
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
    final item = _instances[id._hashCode];
    if (item == null) {
      throw StateError('Instance with id $id does not exist');
    }
    _removeInstance(item.instance);
    _callRemoveProviders(item.instance);
  }

  @mustCallSuper
  void _removeInstance(M instance) {
    _instances.remove(instance.$id._hashCode);
    instance._$repositories.remove(this);
  }

  @mustCallSuper
  void _removeMultipleInstances(
    bool Function(int, RepositoryItem<M>) verifier,
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

  Iterable<RepositoryItem<M>> get values => _instances.values;
}

final class RepositoryItem<M extends Model<M>> {
  final M instance;
  DateTime _lastUse;

  DateTime get lastUse => _lastUse;

  RepositoryItem._(this.instance) : _lastUse = DateTime.now();

  void reuse() => _lastUse = DateTime.now();
}

final class RepositoryView<M extends Model<M>> extends MapMixin<Id, RepositoryItem<M>> {
  final Repository<M> _repository;

  RepositoryView(this._repository);

  @override
  RepositoryItem<M>? operator [](Object? key) {
    if (key is! Id) return null;
    return _repository._instances[key._hashCode];
  }

  @override
  void operator []=(Id key, RepositoryItem<M> value) {
    throw UnsupportedError('Cannot modify RepositoryView');
  }

  @override
  void clear() {
    throw UnsupportedError('Cannot modify RepositoryView');
  }

  @override
  Iterable<Id> get keys => _repository._instances.keys.map((hash) {
    final item = _repository._instances[hash]!;
    return item.instance.$id;
  });

  @override
  RepositoryItem<M>? remove(Object? key) {
    throw UnsupportedError('Cannot modify RepositoryView');
  }

  @override
  int get length => _repository._instances.length;
}