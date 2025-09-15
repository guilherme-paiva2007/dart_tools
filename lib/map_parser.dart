import 'package:dart_tools/result.dart';
import 'package:dart_tools/warnings.dart';

part 'map_parsers/complex.dart';
part 'map_parsers/numerics.dart';
part 'map_parsers/simple.dart';

typedef ParseWarning = Warning<ParseWarningCode>;
typedef JSONMap = Map<String, dynamic>;

final class MapParser {
  final Map<String, MapParserType> fields;
  final bool allowExtraFields;

  MapParser(Map<String, MapParserType> fields, [ this.allowExtraFields = false ]):
    fields = Map.unmodifiable(fields);

  factory MapParser.merge(Iterable<MapParser> parsers) {
    final Map<String, MapParserType> fields = {};

    for (var parser in parsers) {
      fields.addAll(parser.fields);
    }

    return MapParser(fields);
  }

  MapParser copyWith(Map<String, MapParserType> fields, [ bool? allowExtraFields ]) =>
    MapParser({
      ...this.fields,
      ...fields
    }, allowExtraFields ?? this.allowExtraFields);


  Result<JSONMap, Map<String, ParseWarning>> filter(JSONMap map) {
    final JSONMap filtered = {};
    final Set<String> validatedFields = {};
    final Map<String, ParseWarning> warnings = {};

    for (var MapEntry(key: field, value: type) in fields.entries) {
      validatedFields.add(field);

      if (!map.containsKey(field)) {
        if (!type.blankable) {
          warnings[field] = const ParseWarning(ParseWarningCode.missing);
        }
        continue;
      }

      final result = type.get(map[field]);
      switch (result) {
        case Failure _:
          warnings[field] = result.failure!;
          break;
        case Success _:
          filtered[field] = result.result!;
          break;
      }
    }

    checkForExtraFields(map, validatedFields, warnings);

    return warnings.isEmpty ?
      Success(filtered) :
      Failure(warnings);
  }
}

extension on MapParser {
  void checkForExtraFields(JSONMap map, Set<String> validatedFields, Map<String, ParseWarning> warnings) {
    if (allowExtraFields) return;
    for (var key in validatedFields) {
      if (!map.containsKey(key)) {
        warnings[key] = const ParseWarning(ParseWarningCode.extra);
      }
    }
  }
}

abstract mixin class MapParserType<T> {
  bool get blankable;

  Result<T, ParseWarning> get(dynamic value);

  Type get type => T;
}

mixin MapParserSimpleType<T> on MapParserType<T> {
  @override
  get(value) => value is T ?
    Success(value) :
    const Failure( Warning(ParseWarningCode.type) );
}

mixin MapParserComplexType<T> on MapParserType<T> {}

enum ParseWarningCode implements WarningCode {
  missing("Field is missing"),
  type("Field has an incorrect type"),
  extra("Field does not belong in the map"),
  complex("Field value doesn't conform to expected structure");

  @override
  final String explanation;

  const ParseWarningCode(this.explanation);
}