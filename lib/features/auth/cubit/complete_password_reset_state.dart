import 'package:easy_localization/easy_localization.dart';

sealed class CompletePasswordResetState {
  const CompletePasswordResetState();
}

class CompletePasswordResetInitial extends CompletePasswordResetState {
  const CompletePasswordResetInitial();
}

class CompletePasswordResetVerifying extends CompletePasswordResetState {
  const CompletePasswordResetVerifying();
}

class CompletePasswordResetReady extends CompletePasswordResetState {
  const CompletePasswordResetReady({
    required this.email,
    required this.oobCode,
  });

  final String email;
  final String oobCode;
}

class CompletePasswordResetSubmitting extends CompletePasswordResetState {
  const CompletePasswordResetSubmitting({
    required this.email,
    required this.oobCode,
  });

  final String email;
  final String oobCode;
}

class CompletePasswordResetSuccess extends CompletePasswordResetState {
  const CompletePasswordResetSuccess();
}

class CompletePasswordResetInvalidCode extends CompletePasswordResetState {
  const CompletePasswordResetInvalidCode(this.messageKey);

  final String messageKey;

  String localizedMessage() => messageKey.tr();
}

class CompletePasswordResetFailure extends CompletePasswordResetState {
  const CompletePasswordResetFailure({
    required this.email,
    required this.oobCode,
    required this.messageKey,
    this.namedArgs,
  });

  final String email;
  final String oobCode;
  final String messageKey;
  final Map<String, String>? namedArgs;

  String localizedMessage() => messageKey.tr(namedArgs: namedArgs);
}
