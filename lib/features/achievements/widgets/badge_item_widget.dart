import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/badge_model.dart';

class BadgeItemWidget extends StatelessWidget {
  final BadgeModel badge;

  const BadgeItemWidget({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final double opacity = badge.isUnlocked ? 1.0 : 0.3;

    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 50, color: Colors.orange),
            const SizedBox(height: 10),
            Text(
              badge.nameKey.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                badge.descriptionKey.tr(),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}