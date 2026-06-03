import 'package:flutter/material.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:go_router/go_router.dart';

class PagesListScreen extends StatelessWidget {
  const PagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {
                context.push(firstPageRoute);
              },
              child: const Text('Go to $firstPageRoute'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                context.push('/pages/test');
              },
              child: const Text('Go to /pages/test'),
            ),
          ],
        ),
      ),
    );
  }
}
