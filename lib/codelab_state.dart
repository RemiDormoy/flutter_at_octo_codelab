import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:equatable/equatable.dart';

class CodelabState extends Equatable {
  final CodelabStatus status;
  final Activity? activity;

  const CodelabState({
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
