import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../crypto/vault_crypto.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';

class _Picked {
  final String name;
  final String path;
  _Picked(this.name, this.path);
}

/// يعمل في Isolate منفصل: يعالج الملفات واحدًا واحدًا ويرسل رسائل التقدم.
void _worker(Map<String, Object> a) {
  final send = a['port'] as SendPort;
  final enc = a['enc'] as bool;
  final pw = a['pw'] as String;
  final outDir = a['outDir'] as String;
  final paths = (a['paths'] as List).cast<String>();
  final names = (a['names'] as List).cast<String>();

  for (var i = 0; i < paths.length; i++) {
    try {
      final base = names[i];
      final outName = enc
          ? '$base.enc'
          : (base.endsWith('.enc')
              ? base.substring(0, base.length - 4)
              : '$base.dec');
      final out = uniquePath('$outDir/$outName');
      void prog(double f) => send.send(['p', (i + f) / paths.length]);
      if (enc) {
        encryptFile(paths[i], out, pw, progress: prog);
      } else {
        decryptFile(paths[i], out, pw, progress: prog);
      }
      send.send(['ok', out]);
    } on CryptoError catch (e) {
      send.send(['err', names[i], 'err_${e.code}']);
    } catch (_) {
      send.send(['err', names[i], 'err_unknown']);
    }
  }
  send.send(['done']);
}

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  List<_Picked> _files = [];
  final List<(bool, String)> _log = [];
  List<String> _outputs = [];
  bool _hide = true;
  bool _busy = false;
  double _progress = 0;

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.pickFiles();
      if (result.isEmpty) return;
      final tmp = await getTemporaryDirectory();
      final items = <_Picked>[];
      for (final f in result) {
        var path = f.path;
        if (path == null) {
          // احتياط: إذا لم يعطِ النظام مسارًا نكتب نسخة مؤقتة من البيانات
          final dir = Directory('${tmp.path}/vault_in')
            ..createSync(recursive: true);
          path = '${dir.path}/${f.name}';
          await File(path).writeAsBytes(await f.readAsBytes());
        }
        items.add(_Picked(f.name, path));
      }
      if (!mounted) return;
      setState(() {
        _files = items;
        _outputs = [];
        _log.clear();
      });
    } catch (_) {
      if (mounted) showMsg(context, S.of(context).t('err_unknown'));
    }
  }

  Future<void> _run(bool enc) async {
    final s = S.of(context);
    final pw = _pw.text;
    if (_files.isEmpty) {
      showMsg(context, s.t('need_files'));
      return;
    }
    if (pw.isEmpty) {
      showMsg(context, s.t('need_pw'));
      return;
    }
    if (enc) {
      if (pw.runes.length < kMinPasswordLen) {
        showMsg(context, s.t('pw_short', {'n': kMinPasswordLen}));
        return;
      }
      if (pw != _pw2.text) {
        showMsg(context, s.t('pw_mismatch'));
        return;
      }
    }

    final tmp = await getTemporaryDirectory();
    final outDir = Directory('${tmp.path}/vault_out');
    if (outDir.existsSync()) outDir.deleteSync(recursive: true);
    outDir.createSync(recursive: true);

    setState(() {
      _busy = true;
      _progress = 0;
      _outputs = [];
      _log.clear();
    });

    final port = ReceivePort();
    await Isolate.spawn(_worker, <String, Object>{
      'port': port.sendPort,
      'enc': enc,
      'pw': pw,
      'outDir': outDir.path,
      'paths': _files.map((f) => f.path).toList(),
      'names': _files.map((f) => f.name).toList(),
    });

    final outputs = <String>[];
    await for (final m in port) {
      final msg = m as List;
      if (!mounted) {
        port.close();
        break;
      }
      switch (msg[0]) {
        case 'p':
          setState(() => _progress = msg[1] as double);
        case 'ok':
          final out = msg[1] as String;
          outputs.add(out);
          setState(() => _log.add((true, out.split('/').last)));
        case 'err':
          setState(() =>
              _log.add((false, '${msg[1]}: ${S.of(context).t(msg[2] as String)}')));
        case 'done':
          port.close();
      }
    }
    if (!mounted) return;

    // حذف النسخ المؤقتة التي أنشأها منتقي الملفات (لا نمس الملفات الأصلية)
    for (final f in _files) {
      try {
        if (f.path.startsWith(tmp.path)) File(f.path).deleteSync();
      } catch (_) {}
    }

    setState(() {
      _busy = false;
      _progress = 1;
      _outputs = outputs;
      _files = [];
      _log.add((
        true,
        S.of(context).t('done_summary', {
          'ok': outputs.length,
          'n': _log.length,
        })
      ));
    });
  }

  Future<void> _share() async {
    if (_outputs.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(files: _outputs.map((p) => XFile(p)).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final summary = _files.isEmpty
        ? s.t('no_files')
        : (_files.length == 1
            ? _files.first.name
            : s.t('n_files', {'n': _files.length}));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: _busy ? null : _pick,
          icon: const Icon(Icons.attach_file),
          label: Text(s.t('pick_files')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(summary),
        ),
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
        const SizedBox(height: 12),
        TextField(
          controller: _pw2,
          obscureText: _hide,
          decoration: InputDecoration(
            labelText: s.t('confirm_pw'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _run(true),
                icon: const Icon(Icons.lock),
                label: Text(s.t('encrypt')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _run(false),
                icon: const Icon(Icons.lock_open),
                label: Text(s.t('decrypt')),
              ),
            ),
          ],
        ),
        if (_busy || _progress > 0)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: LinearProgressIndicator(value: _busy ? _progress : 1),
          ),
        if (_log.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(s.t('log')),
          const SizedBox(height: 6),
          for (final (ok, text) in _log)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${ok ? '✅' : '❌'} $text'),
            ),
        ],
        if (_outputs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FilledButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.ios_share),
              label: Text(s.t('share_results')),
            ),
          ),
        const SizedBox(height: 16),
        Text(s.t('files_note'),
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
