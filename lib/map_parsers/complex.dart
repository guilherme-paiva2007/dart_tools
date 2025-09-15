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
    if (value is! JSONMap) return const Failure( Warning(ParseWarningCode.type) );
    final result = filter(value);

    if (result is Success) {
      return Success(parser(result.result!));
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
    if (value is! JSONMap) return const Failure( Warning(ParseWarningCode.type) );
    final result = filter(value);

    if (result is Success) {
      return Success(result.result!);
    }
    return Failure(WarningMap(ParseWarningCode.complex, result.failure!));
  }
}

final class MapParserListType<T> extends MapParserType<List<T>> {
  @override
  final bool blankable;

  final T Function(dynamic value)? parser;

  MapParserListType(this.blankable, {
    this.parser
  });

  @override
  Result<List<T>, ParseWarning> get(value) {
    if (value is! List) return const Failure( Warning(ParseWarningCode.type) );
    final List<T> list = [];
    final List<ParseWarning> warnings = [];

    for (var i = 0; i < value.length; i++) {
      final item = parser?.call(value[i]) ?? value[i];
      if (item is T) {
        list.add(item);
      } else {
        warnings[i] = const Warning(ParseWarningCode.type);
      }
    }

    if (warnings.isEmpty) {
      return Success(list);
    }
    return Failure(WarningList(ParseWarningCode.complex, warnings));
  }
}