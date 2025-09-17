part of '../features.dart';

abstract base class Model<M extends Model<M>> with LimitedTimeUseClass {
  final HashSet<Repository<M>> _repositories = HashSet();
  final List<ModelUpdate<M>> _updates = [];

  @mustCallSuper
  final Id $id;

  @mustCallSuper
  ModelUpdate<M>? get $lastUpdate => _updates.isNotEmpty ? _updates.last : null;

  Model(this.$id) {
    init();
  }

  @override void dispose() {
    super.dispose();
    for (var repo in _repositories) {
      repo.remove(this as M);
    }
  }
}

abstract class ModelUpdate<M extends Model<M>> {
  final Id id;

  ModelUpdate(this.id);

  @mustCallSuper
  void update(M instance) {
    if (!instance.inited) throw StateError('Model is not initialized');
    if (instance.disposed) throw StateError('Model is already disposed');
    if (instance.$id != id) {
      throw ArgumentError('Update id $id does not match instance id ${instance.$id}');
    }
    instance._updates.add(this);
    _updateLastUse(instance);
    _callUpdateProviders(instance);
    changeData(instance);
  }

  @mustCallSuper
  void _updateLastUse(M instance) {
    for (var repo in instance._repositories) {
      final item = repo._instances[instance.$id];
      if (item != null) {
        item.reuse();
      }
    }
  }

  @mustCallSuper
  void _callUpdateProviders(M instance) {
    for (var repo in instance._repositories) {
      for (var provider in repo._providers) {
        for (var callback in provider._listeners._updateCallbacks) {
          callback(instance);
        }
      }
    }
  }

  @mustBeOverridden
  void changeData(M instance);
}

final class Id {
  late final List<String> parts;
  late final String _string;

  Id(List<String> parts) {
    if (parts.isEmpty) throw StateError("Id cannot be empty");
    this.parts = List.unmodifiable(parts);
    _string = parts.join(".");
  }

  factory Id.fromString(String str) {
    if (str.isEmpty) throw Exception("Id string cannot be empty");
    return Id(str.split('.'));
  }

  @override
  String toString() => _string;

  @override
  int get hashCode => _string.hashCode;

  @override
  bool operator ==(Object other) => other is Id && _string == other._string;
}