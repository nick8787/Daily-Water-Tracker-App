import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageWidget extends StatelessWidget {
  const PageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text(
          'Current location in navigation is ${GoRouterState.of(context).uri}',
        ),
      ),
    );
  }
}
