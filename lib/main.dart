import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/strings.dart';
import 'screens/about_screen.dart';
import 'screens/files_screen.dart';
import 'screens/generator_screen.dart';
import 'screens/text_screen.dart';

/// null = تلقائي (لغة الهاتف). يمكن للمستخدم تغييرها يدويًا من شاشة «حول».
final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

void main() => runApp(const VaultApp());

class VaultApp extends StatelessWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, manual, _) => MaterialApp(
        onGenerateTitle: (c) => S.of(c).t('app_title'),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        locale: manual,
        supportedLocales: S.supported,
        // هذه المفوّضات تجعل اتجاه الشاشة (يمين/يسار) ونصوص النظام تتبع اللغة
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // نمر على قائمة لغات الهاتف بالترتيب ونختار أول لغة ندعمها،
        // وإذا لم نجد نستعمل الإنجليزية.
        localeListResolutionCallback: (locales, supported) {
          for (final l in locales ?? const <Locale>[]) {
            for (final s in supported) {
              if (s.languageCode == l.languageCode) return s;
            }
          }
          return const Locale('en');
        },
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('app_title'))),
      body: IndexedStack(
        index: _index,
        children: const [
          FilesScreen(),
          TextScreen(),
          GeneratorScreen(),
          AboutScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.folder_outlined), label: s.t('nav_files')),
          NavigationDestination(
              icon: const Icon(Icons.notes), label: s.t('nav_text')),
          NavigationDestination(
              icon: const Icon(Icons.vpn_key_outlined), label: s.t('nav_gen')),
          NavigationDestination(
              icon: const Icon(Icons.info_outline), label: s.t('nav_about')),
        ],
      ),
    );
  }
}
