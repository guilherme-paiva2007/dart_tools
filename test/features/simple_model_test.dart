import 'package:dart_tools/features.dart';
import 'package:dart_tools/result.dart';
import 'package:dart_tools/rules.dart';
import 'package:dart_tools/warnings.dart';
import 'package:test/test.dart';

final class User extends Model<User> {
  String _name;
  String _username;
  int _age;

  String get name => _name;
  String get username => _username;
  int get age => _age;
  
  User(super.$id, {
    required String name,
    required String username,
    required int age,
  }): _name = name,
    _username = username,
    _age = age;
}

final class UserUpdate extends ModelUpdate<User> {
  final String? name;
  final String? username;
  final int? age;

  UserUpdate(super.$id, {
    this.name,
    this.username,
    this.age,
  });

  static final _usernameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
  static Rule<String> usernameRule = Rule([
    RuleCondition(
      function: (value) => _usernameRegExp.hasMatch(value),
      errorMessage: 'Username can only contain alphanumeric characters and underscores.',
    ),
    RuleCondition(
      function: (value) => value.length > 3 && value.length <= 20,
      errorMessage: 'Username must be between 4 and 20 characters long.',
    )
  ]);

  @override
  Result<User, Warning> changeData(User instance) {
    final warnings = <String, Warning>{};
    if (name != null) {
      instance._name = name!;
    }
    if (username != null) {
      final usernameError = usernameRule.errors(username!);
      if (usernameError.isNotEmpty) {
        warnings['username'] = WarningList(
          FeatureWarningCodes.unmatchFieldType,
          usernameError.map((e) => Warning(FeatureWarningCodes.unmatchRule, e),),
        );
      } else {
        instance._username = username!;
      }
    }
    if (age != null) {
      instance._age = age!;
    }

    if (warnings.isEmpty) {
      return Success(instance);
    } else {
      return Failure(WarningMap(FeatureWarningCodes.incorrectUpdate, warnings,));
    }
  }
}

void main() {
  group("Instance tests", () {
    test("Correct initialization", () {
      final user = User(PartId(['user', '1']), name: "John Doe", username: "johndoe", age: 30);
      expect(user.name, "John Doe");
      expect(user.username, "johndoe");
      expect(user.age, 30);
    },);
  },);

  group("Update tests", () {
    test("Correct field values", () {
      final user = User(PartId(['user', '1']), name: "John Doe", username: "johndoe", age: 30);
      final update = UserUpdate(user.$id, name: "Jane Doe", username: "janedoe", age: 25);
      final result = update.update(user);
      
      expect(result is Success, true);
      if (result is Success<User, Warning>) {
        final updatedUser = result.result;
        expect(updatedUser.name, "Jane Doe");
        expect(updatedUser.username, "janedoe");
        expect(updatedUser.age, 25);
      }
    },);

    test("Unmatching rule", () {
      final user = User(PartId(['user', '1']), name: "John Doe", username: "johndoe", age: 30);
      final update = UserUpdate(user.$id, username: "jd",);
      final result = update.update(user);

      expect(result is Failure, true);
      if (result is Failure<User, Warning>) {
        final warning = result.failure;
        expect(warning, isA<WarningMap>());
        if (warning is WarningMap) {
          expect(warning.subWarnings.containsKey('username'), true);
          final usernameWarning = warning.subWarnings['username'];
          expect(usernameWarning, isA<WarningList>());
          if (usernameWarning is WarningList) {
            expect(usernameWarning.subWarnings.isNotEmpty, true);
            expect(usernameWarning.subWarnings.any((element) {
              return element.code == FeatureWarningCodes.unmatchRule;
            },), true);
          }
        }
      }
    },);

    test("Unmatching id", () {
      final user = User(PartId(['user', '1']), name: "John Doe", username: "johndoe", age: 30);
      final update = UserUpdate(PartId(['user', '2']), name: "Jane Doe",);
      final result = update.update(user);

      expect(result is Failure, true);
      if (result is Failure<User, Warning>) {
        final warning = result.failure;
        expect(warning.code, FeatureWarningCodes.unmatchId);
      }
    },);
  },);
}