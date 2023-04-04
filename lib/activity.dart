import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  final String label;
  final String type;
  final int participants;
  final double price;
  final double accessibility;

  const Activity({
    required this.label,
    required this.type,
    required this.participants,
    required this.price,
    required this.accessibility,
  });

  @override
  List<Object?> get props => [
        label,
        type,
        participants,
        price,
        accessibility,
      ];
}
