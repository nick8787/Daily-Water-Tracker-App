import 'package:flutter/material.dart';

/// Dismisses the soft keyboard when the user taps outside focused fields.
class DismissKeyboardOnTap extends StatelessWidget {
  const DismissKeyboardOnTap({
    super.key,
    required this.child,
    this.behavior = HitTestBehavior.translucent,
  });

  final Widget child;
  final HitTestBehavior behavior;

  static void dismiss(BuildContext context) {
    final scope = FocusScope.of(context);
    if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
      scope.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: () => dismiss(context),
      child: child,
    );
  }
}
