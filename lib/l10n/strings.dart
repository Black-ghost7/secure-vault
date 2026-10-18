import 'package:flutter/widgets.dart';

/// الترجمات. اللغة تُؤخذ من لغة الهاتف تلقائيًا (انظر main.dart)،
/// وإذا كانت لغة الهاتف غير مدعومة نستعمل الإنجليزية.
/// لإضافة لغة جديدة: أضف خريطة جديدة هنا، وأضفها إلى S.supported.
class S {
  final String lang;
  const S(this.lang);

  static const supported = [Locale('ar'), Locale('fr'), Locale('en')];

  static S of(BuildContext context) =>
      S(Localizations.localeOf(context).languageCode);

  String t(String key, [Map<String, Object> args = const {}]) {
    var s = _data[lang]?[key] ?? _data['en']![key] ?? key;
    args.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }

  static const Map<String, Map<String, String>> _data = {
    // ------------------------------------------------------------ العربية
    'ar': {
      'app_title': 'خزنة التشفير الآمنة',
      'nav_files': 'الملفات',
      'nav_text': 'النصوص',
      'nav_gen': 'المولّد',
      'nav_about': 'حول',
      'pick_files': 'اختيار ملفات أو صور',
      'no_files': 'لم يتم اختيار أي ملف',
      'n_files': 'تم اختيار {n} ملف',
      'password': 'كلمة المرور',
      'confirm_pw': 'تأكيد كلمة المرور (عند التشفير)',
      'strength': 'قوة كلمة المرور: {s}',
      'str0': 'ضعيفة جداً',
      'str1': 'ضعيفة',
      'str2': 'متوسطة',
      'str3': 'قوية',
      'str4': 'قوية جداً',
      'encrypt': 'تشفير',
      'decrypt': 'فك التشفير',
      'log': 'السجل',
      'done_summary': 'انتهى: نجح {ok} من {n}',
      'share_results': 'حفظ / مشاركة الناتج',
      'files_note':
          'الملفات الأصلية لا تُحذف. النسخ الناتجة مؤقتة: استعمل «حفظ / مشاركة» لحفظها (مثلاً في الملفات أو Drive).',
      'need_files': 'اختر ملفاً واحداً على الأقل.',
      'need_pw': 'أدخل كلمة المرور.',
      'pw_mismatch': 'كلمتا المرور غير متطابقتين.',
      'pw_short':
          'كلمة المرور يجب ألا تقل عن {n} أحرف. استعمل تبويب «المولّد» لإنشاء واحدة قوية.',
      'text_label': 'النص (للتشفير) أو النص المشفر (لفك التشفير)',
      'enc_text': 'تشفير النص',
      'dec_text': 'فك التشفير',
      'result': 'النتيجة',
      'copy_result': 'نسخ النتيجة',
      'copy': 'نسخ',
      'copied': 'تم النسخ (يُمسح من الحافظة بعد 30 ثانية)',
      'need_text_pw': 'أدخل النص وكلمة المرور.',
      'gen_len': 'طول كلمة المرور: {n}',
      'gen_btn': 'توليد كلمة مرور',
      'gen_warn':
          '⚠ احفظ كلمة المرور في مكان آمن (مثل مدير كلمات مرور).\nإذا ضاعت لا توجد أي طريقة لاسترجاع ملفاتك.',
      'err_notVault': 'هذا الملف ليس مشفراً بهذا البرنامج',
      'err_badHeader': 'ترويسة الملف تالفة',
      'err_truncated': 'الملف تالف أو مقتطع',
      'err_wrongPassword': 'كلمة المرور خاطئة أو أن الملف تم تعديله/تلف',
      'err_notText': 'هذا ليس نصاً مشفراً بهذا البرنامج',
      'err_badText': 'النص المشفر تالف',
      'err_badUtf8': 'النتيجة ليست نصاً صالحاً',
      'err_alreadyEnc': 'الملف مشفر مسبقاً (.enc)',
      'err_unknown': 'حدث خطأ غير متوقع',
      'language': 'اللغة',
      'lang_auto': 'تلقائي (لغة الهاتف)',
      'about_text': 'خزنة التشفير الآمنة\n\n'
          '• التشفير: AES-256-GCM\n'
          '• اشتقاق المفتاح: Scrypt (64MB ذاكرة)\n'
          '• كل ملف له Salt و Nonce عشوائيان\n'
          '• أي تعديل على الملف المشفر يتم اكتشافه\n'
          '• التطبيق يعمل دون إنترنت، ولا يرسل أي بيانات\n\n'
          '⚠ مهم:\n'
          'كلمة المرور هي المفتاح الوحيد. لا يوجد أي باب خلفي،\n'
          'ولا يمكن لأي أحد (حتى مبرمج التطبيق) استرجاع ملفاتك إذا نسيتها.',
    },
    // ------------------------------------------------------------ Français
    'fr': {
      'app_title': 'Coffre de chiffrement sécurisé',
      'nav_files': 'Fichiers',
      'nav_text': 'Textes',
      'nav_gen': 'Générateur',
      'nav_about': 'À propos',
      'pick_files': 'Choisir des fichiers ou photos',
      'no_files': 'Aucun fichier choisi',
      'n_files': '{n} fichier(s) choisi(s)',
      'password': 'Mot de passe',
      'confirm_pw': 'Confirmer le mot de passe (chiffrement)',
      'strength': 'Force du mot de passe : {s}',
      'str0': 'Très faible',
      'str1': 'Faible',
      'str2': 'Moyen',
      'str3': 'Fort',
      'str4': 'Très fort',
      'encrypt': 'Chiffrer',
      'decrypt': 'Déchiffrer',
      'log': 'Journal',
      'done_summary': 'Terminé : {ok} réussi(s) sur {n}',
      'share_results': 'Enregistrer / partager le résultat',
      'files_note':
          "Les fichiers originaux ne sont pas supprimés. Les copies produites sont temporaires : utilisez « Enregistrer / partager » pour les conserver (Fichiers, Drive…).",
      'need_files': 'Choisissez au moins un fichier.',
      'need_pw': 'Saisissez le mot de passe.',
      'pw_mismatch': 'Les mots de passe ne correspondent pas.',
      'pw_short':
          "Le mot de passe doit contenir au moins {n} caractères. Utilisez l'onglet « Générateur » pour en créer un solide.",
      'text_label': 'Texte (à chiffrer) ou texte chiffré (à déchiffrer)',
      'enc_text': 'Chiffrer le texte',
      'dec_text': 'Déchiffrer',
      'result': 'Résultat',
      'copy_result': 'Copier le résultat',
      'copy': 'Copier',
      'copied': 'Copié (le presse-papiers sera vidé dans 30 s)',
      'need_text_pw': 'Saisissez le texte et le mot de passe.',
      'gen_len': 'Longueur du mot de passe : {n}',
      'gen_btn': 'Générer un mot de passe',
      'gen_warn':
          "⚠ Conservez le mot de passe en lieu sûr (gestionnaire de mots de passe).\nS'il est perdu, il n'existe aucun moyen de récupérer vos fichiers.",
      'err_notVault': "Ce fichier n'a pas été chiffré par cette application",
      'err_badHeader': 'En-tête du fichier corrompu',
      'err_truncated': 'Fichier corrompu ou tronqué',
      'err_wrongPassword': 'Mot de passe incorrect, ou fichier modifié/corrompu',
      'err_notText': "Ce n'est pas un texte chiffré par cette application",
      'err_badText': 'Texte chiffré corrompu',
      'err_badUtf8': "Le résultat n'est pas un texte valide",
      'err_alreadyEnc': 'Fichier déjà chiffré (.enc)',
      'err_unknown': "Une erreur inattendue s'est produite",
      'language': 'Langue',
      'lang_auto': 'Automatique (langue du téléphone)',
      'about_text': 'Coffre de chiffrement sécurisé\n\n'
          '• Chiffrement : AES-256-GCM\n'
          '• Dérivation de clé : Scrypt (64 Mo de mémoire)\n'
          '• Chaque fichier a un Salt et un Nonce aléatoires\n'
          '• Toute modification du fichier chiffré est détectée\n'
          "• L'application fonctionne hors ligne et n'envoie aucune donnée\n\n"
          '⚠ Important :\n'
          "Le mot de passe est la seule clé. Il n'y a aucune porte dérobée :\n"
          "personne (pas même le développeur) ne peut récupérer vos fichiers si vous l'oubliez.",
    },
    // ------------------------------------------------------------ English
    'en': {
      'app_title': 'Secure Vault',
      'nav_files': 'Files',
      'nav_text': 'Text',
      'nav_gen': 'Generator',
      'nav_about': 'About',
      'pick_files': 'Choose files or photos',
      'no_files': 'No file selected',
      'n_files': '{n} file(s) selected',
      'password': 'Password',
      'confirm_pw': 'Confirm password (when encrypting)',
      'strength': 'Password strength: {s}',
      'str0': 'Very weak',
      'str1': 'Weak',
      'str2': 'Fair',
      'str3': 'Strong',
      'str4': 'Very strong',
      'encrypt': 'Encrypt',
      'decrypt': 'Decrypt',
      'log': 'Log',
      'done_summary': 'Finished: {ok} of {n} succeeded',
      'share_results': 'Save / share result',
      'files_note':
          'Original files are not deleted. The resulting copies are temporary: use "Save / share" to keep them (Files, Drive…).',
      'need_files': 'Choose at least one file.',
      'need_pw': 'Enter the password.',
      'pw_mismatch': 'The passwords do not match.',
      'pw_short':
          'The password must be at least {n} characters. Use the Generator tab to create a strong one.',
      'text_label': 'Text (to encrypt) or encrypted text (to decrypt)',
      'enc_text': 'Encrypt text',
      'dec_text': 'Decrypt',
      'result': 'Result',
      'copy_result': 'Copy result',
      'copy': 'Copy',
      'copied': 'Copied (clipboard will be cleared in 30 s)',
      'need_text_pw': 'Enter the text and the password.',
      'gen_len': 'Password length: {n}',
      'gen_btn': 'Generate password',
      'gen_warn':
          '⚠ Keep the password somewhere safe (e.g. a password manager).\nIf it is lost, there is no way to recover your files.',
      'err_notVault': 'This file was not encrypted by this app',
      'err_badHeader': 'The file header is damaged',
      'err_truncated': 'The file is damaged or truncated',
      'err_wrongPassword': 'Wrong password, or the file was modified/damaged',
      'err_notText': 'This is not text encrypted by this app',
      'err_badText': 'The encrypted text is damaged',
      'err_badUtf8': 'The result is not valid text',
      'err_alreadyEnc': 'File is already encrypted (.enc)',
      'err_unknown': 'An unexpected error occurred',
      'language': 'Language',
      'lang_auto': 'Automatic (phone language)',
      'about_text': 'Secure Vault\n\n'
          '• Encryption: AES-256-GCM\n'
          '• Key derivation: Scrypt (64 MB memory)\n'
          '• Every file gets a random Salt and Nonce\n'
          '• Any change to an encrypted file is detected\n'
          '• The app works offline and sends no data anywhere\n\n'
          '⚠ Important:\n'
          'The password is the only key. There is no back door:\n'
          'nobody (not even the app developer) can recover your files if you forget it.',
    },
  };
}
