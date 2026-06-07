import 'package:equatable/equatable.dart';
import 'package:daily_water_tracker/features/deep_links/models/water_link_purpose.dart';

class DeepLinkState extends Equatable {
  const DeepLinkState({
    required this.purpose,
    required this.shareDeliveryId,
  });

  final WaterLinkPurpose purpose;

  /// Increments every time a share link should be presented in the UI.
  final int shareDeliveryId;

  DeepLinkState copyWith({
    WaterLinkPurpose? purpose,
    int? shareDeliveryId,
  }) {
    return DeepLinkState(
      purpose: purpose ?? this.purpose,
      shareDeliveryId: shareDeliveryId ?? this.shareDeliveryId,
    );
  }

  factory DeepLinkState.initial() => const DeepLinkState(
    purpose: WaterLinkPurposeNone(),
    shareDeliveryId: 0,
  );

  @override
  List<Object?> get props => [
    purpose,
    shareDeliveryId,
  ];
}
