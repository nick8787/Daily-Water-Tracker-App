import 'package:equatable/equatable.dart';
import 'package:daily_water_tracker/features/deep_links/models/water_link_purpose.dart';

class DeepLinkState extends Equatable {
  const DeepLinkState({
    required this.purpose,
    required this.lastHandledUri,
  });

  final WaterLinkPurpose purpose;
  final String? lastHandledUri;

  DeepLinkState copyWith({
    WaterLinkPurpose? purpose,
    String? lastHandledUri,
  }) {
    return DeepLinkState(
      purpose: purpose ?? this.purpose,
      lastHandledUri: lastHandledUri ?? this.lastHandledUri,
    );
  }

  factory DeepLinkState.initial() => const DeepLinkState(
    purpose: WaterLinkPurposeNone(),
    lastHandledUri: null,
  );

  @override
  List<Object?> get props => [
    purpose,
    lastHandledUri,
  ];
}
