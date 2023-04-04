import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:flutter/material.dart';

class FindActivityAction {
  final RangeValues currentPriceFilter;
  final RangeValues currentAccessibilityFilter;
  final int currentParticipantsFilter;

  FindActivityAction({
    required this.currentPriceFilter,
    required this.currentAccessibilityFilter,
    required this.currentParticipantsFilter,
  });
}

class ProcessActivityFoundAction {
  final Activity activity;

  ProcessActivityFoundAction(this.activity);
}

class ProcessActivityLoadErrorAction {}

class UpdateAccessibilityFiltersAction {
  final RangeValues values;

  UpdateAccessibilityFiltersAction(this.values);
}

class UpdatePriceFiltersAction {
  final RangeValues values;

  UpdatePriceFiltersAction(this.values);
}

class UpdateParticipantsFiltersAction {
  final int value;

  UpdateParticipantsFiltersAction(this.value);
}
