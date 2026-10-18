import 'dart:math';

import 'crypto/vault_crypto.dart' show kMinPasswordLen;

/// يرجع درجة من 0 إلى 4 (النص الوصفي يأتي من الترجمة: str0..str4)
int passwordStrength(String pw) {
  if (pw.isEmpty) return 0;
  final len = pw.runes.length;
  var score = 0;
  if (len >= kMinPasswordLen) score++;
  if (len >= 14) score++;

  final kinds = [
    RegExp(r'\p{Ll}', unicode: true),
    RegExp(r'\p{Lu}', unicode: true),
    RegExp(r'\p{Nd}', unicode: true),
    RegExp(r'[^\p{L}\p{N}]', unicode: true),
  ].where((r) => r.hasMatch(pw)).length;

  if (kinds >= 3) score++;
  if (kinds == 4 && len >= 12) score++;
  if (len < kMinPasswordLen) score = min(score, 1);
  return score;
}

String generatePassword([int length = 20]) {
  const alphabet =
      r'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+?';
  final rnd = Random.secure();
  while (true) {
    final pw = List.generate(
        length, (_) => alphabet[rnd.nextInt(alphabet.length)]).join();
    if (RegExp('[a-z]').hasMatch(pw) &&
        RegExp('[A-Z]').hasMatch(pw) &&
        RegExp('[0-9]').hasMatch(pw) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) {
      return pw;
    }
  }
}
