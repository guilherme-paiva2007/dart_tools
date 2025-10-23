part of '../map_parser.dart';

enum MapParserTypes<T> with MapParserType<T>, MapParserSimpleType<T> {
  string<String>(),
  boolean<bool>(),
  list<List>(),
  map<JSONMap>(),
  
  stringBlankable<String>(true),
  booleanBlankable<bool>(true),
  listBlankable<List>(true),
  mapBlankable<JSONMap>(true),
  ;

  @override
  final bool blankable;

  const MapParserTypes([this.blankable = false]);
}

enum MapParserNullTypes with MapParserType<Null>, MapParserSimpleType<Null> {
  empty(),
  emptyBlankable(true);

  @override
  final bool blankable;

  const MapParserNullTypes([this.blankable = false]);
}