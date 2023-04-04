import 'package:codelab_flutter_at_octo/activity_repository.dart';
import 'package:codelab_flutter_at_octo/codelab_actions.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:redux/redux.dart';

class CodelabMiddleware extends MiddlewareClass<CodelabState> {
  final ActivityRepository repository;

  CodelabMiddleware(this.repository);

  @override
  Future<void> call(Store<CodelabState> store, dynamic action, NextDispatcher next) async {
    next(action);
    if (action is FindActivityAction) {
      final activity = await repository.getActivity(
        action.currentPriceFilter,
        action.currentAccessibilityFilter,
        action.currentParticipantsFilter,
      );
      if (activity == null) {
        store.dispatch(ProcessActivityLoadErrorAction());
      } else {
        store.dispatch(ProcessActivityFoundAction(activity));
      }
    }
  }
}
