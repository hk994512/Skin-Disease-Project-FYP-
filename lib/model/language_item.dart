class LanguageItem {
  final String flag;
  final String name;
  final String code;
  final bool isSelected;
  LanguageItem({
    required this.flag,
    required this.name,
    required this.code,
    this.isSelected = false,
  });
}
