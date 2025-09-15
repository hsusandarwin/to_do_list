import 'package:coffee_shop/l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum Language {
  english(flag: '🇺🇲',name: 'English',code: 'en'),
  myanmar(flag: '🇲🇲',name: 'မြန်မာ',code: 'my'),
  japanese(flag: '🇯🇵',name: '日本',code: 'ja'),
  korea(flag: '🇰🇷',name: '한국',code: 'ko');

const Language({required this.flag,required this.name,required this.code});

final String flag;
final String name;
final String code;
}

// ignore: non_constant_identifier_names
final LanguageProvider = StateProvider<Language>((ref) => Language.english);


final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final languageState = ref.watch(LanguageProvider);
  final locale = Locale(languageState.code);
  return lookupAppLocalizations(locale);
});