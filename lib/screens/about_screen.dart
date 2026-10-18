import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart' show appLocale;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final current = appLocale.value?.languageCode ?? 'auto';
    final options = <String, String>{
      'auto': s.t('lang_auto'),
      'ar': 'العربية',
      'fr': 'Français',
      'en': 'English',
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(s.t('language'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final e in options.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: current == e.key,
                onSelected: (_) =>
                    appLocale.value = e.key == 'auto' ? null : Locale(e.key),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(s.t('about_text'), style: const TextStyle(height: 1.6)),
      ],
    );
  }
}
