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

final LanguageProvider = StateProvider<Language>((ref) => Language.english);