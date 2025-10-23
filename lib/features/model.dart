part of '../features.dart';

abstract base class Model<M extends Model<M>> with LimitedTimeUseClass {
  final HashSet<Repository<M>> _$repositories = HashSet();
  final List<ModelUpdate<M>> _$updates = [];

  @mustCallSuper
  final Id $id;

  @mustCallSuper
  ModelUpdate<M>? get $lastUpdate => _$updates.isNotEmpty ? _$updates.last : null;

  Model(this.$id) {
    init();
  }

  @override void dispose() {
    super.dispose();
    for (var repo in _$repositories) {
      repo.remove(this as M);
    }
  }
}

abstract class ModelUpdate<M extends Model<M>> {
  final Id $id;

  ModelUpdate(this.$id);

  @mustCallSuper
  Result<M, Warning> update(M instance) {
    if (!instance.inited) throw StateError('Model is not initialized');
    if (instance.disposed) throw StateError('Model is already disposed');
    if (instance.$id != $id) {
      return Failure(Warning(
        FeatureWarningCodes.unmatchId,
        'Trying to update model with id ${instance.$id} using update with id ${$id}',
      ));
    }
    instance._$updates.add(this);
    _updateLastUse(instance);
    _callUpdateProviders(instance);
    return changeData(instance);
  }

  @mustCallSuper
  void _updateLastUse(M instance) {
    for (var repo in instance._$repositories) {
      final item = repo._instances[instance.$id];
      if (item != null) {
        item.reuse();
      }
    }
  }

  @mustCallSuper
  void _callUpdateProviders(M instance) {
    for (var repo in instance._$repositories) {
      for (var provider in repo._providers) {
        for (var callback in provider._listeners.updateCallbacks) {
          callback(instance);
        }
      }
    }
  }

  @mustBeOverridden
  Result<M, Warning> changeData(M instance);
}

sealed class Id<T extends Object> {
  factory Id.part(List<T> parts) = PartId;
}

final class PartId<T extends Object> implements Id<T> {
  late final List<T> parts;
  late final String _string;

  PartId(List<T> parts): assert(parts.isNotEmpty, "Parts cannot be empty") {
    if (parts.isEmpty) throw StateError("Id cannot be empty");
    this.parts = List<T>.unmodifiable(parts);
    _string = parts.join(".");
  }

  @override
  String toString() => _string;

  @override
  int get hashCode => _string.hashCode;

  @override
  bool operator ==(Object other) => other is PartId && _string == other._string;
}