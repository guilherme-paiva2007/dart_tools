import 'dart:math';

import 'package:dart_tools/features.dart';
import 'package:dart_tools/result.dart';
import 'package:dart_tools/warnings.dart';
import 'package:test/test.dart';

final class DBItem extends Model<DBItem> {
  int _number;
  int get number => _number;
  late final DateTime timestamp;

  DBItem(super.$id, this._number) {
    timestamp = DateTime.now();
  }
}

final class DBItemUpdate extends ModelUpdate<DBItem> {
  final int? number;

  DBItemUpdate(super.$id, {
    this.number,
  });
  
  @override
  Result<DBItem, Warning<WarningCode>> changeData(DBItem instance) {
    if (number != null) {
      instance._number = number!;
    }
    return Success(instance);
  }
}

final class DBService extends Service<DBItem> {
  static final _random = Random.secure();
  
  Future<void> serve() async {
    await Future.delayed(const Duration(microseconds: 500));
    final number = _random.nextInt(1 << 24);
    addInRepositories(DBItem(
      PartId([ "dbitem", number ]),
      number
    ));
  }

  Future<void> snatch() async {
    await Future.delayed(const Duration(microseconds: 500));
    for (var repo in repositories) {
      if (repo.instances.isEmpty) {
        continue;
      } else {
        final instance = repo.instances.values.first.instance;
        removeInRepositories(instance.$id);

        return;
      }
    }
  }

  Future<void> update() async {
    await Future.delayed(const Duration(microseconds: 500));
    
    for (var repo in repositories) {
      if (repo.instances.isEmpty) {
        continue;
      } else {
        final instance = repo.instances.values.first.instance;
        updateInstance(DBItemUpdate(instance.$id, number: _random.nextInt(1 << 24)));

        return;
      }
    }
  }
}

final class DBRepository extends Repository<DBItem> {}

final class DBProvider extends Provider<DBItem> {}

void main() {
  group("Using service, repository and provider", () {
    final service = DBService();
    final repo = DBRepository();
    final provider = DBProvider();

    repo.subscribe(service);
    repo.addProvider(provider);

    provider.addListener(InstanceEvent.add, (instance) {
      print("Instance added to repository (Id: ${instance.$id})");
    },);

    provider.addListener(InstanceEvent.remove, (instance) {
      print("Instance removed from repository (Id: ${instance.$id})");
    },);

    provider.addListener(InstanceEvent.update, (instance) {
      print("Instance updated in repository (Id: ${instance.$id}, New number: ${instance.number})");
    },);

    test("Using service", () async {
      await service.serve();

      expect(repo.instances.length, 1);

      await service.serve();

      expect(repo.instances.length, 2);

      await service.snatch();

      expect(repo.instances.length, 1);

      await service.update();

      expect(repo.instances.length, 1);

      await service.snatch();

      expect(repo.instances.length, 0);

    },);
  },);
}