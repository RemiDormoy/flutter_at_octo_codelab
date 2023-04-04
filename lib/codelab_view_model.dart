import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:equatable/equatable.dart';
import 'package:redux/redux.dart';

class CodelabViewModel extends Equatable {
  final bool loading;
  final bool error;
  final Activity? activity;

  const CodelabViewModel({
    required this.loading,
    required this.error,
    required this.activity,
  });

  factory CodelabViewModel.fromStore(Store<CodelabState> store) {
    return CodelabViewModel(
      loading: store.state.status == CodelabStatus.LOADING,
      error: store.state.status == CodelabStatus.ERROR,
      activity: store.state.activity,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    error,
    activity,
  ];
}
