import 'dart:async';
import 'dart:collection';

import 'package:dart_tools/result.dart';
import 'package:dart_tools/warnings.dart';
import 'package:meta/meta.dart' show mustBeOverridden, mustCallSuper, protected;

import 'package:dart_tools/utils/limited_time_use_class.dart';

part 'features/model.dart';
part 'features/service.dart';
part 'features/repository.dart';
part 'features/provider.dart';

part 'features/repositories/auto_cleaning_repository.dart';
part 'features/services/database.dart';

enum FeatureWarningCodes implements WarningCode {
  incorrectUpdate("The update provided is incorrect and could not be applied."),

  unmatchId("The provided id does not match the model's id."),
  unmatchFieldType("The provided field type does not match the model's field type."),
  unmatchRule("The provided field value does not match the defined rules.")
  
  ;
  
  @override
  final String explanation;

  const FeatureWarningCodes(this.explanation);
}