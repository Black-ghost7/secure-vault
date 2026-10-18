import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../password_tools.dart';
import '../widgets/common.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  double _len = 20;
  String _pw = '';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(s.t('gen_len', {'n': _len.round()})),
        Slider(
          min: 12,
          max: 64,
          divisions: 52,
          value: _len,
          label: _len.round().toString(),
          onChanged: (v) => setState(() => _len = v),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => setState(() => _pw = generatePassword(_len.round())),
          icon: const Icon(Icons.casino),
          label: Text(s.t('gen_btn')),
        ),
        const SizedBox(height: 16),
        ResultBox(_pw.isEmpty ? '—' : _pw, ltr: true),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: _pw.isEmpty ? null : () => copyAndAutoClear(context, _pw),
            icon: const Icon(Icons.copy),
            label: Text(s.t('copy')),
          ),
        ),
        const SizedBox(height: 16),
        Text(s.t('gen_warn')),
      ],
    );
  }
}
