import 'package:equatable/equatable.dart';

sealed class WaterLinkPurpose extends Equatable {
  const WaterLinkPurpose();

  @override
  List<Object?> get props => const [];
}

class WaterLinkPurposeShareProgress extends WaterLinkPurpose {
  const WaterLinkPurposeShareProgress({
    required this.ml,
  });

  final int ml;

  @override
  List<Object?> get props => [ml];
}

class WaterLinkPurposeNone extends WaterLinkPurpose {
  const WaterLinkPurposeNone();
}
