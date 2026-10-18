import 'dart:isolate';

import 'package:flutter/material.dart';

import '../crypto/vault_crypto.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final _in = TextEditingController();
  final _pw = TextEditingController();
  String _out = '';
  bool _busy = false;
  bool _hide = true;

  @override
  void dispose() {
    _in.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _run(bool enc) async {
    final s = S.of(context);
    final text = _in.text.trim();
    final pw = _pw.text;
    if (text.isEmpty || pw.isEmpty) {
      showMsg(context, s.t('need_text_pw'));
      return;
    }
    if (enc && pw.runes.length < kMinPasswordLen) {
      showMsg(context, s.t('pw_short', {'n': kMinPasswordLen}));
      return;
    }
    setState(() => _busy = true);
    // Scrypt ثقيل: نشغّله في Isolate حتى لا تتجمد الشاشة
    final (bool ok, String value) = await Isolate.run(() {
      try {
        return (true, enc ? encryptText(text, pw) : decryptText(text, pw));
      } on CryptoError catch (e) {
        return (false, 'err_${e.code}');
      } catch (_) {
        return (false, 'err_unknown');
      }
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _out = value;
    });
    if (!ok) showMsg(context, S.of(context).t(value));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _in,
          minLines: 4,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: s.t('text_label'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pw,
          obscureText: _hide,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: s.t('password'),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _hide = !_hide),
            ),
          ),
        ),
        StrengthLabel(_pw.text),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _run(true),
                icon: const Icon(Icons.lock),
                label: Text(s.t('enc_text')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _run(false),
                icon: const Icon(Icons.lock_open),
                label: Text(s.t('dec_text')),
              ),
            ),
          ],
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: LinearProgressIndicator(),
          ),
        const SizedBox(height: 16),
        Text(s.t('result')),
        const SizedBox(height: 6),
        ResultBox(_out),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: _out.isEmpty ? null : () => copyAndAutoClear(context, _out),
            icon: const Icon(Icons.copy),
            label: Text(s.t('copy_result')),
          ),
        ),
      ],
    );
  }
}
