import 'package:dart_tools/map_parser.dart';
import 'package:dart_tools/result.dart';
import 'package:test/test.dart';

final parser = MapParser({
  "submap": SubMapParserType({
    "field1": MapParserTypes.string,
    "field2": MapParserTypes.boolean,
  }),
});

void main() {
  final basemap = <String, dynamic>{
    "submap": {
      "field1": "value1",
      "field2": true
    }
  };
  group("Submap type checks", () {
    test("All fields in correct type", () {
      expect(parser.filter(basemap) is Success, true);
    },);

    test("Submap with incorrect field type", () {
      final incorrect = { ...basemap };
      incorrect["submap"]["field2"] = "not a boolean";

      expect(parser.filter(incorrect) is Failure, true);
    },);

    test("Submap missing field", () {
      final missing = { ...basemap };
      (missing["submap"] as Map<String, dynamic>).remove("field1");

      expect(parser.filter(missing) is Failure, true);
    },);

    test("Submap is not a map", () {
      final incorrect = { ...basemap };
      incorrect["submap"] = "not a map";

      expect(parser.filter(incorrect) is Failure, true);
    },);
  },);
}