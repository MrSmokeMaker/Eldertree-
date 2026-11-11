import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for default seed color used throughout the app.
final defaultSeedColorProvider =
    Provider<Color>((ref) => const Color(0xFF2D4A3E));

/// Map of member IDs to custom seed colors. Populate as needed.
final memberSeedColorMapProvider = Provider<Map<String, Color>>((ref) => {
      // 'memberId1': Color(0xFF2D4A3E),
      // 'memberId2': Color(0xFFD4AF37),
    });

/// Returns the seed color for a specific member, falling back to default.
Color getSeedColorForMember(String memberId, WidgetRef ref) {
  final map = ref.watch(memberSeedColorMapProvider);
  return map[memberId] ?? ref.watch(defaultSeedColorProvider);
}
