import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/codelab_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CodelabViewModel extends Equatable {
  final CodelabStatus status;
  final Activity? activity;

  const CodelabViewModel({
    required this.status,
    required this.activity,
  });

  @override
  List<Object?> get props => [
        status,
        activity,
      ];
}

enum CodelabStatus {
  EMPTY,
  SUCCESS,
  LOADING,
  ERROR,
}

final codelabViewModelProvider = StateNotifierProvider<CodelabViewModelNotifier, CodelabViewModel>((ref) {
  return CodelabViewModelNotifier(ref);
});

class CodelabViewModelNotifier extends StateNotifier<CodelabViewModel> {
  final Ref ref;

  CodelabViewModelNotifier(this.ref) : super(const CodelabViewModel(status: CodelabStatus.EMPTY, activity: null));

  findActivity(FindActivityUseCaseArguments args) async {
    _setLoading();
    final activity = await ref.read(findActivityUseCase(args));
    if (activity == null) {
      _setError();
    } else {
      _setSuccess(activity);
    }
  }

  _setLoading() {
    state = const CodelabViewModel(status: CodelabStatus.LOADING, activity: null);
  }

  _setError() {
    state = const CodelabViewModel(status: CodelabStatus.ERROR, activity: null);
  }

  _setSuccess(Activity activity) {
    state = CodelabViewModel(status: CodelabStatus.SUCCESS, activity: activity);
  }
}
