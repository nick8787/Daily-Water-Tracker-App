import 'package:flutter/material.dart';

class DelayedEntrance extends StatefulWidget {
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset from;
  final Widget child;

  const DelayedEntrance({
    super.key,
    required this.delay,
    required this.duration,
    this.curve = Curves.easeOutCubic,
    this.from = const Offset(0, 14),
    required this.child,
  });

  @override
  State<DelayedEntrance> createState() => _DelayedEntranceState();
}

class _DelayedEntranceState extends State<DelayedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _controller, curve: widget.curve);
    Future<void>.delayed(widget.delay).then((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final t = _t.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(widget.from.dx * (1 - t), widget.from.dy * (1 - t)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
