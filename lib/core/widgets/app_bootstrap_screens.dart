import 'package:flutter/material.dart';

/// Показывается, пока флаг онбординга читается из хранилища.
/// Рендерится внутри `MaterialApp`, поэтому Theme/Directionality доступны.
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9F8F6),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF2D4A3E)),
      ),
    );
  }
}

/// Заменяет молчаливый серый экран: объясняет, чего не хватает приложению,
/// чтобы работать с бэкендом.
class AppConfigurationScreen extends StatelessWidget {
  const AppConfigurationScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.settings_suggest_outlined,
                  size: 56,
                  color: Color(0xFF2D4A3E),
                ),
                const SizedBox(height: 20),
                Text(
                  'Eldertree не настроен',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                const SelectableText(
                  'flutter build web --release --base-href /Eldertree-/ \\\n'
                  '  --dart-define=SUPABASE_URL=<project-url> \\\n'
                  '  --dart-define=SUPABASE_ANON_KEY=<anon-key>',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
