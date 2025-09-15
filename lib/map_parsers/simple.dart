part of '../map_parser.dart';

enum MapParserTypes<T> with MapParserType<T>, MapParserSimpleType<T> {
  string<String>(),
  boolean<bool>(),
  list<List>(),
  map<JSONMap>(),
  empty<Null>(),
  stringNull<String>(),
  booleanNull<bool>(),
  listNull<List>(),
  mapNull<JSONMap>(),
  emptyNull<Null>(),

  stringBlankable<String>(true),
  booleanBlankable<bool>(true),
  listBlankable<List>(true),
  mapBlankable<JSONMap>(true),
  emptyBlankable<Null>(true),
  stringNullBlankable<String>(true),
  booleanNullBlankable<bool>(true),
  listNullBlankable<List>(true),
  mapNullBlankable<JSONMap>(true),
  emptyNullBlankable<Null>(true),
  ;

  @override
  final bool blankable;

  const MapParserTypes([this.blankable = false]);
}