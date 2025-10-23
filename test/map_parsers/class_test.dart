import 'package:dart_tools/map_parser.dart';
import 'package:dart_tools/result.dart';
import 'package:test/test.dart';

final class TestClass {
  final String name;
  final int value;
  TestClass(this.name, this.value);
}

final parser = MapParserClassType<TestClass>(
  fields: {
    "name": MapParserTypes.string,
    "value": MapParserTypes.string,
  },
  parser: (map) => TestClass(
    map["name"] as String,
    int.parse(map["value"] as String),
  ),
);

void main() {
  final basemap = <String, dynamic>{
    "name": "test",
    "value": "42",
  };
  group("Class type checks", () {
    test("All fields in correct type", () {
      expect(parser.filter(basemap) is Success, true);
    },);

    test("Field with incorrect type", () {
      final incorrect = { ...basemap };
      incorrect["value"] = 3.14;

      expect(parser.filter(incorrect) is Failure, true);
    },);

    test("Field missing", () {
      final missing = { ...basemap };
      missing.remove("name");

      expect(parser.filter(missing) is Failure, true);
    },);

    test("Result parse correctly", () {
      final result = parser.get(basemap);
      expect(result is Success, true);
      if (result is Success<TestClass, ParseWarning>) {
        expect(result.result.name, "test");
        expect(result.result.value, 42);
      }
    },);
  },);
}