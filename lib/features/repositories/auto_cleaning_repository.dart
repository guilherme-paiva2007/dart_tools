part of "../../features.dart";

base mixin AutoCleaningRepository<M extends Model<M>> on Repository<M> {
  Duration get cleaningInterval;
  Duration get maxTtl;
  bool get callProvidersOnRemove => false;
  bool _timerFirstStarted = false;
  late Timer _timer;

  // caches
  late DateTime _now;
  late Duration _currentMaxTtl;
  
  @override
  void init() {
    super.init();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timerFirstStarted) _timer.cancel();
  }

  void startTimer() {
    if (!active) {
      throw StateError('Repository is not active');
    }

    if (cleaningInterval < const Duration(minutes: 15)) {
      throw Exception("cleaningInterval must be at least 15 minutes"); // TODO: change to global warns
    }
    if (_timerFirstStarted) {
      _timer.cancel();
    } else {
      _timerFirstStarted = true;
    }
    _timer = Timer.periodic(cleaningInterval, (timer) {
      clean();
    });
  }

  void clean({
    Duration? maxTtl,
    bool? callProvidersOnRemove,
  }) {
    if (!active) {
      throw StateError('Repository is not active');
    }

    _currentMaxTtl = maxTtl ?? this.maxTtl;
    callProvidersOnRemove ??= this.callProvidersOnRemove;

    _now = DateTime.now();
    _removeMultipleInstances(_itemWhereVerifier, callProvidersOnRemove);
  }

  bool _itemWhereVerifier(Id id, _RepositoryItem<M> item) {
    return _now.difference(item.lastUse) > _currentMaxTtl;
  }
}