import 'package:flutter/material.dart';

/// Swaps Sign In / Sign Up cards with the same cross-fade + slide in both directions.
class AuthCardSwitcher extends StatefulWidget {
  const AuthCardSwitcher({
    super.key,
    required this.showSignUp,
    required this.signInBuilder,
    required this.signUpBuilder,
  });

  final bool showSignUp;
  final WidgetBuilder signInBuilder;
  final WidgetBuilder signUpBuilder;

  @override
  State<AuthCardSwitcher> createState() => _AuthCardSwitcherState();
}

class _AuthCardSwitcherState extends State<AuthCardSwitcher>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 340);

  late final AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _incomingSlide;
  late Animation<Offset> _outgoingSlide;

  late bool _displaySignUp;
  bool _targetSignUp = false;

  @override
  void initState() {
    super.initState();
    _displaySignUp = widget.showSignUp;
    _targetSignUp = widget.showSignUp;
    _controller = AnimationController(vsync: this, duration: _duration);
    _syncAnimations(forwardToSignUp: _targetSignUp);
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(AuthCardSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showSignUp == widget.showSignUp) return;

    _targetSignUp = widget.showSignUp;
    _syncAnimations(forwardToSignUp: _targetSignUp);
    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() => _displaySignUp = _targetSignUp);
    });
  }

  void _syncAnimations({required bool forwardToSignUp}) {
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _fade = Tween<double>(begin: 0, end: 1).animate(curve);

    // Sign Up: incoming from below, outgoing up. Sign In: mirror.
    final incomingBegin = forwardToSignUp
        ? const Offset(0, 0.06)
        : const Offset(0, -0.06);
    final outgoingEnd = forwardToSignUp
        ? const Offset(0, -0.05)
        : const Offset(0, 0.05);

    _incomingSlide = Tween<Offset>(begin: incomingBegin, end: Offset.zero).animate(curve);
    _outgoingSlide = Tween<Offset>(begin: Offset.zero, end: outgoingEnd).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _card({required bool signUp}) {
    return signUp ? widget.signUpBuilder(context) : widget.signInBuilder(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = _fade.value;
    final animating = _controller.isAnimating;
    final showOutgoing = animating ? _displaySignUp : _targetSignUp;
    final showIncoming = _targetSignUp;

    if (!animating && _displaySignUp == _targetSignUp) {
      return AnimatedSize(
        duration: _duration,
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        child: _card(signUp: _displaySignUp),
      );
    }

    return AnimatedSize(
      duration: _duration,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            ignoring: t > 0.5,
            child: FadeTransition(
              opacity: ReverseAnimation(_fade),
              child: SlideTransition(
                position: _outgoingSlide,
                child: _card(signUp: showOutgoing),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: t <= 0.5,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _incomingSlide,
                child: _card(signUp: showIncoming),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
