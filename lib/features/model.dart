part of '../features.dart';

abstract base class Model<M extends Model<M>> with LimitedTimeUseClass {
  final HashSet<Repository<M>> _$repositories = HashSet();
  final List<ModelUpdate<M>> _$updates = [];

  UnmodifiableListView<ModelUpdate<M>> get $updates => UnmodifiableListView(_$updates);

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

  static bool registerUpdates = true;
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
    if (Model.registerUpdates) instance._$updates.add(this);
    _updateLastUse(instance);
    final result = changeData(instance);
    _callUpdateProviders(instance);
    return result;
  }

  @mustCallSuper
  void _updateLastUse(M instance) {
    for (var repo in instance._$repositories) {
      final item = repo._instances[instance.$id._hashCode];
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
  Id._();

  factory Id.part(List<T> parts) = PartId;

  @override
  bool operator ==(Object other) => _compare(other);

  @override
  int get hashCode => _hashCode;

  int get _hashCode;

  bool _compare(Object other);
}

final class PartId<T extends Object> extends Id<T> {
  late final List<T> parts;
  late final String _string;

  String get string => _string;

  PartId(List<T> parts): assert(parts.isNotEmpty, "Parts cannot be empty"), super._() {
    if (parts.isEmpty) throw StateError("Id cannot be empty");
    this.parts = List<T>.unmodifiable(parts);
    _string = parts.join(".");
  }

  @override
  String toString() => _string;

  @override
  int get _hashCode => _string.hashCode;

  @override
  bool _compare(Object other) => other is PartId<T> && _string == other._string;
}