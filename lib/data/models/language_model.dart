class LanguageModel {
  final String code;
  final String name;
  final String flag;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flag,
  });

  static const List<LanguageModel> languages = [
    LanguageModel(code: 'fr', name: 'Français', flag: '🇫🇷'),
    LanguageModel(code: 'en', name: 'English', flag: '🇺🇸'),
    LanguageModel(code: 'ar', name: 'العربية', flag: '🇹🇳'),
  ];
}
