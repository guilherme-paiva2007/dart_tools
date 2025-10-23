import 'package:dart_tools/utils/limited_time_use_class.dart';
import 'package:test/test.dart';

final class TestClass with LimitedTimeUseClass {
  TestClass() {
    init();
  }

  @override
  void init() {
    super.init();
    print("Class inited");
  }

  @override
  void dispose() {
    super.dispose();
    print("Class disposed");
  }

  bool action() {
    if (!active) return false;
    print("Class action");
    return true;
  }
}

void main() {
  group("Limited time use class tests", () {
    test("Class action when active", () {
      final instance = TestClass();
      expect(instance.action(), true);
    },);

    test("Class action after dispose", () {
      final instance = TestClass();
      instance.dispose();
      expect(instance.action(), false);
    },);

    test("Initing class again", () {
      final instance = TestClass();
      bool okay = false;
      try {
        instance.init();
      } catch (e) {
        okay = true;
      }
      expect(okay, true);
    },);

    test("Disposing class twice", () {
      final instance = TestClass();
      instance.dispose();
      bool okay = false;
      try {
        instance.dispose();
      } catch (e) {
        okay = true;
      }
      expect(okay, true);
    },);
  },);
}