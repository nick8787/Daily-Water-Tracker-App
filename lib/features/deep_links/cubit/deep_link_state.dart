import 'package:daily_water_tracker/features/deep_links/models/water_link_purpose.dart';
import 'package:equatable/equatable.dart';

class DeepLinkState extends Equatable {
  const DeepLinkState({
    required this.purpose,
    required this.shareDeliveryId,
    required this.passwordResetDeliveryId,
  });

  final WaterLinkPurpose purpose;
  final int shareDeliveryId;
  final int passwordResetDeliveryId;

  DeepLinkState copyWith({
    WaterLinkPurpose? purpose,
    int? shareDeliveryId,
    int? passwordResetDeliveryId,
  }) {
    return DeepLinkState(
      purpose: purpose ?? this.purpose,
      shareDeliveryId: shareDeliveryId ?? this.shareDeliveryId,
      passwordResetDeliveryId:
          passwordResetDeliveryId ?? this.passwordResetDeliveryId,
    );
  }

  factory DeepLinkState.initial() => const DeepLinkState(
    purpose: WaterLinkPurposeNone(),
    shareDeliveryId: 0,
    passwordResetDeliveryId: 0,
  );

  @override
  List<Object?> get props => [
    purpose,
    shareDeliveryId,
    passwordResetDeliveryId,
  ];
}
