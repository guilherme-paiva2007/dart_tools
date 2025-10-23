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


  Result<JSONMap, Map<String, ParseWarning>> filter(JSONMap map, [bool stopOnFirstWarning = false]) {
    final JSONMap filtered = {};
    final Set<String> validatedFields = {};
    final Set<String> nonValidatedFields = map.keys.toSet();

    final WarningMap<ParseWarningCode, String> warnings = WarningMap(ParseWarningCode.complex, {});

    for (var MapEntry(key: field, value: type) in fields.entries) {
      validatedFields.add(field);
      nonValidatedFields.remove(field);

      if (!map.containsKey(field)) {
        if (!type.blankable) {
          if (!warnings.containsKey(field)) {
            warnings[field] = WarningList<ParseWarningCode>(ParseWarningCode.complex, []);
          }
          (warnings[field] as WarningList<ParseWarningCode>).add(ParseWarning(ParseWarningCode.missing));
          if (stopOnFirstWarning) return Failure(warnings);
        }
        continue;
      }

      final result = type.get(map[field]);
      if (result is Success<dynamic, Warning<ParseWarningCode>>) {
        filtered[field] = result.result;
      } else if (result is Failure<dynamic, Warning<ParseWarningCode>>) {
        if (!warnings.containsKey(field)) {
          warnings[field] = WarningList<ParseWarningCode>(ParseWarningCode.complex, []);
        }
        (warnings[field] as WarningList<ParseWarningCode>).add(result.failure);
        if (stopOnFirstWarning) return Failure(warnings);
      }
    }

    if (!allowExtraFields) {
      for (var nonValidatedField in nonValidatedFields) {
        if (!warnings.containsKey(nonValidatedField)) {
          warnings[nonValidatedField] = WarningList<ParseWarningCode>(ParseWarningCode.complex, []);
        }
        (warnings[nonValidatedField] as WarningList<ParseWarningCode>).add(ParseWarning(ParseWarningCode.extra));
        if (stopOnFirstWarning) return Failure(warnings);
      }
    }

    return warnings.values.every(_warningMapListAllEmptyEvery) ?
      Success(filtered) :
      Failure(warnings);
  }

  static bool _warningMapListAllEmptyEvery(ParseWarning warning) {
    return warning is WarningList ?
      (warning as WarningList).isEmpty :
      true;
  }
}

abstract mixin class MapParserType<T> {
  bool get blankable;

  Result<T, ParseWarning> get(dynamic value);

  Type get type => T;
}

final class NullableParserType<T> extends MapParserType<T?> {
  final MapParserType<T> original;

  NullableParserType(this.original);
  
  @override
  bool get blankable => original.blankable;

  @override
  Result<T?, ParseWarning> get(value) {
    if (value == null) return Success(null);
    return original.get(value);
  }
}

mixin MapParserSimpleType<T> on MapParserType<T> {
  @override
  get(value) => value is T ?
    Success(value) :
    Failure( Warning(ParseWarningCode.type) );
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