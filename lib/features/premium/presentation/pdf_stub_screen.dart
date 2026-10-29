import 'package:flutter/material.dart';

class PdfStubScreen extends StatelessWidget {
  const PdfStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poster Export')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 4),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10))
                  ],
                ),
                child: Center(
                    child: Icon(Icons.account_tree,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 40),
              const Text('Heirloom Quality Poster',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'Generate a high-resolution, print-ready PDF of your entire family tree. Perfect for framing or family reunions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.hourglass_bottom),
                label: const Text('Coming in next update'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
