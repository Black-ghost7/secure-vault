// نواة التشفير: AES-256-GCM + Scrypt
// مطابقة تمامًا لصيغة ملفات برنامج Python (SVLT0001)، فيمكن فك ملفات
// الحاسوب على الهاتف والعكس.
//
// الصيغة:
//   الترويسة (33 بايت) = "SVLT0001" + log2(N) + salt(16) + prefix(8)
//   ثم دفعات: كل دفعة (حتى 1MB) تُشفَّر بـ AES-GCM
//     nonce = prefix + عداد(4 بايت، big-endian)
//     aad   = الترويسة + (1 إذا كانت آخر دفعة، وإلا 0)
//   وتُكتب الدفعة المشفرة = نص مشفر + وسم 16 بايت

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

final Uint8List kMagic = Uint8List.fromList(ascii.encode('SVLT0001'));
const int kChunk = 1024 * 1024;
const int kTag = 16;
const int kScryptLog2N = 16; // 2^16 => 64MB ذاكرة
const int kMinPasswordLen = 10;
const String kTextPrefix = 'SVLTTXT1:';
const int _headerLen = 8 + 1 + 16 + 8;

/// أخطاء التشفير تُرجع «رمزًا» وليس نصًا، لتُترجَم في الواجهة حسب لغة الهاتف.
/// الرموز: notVault, badHeader, truncated, wrongPassword, notText,
/// badText, badUtf8, alreadyEnc
class CryptoError implements Exception {
  final String code;
  CryptoError(this.code);
  @override
  String toString() => code;
}

typedef ReadFn = Uint8List Function(int n); // يرجع بايتات فارغة عند النهاية
typedef WriteFn = void Function(Uint8List data);
typedef ProgressFn = void Function(double fraction);

// ---------------------------------------------------------------- أدوات

Uint8List _randomBytes(int n) {
  final r = Random.secure();
  return Uint8List.fromList(List<int>.generate(n, (_) => r.nextInt(256)));
}

Uint8List deriveKey(String password, Uint8List salt, int nLog2) {
  final scrypt = Scrypt()..init(ScryptParameters(1 << nLog2, 8, 1, 32, salt));
  return scrypt.process(Uint8List.fromList(utf8.encode(password)));
}

Uint8List _nonce(Uint8List prefix, int counter) {
  final n = Uint8List(12);
  n.setRange(0, 8, prefix);
  n[8] = (counter >> 24) & 0xFF;
  n[9] = (counter >> 16) & 0xFF;
  n[10] = (counter >> 8) & 0xFF;
  n[11] = counter & 0xFF;
  return n;
}

Uint8List _aad(Uint8List header, bool last) {
  final a = Uint8List(header.length + 1);
  a.setRange(0, header.length, header);
  a[header.length] = last ? 1 : 0;
  return a;
}

Uint8List _gcm(bool encrypt, Uint8List key, Uint8List nonce, Uint8List aad,
    Uint8List data) {
  final c = GCMBlockCipher(AESEngine())
    ..init(encrypt, AEADParameters(KeyParameter(key), 128, nonce, aad));
  return c.process(data);
}

Uint8List _readFull(ReadFn read, int n) {
  final b = BytesBuilder(copy: false);
  var left = n;
  while (left > 0) {
    final part = read(left);
    if (part.isEmpty) break;
    b.add(part);
    left -= part.length;
  }
  return b.takeBytes();
}

bool _sameBytes(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// ---------------------------------------------------------------- التيار

void encryptStream(ReadFn read, WriteFn write, String password,
    {ProgressFn? progress, int total = 0}) {
  final salt = _randomBytes(16);
  final prefix = _randomBytes(8);
  final header =
      Uint8List.fromList([...kMagic, kScryptLog2N, ...salt, ...prefix]);
  write(header);

  final key = deriveKey(password, salt, kScryptLog2N);
  var counter = 0;
  var cur = _readFull(read, kChunk);
  var readSoFar = cur.length;
  while (true) {
    final nxt = _readFull(read, kChunk);
    readSoFar += nxt.length;
    final last = nxt.isEmpty;
    write(_gcm(true, key, _nonce(prefix, counter), _aad(header, last), cur));
    counter++;
    if (progress != null && total > 0) {
      progress(min(1.0, readSoFar / total));
    }
    if (last) break;
    cur = nxt;
  }
}

void decryptStream(ReadFn read, WriteFn write, String password,
    {ProgressFn? progress, int total = 0}) {
  final header = _readFull(read, _headerLen);
  if (header.length < _headerLen ||
      !_sameBytes(header.sublist(0, 8), kMagic)) {
    throw CryptoError('notVault');
  }
  final nLog2 = header[8];
  if (nLog2 < 14 || nLog2 > 20) {
    throw CryptoError('badHeader');
  }
  final salt = Uint8List.fromList(header.sublist(9, 25));
  final prefix = Uint8List.fromList(header.sublist(25, 33));

  final key = deriveKey(password, salt, nLog2);
  var counter = 0;
  var cur = _readFull(read, kChunk + kTag);
  if (cur.length < kTag) throw CryptoError('truncated');
  var readSoFar = header.length + cur.length;
  while (true) {
    final nxt = _readFull(read, kChunk + kTag);
    readSoFar += nxt.length;
    final last = nxt.isEmpty;
    try {
      write(_gcm(false, key, _nonce(prefix, counter), _aad(header, last), cur));
    } on InvalidCipherTextException {
      throw CryptoError('wrongPassword');
    }
    counter++;
    if (progress != null && total > 0) {
      progress(min(1.0, readSoFar / total));
    }
    if (last) break;
    cur = nxt;
  }
}

// ---------------------------------------------------------------- الذاكرة

ReadFn _memReader(Uint8List data) {
  var pos = 0;
  return (int n) {
    final end = min(pos + n, data.length);
    final out = Uint8List.sublistView(data, pos, end);
    pos = end;
    return out;
  };
}

Uint8List encryptBytes(Uint8List data, String password) {
  final out = BytesBuilder(copy: false);
  encryptStream(_memReader(data), out.add, password);
  return out.takeBytes();
}

Uint8List decryptBytes(Uint8List data, String password) {
  final out = BytesBuilder(copy: false);
  decryptStream(_memReader(data), out.add, password);
  return out.takeBytes();
}

// ---------------------------------------------------------------- النصوص

String encryptText(String text, String password) {
  final enc = encryptBytes(Uint8List.fromList(utf8.encode(text)), password);
  return kTextPrefix + base64.encode(enc);
}

String decryptText(String token, String password) {
  token = token.trim();
  if (!token.startsWith(kTextPrefix)) {
    throw CryptoError('notText');
  }
  final Uint8List raw;
  try {
    final b64 =
        token.substring(kTextPrefix.length).replaceAll(RegExp(r'\s'), '');
    raw = base64.decode(b64);
  } catch (_) {
    throw CryptoError('badText');
  }
  final plain = decryptBytes(raw, password);
  try {
    return utf8.decode(plain);
  } on FormatException {
    throw CryptoError('badUtf8');
  }
}

// ---------------------------------------------------------------- الملفات
// (جاهزة للخطوة القادمة: شاشة الملفات. تعمل بشكل متزامن، فتُشغَّل داخل Isolate)

String uniquePath(String path) {
  if (!File(path).existsSync()) return path;
  final dot = path.lastIndexOf('.');
  final slash = path.lastIndexOf(Platform.pathSeparator);
  final hasExt = dot > slash + 1;
  final base = hasExt ? path.substring(0, dot) : path;
  final ext = hasExt ? path.substring(dot) : '';
  var i = 1;
  while (File('$base ($i)$ext').existsSync()) {
    i++;
  }
  return '$base ($i)$ext';
}

void _processFile(bool encrypt, String inPath, String outPath, String password,
    ProgressFn? progress) {
  final tmp = '$outPath.part';
  final fin = File(inPath).openSync();
  final fout = File(tmp).openSync(mode: FileMode.write);
  var ok = false;
  try {
    final total = fin.lengthSync();
    final fn = encrypt ? encryptStream : decryptStream;
    fn((n) => fin.readSync(n), (d) => fout.writeFromSync(d), password,
        progress: progress, total: total);
    ok = true;
  } finally {
    fin.closeSync();
    fout.closeSync();
    if (!ok && File(tmp).existsSync()) File(tmp).deleteSync();
  }
  File(tmp).renameSync(outPath);
}

void encryptFile(String inPath, String outPath, String password,
    {ProgressFn? progress}) {
  if (inPath.endsWith('.enc')) throw CryptoError('alreadyEnc');
  _processFile(true, inPath, outPath, password, progress);
}

void decryptFile(String inPath, String outPath, String password,
    {ProgressFn? progress}) {
  _processFile(false, inPath, outPath, password, progress);
}
