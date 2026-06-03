import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(child: Text('$error', style: Theme.of(context).textTheme.bodyLarge)),
          ),
        ],
      ),
    );
  }
}
