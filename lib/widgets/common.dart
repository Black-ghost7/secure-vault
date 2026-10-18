import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../password_tools.dart';

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

/// ينسخ النص، ثم يمسح الحافظة بعد 30 ثانية (إذا لم يتغير محتواها)،
/// حتى لا تبقى كلمة المرور أو النص السري في الحافظة.
Future<void> copyAndAutoClear(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showMsg(context, S.of(context).t('copied'));
  Timer(const Duration(seconds: 30), () async {
    try {
      final d = await Clipboard.getData(Clipboard.kTextPlain);
      if (d?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {}
  });
}

const _strengthColors = [
  Color(0xFFB00020),
  Color(0xFFD84315),
  Color(0xFFF9A825),
  Color(0xFF2E7D32),
  Color(0xFF1B5E20),
];

class StrengthLabel extends StatelessWidget {
  final String password;
  const StrengthLabel(this.password, {super.key});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final s = S.of(context);
    final score = passwordStrength(password);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        s.t('strength', {'s': s.t('str$score')}),
        style: TextStyle(color: _strengthColors[score]),
      ),
    );
  }
}

class ResultBox extends StatelessWidget {
  final String text;
  final bool ltr;
  const ResultBox(this.text, {super.key, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        text,
        textDirection: ltr ? TextDirection.ltr : null,
      ),
    );
  }
}
