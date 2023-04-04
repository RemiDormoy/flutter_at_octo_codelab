import 'package:codelab_flutter_at_octo/codelab_actions.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';

CodelabState reducer(CodelabState currentState, dynamic action) {
  if (action is FindActivityAction) {
    return const CodelabState(
      status: CodelabStatus.LOADING,
      activity: null,
    );
  }
  if (action is ProcessActivityLoadErrorAction) {
    return const CodelabState(
      status: CodelabStatus.ERROR,
      activity: null,
    );
  }
  if (action is ProcessActivityFoundAction) {
    return CodelabState(
      status: CodelabStatus.SUCCESS,
      activity: action.activity,
    );
  }
  return currentState;
}
