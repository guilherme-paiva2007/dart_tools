part of "../features.dart";

abstract base class Service<M extends Model<M>> with LimitedTimeUseClass {
  final HashSet<Repository<M>> _repositories = HashSet();

  Service() {
    init();
  }

  @override
  void dispose() {
    super.dispose();
    for (var repo in _repositories) {
      repo._services.remove(this);
    }
    _repositories.clear();
  }

  @mustCallSuper
  // ignore: unused_element
  void _addInRepositories(M instance) {
    for (var repo in _repositories) {
      repo.add(instance);
    }
  }

  @mustCallSuper
  // ignore: unused_element
  void _removeInRepositories(Id id) {
    for (var repo in _repositories) {
      repo.removeId(id);
    }
  }

  @mustCallSuper
  // ignore: unused_element
  void _updateInstance(ModelUpdate<M> update) {
    for (var repo in _repositories) {
      final instance = repo.get(update.id);
      if (instance != null) {
        update.update(instance);
      }
    }
  }
}
