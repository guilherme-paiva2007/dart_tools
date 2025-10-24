part of "../features.dart";

abstract base class Service<M extends Model<M>> with LimitedTimeUseClass {
  final HashSet<Repository<M>> _repositories = HashSet();

  @protected
  late final UnmodifiableSetView<Repository<M>> repositories;

  Service() {
    init();
    repositories = UnmodifiableSetView(_repositories);
  }

  @override
  void dispose() {
    super.dispose();
    for (var repo in _repositories) {
      repo._services.remove(this);
    }
    _repositories.clear();
  }

  @protected
  @mustCallSuper
  void addInRepositories(M instance) {
    for (var repo in _repositories) {
      repo.add(instance);
    }
  }

  @protected
  @mustCallSuper
  void removeInRepositories(Id id) {
    for (var repo in _repositories) {
      repo.removeId(id);
    }
  }

  @protected
  @mustCallSuper
  void updateInstance(ModelUpdate<M> update) {
    for (var repo in _repositories) {
      final instance = repo.get(update.$id);
      if (instance != null) {
        update.update(instance);
      }
    }
  }
}
