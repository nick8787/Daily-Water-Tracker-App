import 'package:daily_water_tracker/features/remote_config/models/issue_disclaimer.dart';
import 'package:daily_water_tracker/firebase/services/remote_config_service.dart';
import 'package:equatable/equatable.dart';

class RemoteConfigState extends Equatable {
  const RemoteConfigState({
    required this.progressIndicatorType,
    required this.issueDisclaimers,
  });

  final ProgressIndicatorType progressIndicatorType;
  final List<IssueDisclaimer> issueDisclaimers;

  IssueDisclaimer? firstForScreen(IssueDisclaimerType screen) {
    for (final d in issueDisclaimers) {
      if (d.screenType == screen) return d;
    }
    return null;
  }

  RemoteConfigState copyWith({
    ProgressIndicatorType? progressIndicatorType,
    List<IssueDisclaimer>? issueDisclaimers,
  }) {
    return RemoteConfigState(
      progressIndicatorType:
          progressIndicatorType ?? this.progressIndicatorType,
      issueDisclaimers: issueDisclaimers ?? this.issueDisclaimers,
    );
  }

  factory RemoteConfigState.initial() {
    return const RemoteConfigState(
      progressIndicatorType: RemoteConfigService.fallbackProgressIndicatorType,
      issueDisclaimers: <IssueDisclaimer>[],
    );
  }

  @override
  List<Object?> get props => [
    progressIndicatorType,
    issueDisclaimers,
  ];
}
