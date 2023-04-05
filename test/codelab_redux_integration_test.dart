import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/activity_repository.dart';
import 'package:codelab_flutter_at_octo/codelab_actions.dart';
import 'package:codelab_flutter_at_octo/codelab_middleware.dart';
import 'package:codelab_flutter_at_octo/codelab_reducer.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';

main() {
  test('when FindActivityAction is dispatched, state should go to success', () async {
    // Given
    const activity = Activity(label: 'label', type: 'type', participants: 1, price: 12, accessibility: 14);
    const currentState = CodelabState(status: CodelabStatus.EMPTY, activity: null);
    final store = Store<CodelabState>(
      reducer,
      initialState: currentState,
      middleware: [
        CodelabMiddleware(_SuccessRepository(activity)),
      ]
    );

    // When
    store.dispatch(FindActivityAction(currentPriceFilter: const RangeValues(0, 1), currentAccessibilityFilter: const RangeValues(0.4, 2), currentParticipantsFilter: 4));
    final finalState = await store.onChange.firstWhere((element) => element.status == CodelabStatus.SUCCESS);

    // Then
    expect(finalState.status, CodelabStatus.SUCCESS);
    expect(finalState.activity, activity);
  });

  test('when FindActivityAction is dispatched with error, state should go to error', () async {
    // Given
    const currentState = CodelabState(status: CodelabStatus.EMPTY, activity: null);
    final store = Store<CodelabState>(
        reducer,
        initialState: currentState,
        middleware: [
          CodelabMiddleware(_ErrorRepository()),
        ]
    );

    // When
    store.dispatch(FindActivityAction(currentPriceFilter: const RangeValues(0, 1), currentAccessibilityFilter: const RangeValues(0.4, 2), currentParticipantsFilter: 4));
    final finalState = await store.onChange.firstWhere((element) => element.status == CodelabStatus.ERROR);

    // Then
    expect(finalState.status, CodelabStatus.ERROR);
  });
}

class _SuccessRepository extends ActivityRepository {
  final Activity returnActivity;
  _SuccessRepository(this.returnActivity) : super(Client());

  @override
  Future<Activity?> getActivity(RangeValues priceRangeValue, RangeValues accessibilityRangeValue, int participants) async {
    return returnActivity;
  }
}

class _ErrorRepository extends ActivityRepository {
  _ErrorRepository() : super(Client());

  @override
  Future<Activity?> getActivity(RangeValues priceRangeValue, RangeValues accessibilityRangeValue, int participants) async {
    return null;
  }
}
