part of '../map_parser.dart';

enum MapParserNumericTypes<T extends num> with MapParserType<T> {
  integer<int>(_isInt, _asInt),
  floating<double>(_isDouble, _asDouble),
  
  integerBlankable<int>(_isInt, _asInt, true),
  floatingBlankable<double>(_isDouble, _asDouble, true)
  ;

  @override
  final bool blankable;

  final bool Function(dynamic value) _validate;
  final T Function(dynamic value) _convert;

  @override
  get(dynamic value) => _validate(value) ?
    Success(_convert(value)) :
    const Failure( Warning(ParseWarningCode.type) );

  const MapParserNumericTypes(this._validate, this._convert, [this.blankable = false]);
}

bool _isInt(dynamic value) => value is num && value == value.floor();

int _asInt(dynamic value) => (value as num).toInt();

bool _isDouble(dynamic value) => value is num;

double _asDouble(dynamic value) => (value as num).toDouble();