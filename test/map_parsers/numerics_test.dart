import 'package:dart_tools/tools.dart';
import 'package:test/test.dart';

final parser1 = MapParser({
  "int": MapParserNumericTypes.integer,
  "double": MapParserNumericTypes.floating,
});

void main() {
  final basemap = <String, dynamic>{
    "int": 42,
    "double": 3.14,
  };
  group("Numeric types checks", () {
    test("All fields in correct type", () {
      expect(parser1.filter(basemap) is Success, true);
    },);

    test("Field with incorrect type", () {
      final incorrect = { ...basemap };
      incorrect["int"] = "not an int";

      expect(parser1.filter(incorrect) is Failure, true);
    },);

    test("Int as double", () {
      final intAsDouble = { ...basemap };
      intAsDouble["double"] = 42;

      expect(parser1.filter(intAsDouble) is Success, true);
    },);

    test("Double as int", () {
      final doubleAsInt = { ...basemap };
      doubleAsInt["int"] = 3.14;

      expect(parser1.filter(doubleAsInt) is Failure, true);
    },);
  },);
}