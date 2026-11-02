import 'package:flutter/material.dart';
import 'subscription_screen.dart';

class PremiumModal {
  static void show(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium,
                size: 64, color: Color(0xFFD4AF37)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('View Premium Plans'),
            ),
            const SizedBox(height: 16),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe later'))
          ],
        ),
      ),
    );
  }
}
