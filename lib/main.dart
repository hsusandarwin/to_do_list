import 'package:coffee_shop/app_theme.dart';
import 'package:coffee_shop/l10n/app_localizations.dart';
import 'package:coffee_shop/language.dart';
import 'package:coffee_shop/providers/theme_provider.dart';
import 'package:coffee_shop/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    final Language = ref.watch(LanguageProvider);
    return GetMaterialApp(
      title: 'Firebase Test',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeState.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(Language.code),
      debugShowCheckedModeBanner: false,
      home: Wrapper(),
    );
  }
}
