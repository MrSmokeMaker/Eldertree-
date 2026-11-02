import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../lens_controller.dart';

class LensOverlayWidget extends ConsumerWidget {
  final int minYear;
  final int maxYear;

  const LensOverlayWidget({
    super.key,
    required this.minYear,
    required this.maxYear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lensState = ref.watch(lensControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeMin = minYear < maxYear ? minYear : maxYear - 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1A1D24) : Colors.white)
            .withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history,
              color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          const Text('Линза времени',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Switch(
            value: lensState.isActive,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              ref.read(lensControllerProvider.notifier).toggle(val);
            },
          ),
          if (lensState.isActive) ...[
            Container(
                width: 1,
                height: 24,
                color: Colors.grey.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 8)),
            SizedBox(
              width: 150,
              child: Slider(
                value: lensState.year
                    .toDouble()
                    .clamp(safeMin.toDouble(), maxYear.toDouble()),
                min: safeMin.toDouble(),
                max: maxYear.toDouble(),
                divisions: maxYear - safeMin,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) {
                  ref
                      .read(lensControllerProvider.notifier)
                      .setYear(val.toInt());
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lensState.year.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
