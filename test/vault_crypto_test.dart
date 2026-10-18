import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/crypto/vault_crypto.dart';
import 'package:my_app/l10n/strings.dart';
import 'package:my_app/password_tools.dart';

void main() {
  test('توافق: فك نص شفّره برنامج Python الأصلي', () {
    // مولَّد من tachfer.pyw بكلمة المرور test-password-123
    const token =
        'SVLTTXT1:U1ZMVDAwMDEQ1MuKwa8QupKAyvG3csMONwvEJj/ELsSzjs+wl2SH1K8Hifry'
        'puBAQ2k4VqFoh10QUl3BlOC49PjvoEF89Tc=';
    expect(decryptText(token, 'test-password-123'), 'مرحبا Flutter 123');
  });

  test('تشفير ثم فك لنص عربي', () {
    const pw = 'كلمة-مرور-قوية-123!';
    final enc = encryptText('مرحبا بالعالم', pw);
    expect(enc.startsWith(kTextPrefix), isTrue);
    expect(decryptText(enc, pw), 'مرحبا بالعالم');
  });

  test('كلمة مرور خاطئة تعطي الرمز wrongPassword', () {
    final enc = encryptText('hello', 'correct-password-1');
    expect(
      () => decryptText(enc, 'wrong-password-12'),
      throwsA(isA<CryptoError>().having((e) => e.code, 'code', 'wrongPassword')),
    );
  });

  test('بيانات أكبر من دفعة واحدة', () {
    final data =
        Uint8List.fromList(List.generate(kChunk * 2 + 123, (i) => i % 251));
    final enc = encryptBytes(data, 'a-long-password-1');
    expect(decryptBytes(enc, 'a-long-password-1'), data);
  });

  test('اكتشاف التعديل', () {
    final enc =
        encryptBytes(Uint8List.fromList([1, 2, 3, 4]), 'a-long-password-1');
    enc[enc.length - 1] ^= 1;
    expect(() => decryptBytes(enc, 'a-long-password-1'),
        throwsA(isA<CryptoError>()));
  });

  test('المولّد وقوة كلمة المرور', () {
    final p = generatePassword(20);
    expect(p.length, 20);
    expect(passwordStrength(p), greaterThanOrEqualTo(3));
    expect(passwordStrength('abc'), lessThanOrEqualTo(1));
  });

  test('الترجمة: كل لغة تملك كل المفاتيح', () {
    final en = const S('en');
    for (final code in ['ar', 'fr']) {
      final s = S(code);
      for (final key in ['app_title', 'encrypt', 'err_wrongPassword', 'about_text', 'str4', 'pw_short']) {
        expect(s.t(key), isNot(key), reason: '$code/$key');
        expect(s.t(key), isNotEmpty);
      }
    }
    expect(en.t('pw_short', {'n': 10}), contains('10'));
    expect(const S('de').t('encrypt'), 'Encrypt'); // لغة غير مدعومة ترجع للإنجليزية
    expect(S.supported.map((l) => l.languageCode), containsAll(['ar', 'fr', 'en']));
    expect(const Locale('ar').languageCode, 'ar');
  });
}
