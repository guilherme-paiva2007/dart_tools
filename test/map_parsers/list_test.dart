import 'package:dart_tools/map_parser.dart';
import 'package:dart_tools/result.dart';
import 'package:test/test.dart';

final parser = MapParser({
  "intList": MapParserListType(MapParserNumericTypes.integer),
  "stringList": MapParserListType(MapParserTypes.string)
});

void main() {
  final basemap = <String, dynamic>{
    "intList": [1, 2, 3, 4, 5],
    "stringList": ["one", "two", "three"]
  };
  group("List type checks", () {
    test("All fields in correct type", () {
      expect(parser.filter(basemap) is Success, true);
    },);

    test("List field with incorrect element type", () {
      final incorrect = { ...basemap };
      incorrect["intList"] = [1, "two", 3];

      expect(parser.filter(incorrect) is Failure, true);
    },);

    test("Field missing", () {
      final missing = { ...basemap };
      missing.remove("stringList");

      expect(parser.filter(missing) is Failure, true);
    });

    test("Empty field list", () {
      final emptyList = { ...basemap };
      emptyList["intList"] = [];

      expect(parser.filter(emptyList) is Success, true);
    },);

    test("Null list (for some reason)", () {
      final newParser = parser.copyWith({
        "nullList": MapParserListType(MapParserNullTypes.empty),
      });
      final nullList = { ...basemap };
      nullList["nullList"] = [ null, null, null, null ];

      expect(newParser.filter(nullList) is Success, true);
    },);
  },);
}