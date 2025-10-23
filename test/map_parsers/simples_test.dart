import 'package:dart_tools/map_parser.dart';
import 'package:dart_tools/result.dart';
import 'package:test/test.dart';

final MapParser parser1 = MapParser({
  "string": MapParserTypes.string,
  "boolean": MapParserTypes.boolean,
  "null": MapParserNullTypes.empty,
  "list": MapParserTypes.list,
  "map": MapParserTypes.map,
});

final MapParser parser2 = parser1.copyWith({}, true);

final MapParser parser3 = MapParser({
  "string": MapParserTypes.stringBlankable,
  "boolean": MapParserTypes.booleanBlankable,
  "null": MapParserNullTypes.emptyBlankable,
  "list": MapParserTypes.listBlankable,
  "map": MapParserTypes.mapBlankable,
});

void main() {
  final basemap = <String, dynamic>{
    "string": "string value",
    "boolean": true,
    "null": null,
    "list": [ 1, 2, "str", true, null, {}, {}, [] ],
    "map": <String, dynamic>{
      "1": 2,
      "true": false,
      "null": []
    }
  };
  group("Simple types checks", () {
    test("All fields in correct type", () {
      expect(parser1.filter(basemap) is Success, true);
    },);

    test("Field with incorrect type", () {
      final incorrect = { ...basemap };
      incorrect["boolean"] = "str value";

      expect(parser1.filter(incorrect) is Failure, true);
    },);
    
    test("Field missing", () {
      final missing = { ...basemap };
      missing.remove("string");

      expect(parser1.filter(missing) is Failure, true);
    },);

    test("Arbritary map type with incorrect keys", () {
      final incorrect = { ...basemap };
      incorrect["map"] = {
        1: 2,
        true: false,
        null: []
      };

      expect(parser1.filter(incorrect) is Failure, true);
    },);
    
    test("Map with extra field", () {
      final extra = { ...basemap, "extra": "value" };
      final result = parser1.filter(extra);

      if (result is Success) {
        print(result.result);
      }

      expect(result is Failure, true);
    },);
  },);
  
  group("Checks for extra fields parser", () {
    test("All correct fields", () {
      expect(parser2.filter(basemap) is Success, true);
    },);

    test("Extra field", () {
      final extra = { ...basemap, "extra": "value" };
      
      expect(parser2.filter(extra) is Success, true);
    },);

    test("Incorrect field type", () {
      final incorrect = { ...basemap };
      incorrect["boolean"] = "str value";

      expect(parser2.filter(incorrect) is Failure, true);
    },);

    test("Missing field", () {
      final missing = { ...basemap };
      missing.remove("string");

      expect(parser2.filter(missing) is Failure, true);
    },);
  },);
  
  group("Simple blankable types checks", () {
    test("All fields in correct type", () {
      expect(parser3.filter(basemap) is Success, true);
    },);

    test("Blankable field missing", () {
      final missing = { ...basemap };
      missing.remove("string");

      expect(parser3.filter(missing) is Success, true);
    },);

    test("Blankable field with incorrect type", () {
      final incorrect = { ...basemap };
      incorrect["boolean"] = "str value";

      expect(parser3.filter(incorrect) is Failure, true);
    },);
  },);
}