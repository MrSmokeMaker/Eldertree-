import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../subscription_controller.dart';
import '../../../data/models/enums.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionControllerProvider);
    final currentTier = subState.value?.tierLevel ?? TierLevel.free;

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Archive')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Preserve your family legacy\nfor generations to come.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildTierCard(
            context,
            title: 'Free',
            price: '\$0',
            features: [
              'Up to 15 family members',
              'Basic text facts',
              'Standard tree export'
            ],
            isCurrent: currentTier == TierLevel.free,
          ),
          const SizedBox(height: 16),
          _buildTierCard(
            context,
            title: 'Standard',
            price: '\$4.99/mo',
            features: [
              'Up to 100 family members',
              'Full text interview',
              'Photo uploads'
            ],
            isCurrent: currentTier == TierLevel.standard,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFE5C158)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 20)
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: _buildTierCard(
              context,
              title: 'Pro',
              price: '\$9.99/mo',
              features: [
                'Unlimited members',
                'Voice capsules & Reminders',
                'Print-ready PDF Export',
                'Seasonal Themes'
              ],
              isCurrent: currentTier == TierLevel.pro,
              isPro: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool isCurrent,
    bool isPro = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D24) : Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPro ? const Color(0xFFD4AF37) : null)),
              if (isPro)
                const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.workspace_premium,
                        color: Color(0xFFD4AF37))),
              const Spacer(),
              if (isCurrent)
                Chip(
                    label:
                        const Text('Current', style: TextStyle(fontSize: 12)),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(price,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Icon(Icons.check_circle,
                      size: 16,
                      color: isPro ? const Color(0xFFD4AF37) : Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f)),
                ]),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPro ? const Color(0xFFD4AF37) : null,
                foregroundColor: isPro ? Colors.black : null,
              ),
              child: Text(isCurrent ? 'Active' : 'Upgrade to $title'),
            ),
          )
        ],
      ),
    );
  }
}
