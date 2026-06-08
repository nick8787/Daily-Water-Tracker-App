import 'package:equatable/equatable.dart';

class VibrationState extends Equatable {
  const VibrationState({required this.enabled});

  final bool enabled;

  VibrationState copyWith({bool? enabled}) {
    return VibrationState(enabled: enabled ?? this.enabled);
  }

  @override
  List<Object?> get props => [enabled];
}
