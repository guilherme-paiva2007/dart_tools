part of '../map_parser.dart';

typedef ParseWarningMap = WarningMap<ParseWarningCode, String>;

final class MapParserClassType<T extends Object> extends MapParser with MapParserType<T> {
  @override
  final bool blankable;

  final T Function(JSONMap map) parser;

  MapParserClassType({
    required Map<String, MapParserType> fields,
    this.blankable = false,
    bool allowExtraFields = false,
    required this.parser
  }): super(fields, allowExtraFields);

  @override
  Result<T, ParseWarning> get(value) {
    if (value is! JSONMap) return Failure( Warning(ParseWarningCode.type) );
    final result = filter(value);

    if (result is Success<Map<String, dynamic>, Map<String, Warning<ParseWarningCode>>>) {
      return Success(parser(result.result));
    }
    return Failure(WarningMap(ParseWarningCode.complex, result.failure!));
  }
}

final class SubMapParserType extends MapParser with MapParserType<JSONMap> {
  @override
  final bool blankable;

  SubMapParserType(Map<String, MapParserType> fields, {
    this.blankable = false,
    bool allowExtraFields = false,
  }) : super(fields, allowExtraFields);

  @override
  Result<JSONMap, ParseWarning> get(value) {
    if (value is! JSONMap) return Failure( Warning(ParseWarningCode.type) );
    final result = filter(value);

    if (result is Success<Map<String, dynamic>, Map<String, Warning<ParseWarningCode>>>) {
      return Success(result.result);
    }
    return Failure(WarningMap(ParseWarningCode.complex, (result as Failure<Map<String, dynamic>, Map<String, Warning<ParseWarningCode>>>).failure));
  }
}

final class MapParserListType<T, P extends dynamic> extends MapParserType<List<T>> {
  @override
  final bool blankable;

  final MapParserType<T> subtype;
  final T Function(P value)? parser;

  MapParserListType(this.subtype, {
    this.blankable = false,
    this.parser
  });

  @override
  Result<List<T>, ParseWarning> get(value) {
    if (value is! List) return Failure( Warning(ParseWarningCode.type) );
    final List<T> list = [];
    final Map<int, ParseWarning> warnings = {};

    final bool hasParser = parser != null;

    for (var i = 0; i < value.length; i++) {
      final item = subtype.get(hasParser ? parser!.call(value[i]) : value[i]);
      if (item is Success<T, Warning<ParseWarningCode>>) {
        list.add(item.result);
      } else if (item is Failure<T, Warning<ParseWarningCode>>) {
        warnings[i] = item.failure;
      }
    }

    if (warnings.isEmpty) {
      return Success(list);
    }
    return Failure(WarningMap(ParseWarningCode.complex, warnings));
  }
}