import 'package:equatable/equatable.dart';

enum IssueDisclaimerType {
  home,
  profile,
  other;

  static IssueDisclaimerType fromWire(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'profile':
        return IssueDisclaimerType.profile;
      case 'home':
        return IssueDisclaimerType.home;
      case 'other':
      default:
        return IssueDisclaimerType.other;
    }
  }
}

enum IssueDisclaimerLevel {
  warning,
  error,
  neutral;

  static IssueDisclaimerLevel fromWire(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'warning':
        return IssueDisclaimerLevel.warning;
      case 'error':
        return IssueDisclaimerLevel.error;
      case 'neutral':
      default:
        return IssueDisclaimerLevel.neutral;
    }
  }
}

class IssueDisclaimer extends Equatable {
  const IssueDisclaimer({
    required this.title,
    required this.description,
    required this.screenType,
    required this.level,
    required this.isActive,
  });

  final String? title;
  final String? description;
  final IssueDisclaimerType screenType;
  final IssueDisclaimerLevel level;
  final bool isActive;

  factory IssueDisclaimer.fromJson(Map<String, dynamic> json) {
    final rawEnabled = json['enabled'] ?? json['is_active'] ?? true;
    final isActive = rawEnabled == true;

    return IssueDisclaimer(
      title: json['title'] as String?,
      description: json['description'] as String?,
      screenType: IssueDisclaimerType.fromWire(json['screen_type']?.toString()),
      level: IssueDisclaimerLevel.fromWire(json['level']?.toString()),
      isActive: isActive,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    screenType,
    level,
    isActive,
  ];
}
