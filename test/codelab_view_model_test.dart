import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/codelab_reducer.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:codelab_flutter_at_octo/codelab_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';

main() {
  test('when state is in status loading, view model should have isLoading to true', () {
    // Given
    const currentState = CodelabState(status: CodelabStatus.LOADING, activity: null);
    final store = Store<CodelabState>(
      reducer,
      initialState: currentState,
    );

    // When
    final viewModel = CodelabViewModel.fromStore(store);

    // Then
    expect(viewModel.loading, isTrue);
    expect(viewModel.error, isFalse);
  });

  test('when state is in status error, view model should have isError to true', () {
    // Given
    const currentState = CodelabState(status: CodelabStatus.ERROR, activity: null);
    final store = Store<CodelabState>(
      reducer,
      initialState: currentState,
    );

    // When
    final viewModel = CodelabViewModel.fromStore(store);

    // Then
    expect(viewModel.error, isTrue);
    expect(viewModel.loading, isFalse);
  });

  test('when state is in status succes, view model should have activity', () {
    // Given
    const activity = Activity(label: 'label', type: 'type', participants: 1, price: 12, accessibility: 14);
    const currentState = CodelabState(status: CodelabStatus.SUCCESS, activity: activity);
    final store = Store<CodelabState>(
      reducer,
      initialState: currentState,
    );

    // When
    final viewModel = CodelabViewModel.fromStore(store);

    // Then
    expect(viewModel.error, isFalse);
    expect(viewModel.loading, isFalse);
    expect(viewModel.activity, activity);
  });
}
