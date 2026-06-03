import 'package:equatable/equatable.dart';
import 'package:daily_water_tracker/features/remote_config/models/issue_disclaimer.dart';
import 'package:daily_water_tracker/firebase/services/remote_config_service.dart';

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
    return RemoteConfigState(
      progressIndicatorType: RemoteConfigService.fallbackProgressIndicatorType,
      issueDisclaimers: const <IssueDisclaimer>[],
    );
  }

  @override
  List<Object?> get props => [
    progressIndicatorType,
    issueDisclaimers,
  ];
}
