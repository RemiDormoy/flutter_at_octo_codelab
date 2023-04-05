import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/activity_repository.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final findActivityUseCase = Provider.family<Future<Activity?>, FindActivityUseCaseArguments>((ref, args) async {
  final repository = ref.read(activityRepositoryProvider);
  final activity = await repository.getActivity(args.priceRangeValue, args.accessibilityRangeValue, args.participants);
  return activity;
});

class FindActivityUseCaseArguments {
  final RangeValues priceRangeValue;
  final RangeValues accessibilityRangeValue;
  final int participants;

  FindActivityUseCaseArguments(this.priceRangeValue, this.accessibilityRangeValue, this.participants);
}