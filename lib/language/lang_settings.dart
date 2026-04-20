// ignore_for_file: deprecated_member_use

import '../global/config.dart';

class SelectLanguageScreen extends ConsumerStatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  ConsumerState<SelectLanguageScreen> createState() =>
      _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends ConsumerState<SelectLanguageScreen> {
  // ✅ Key is a constant — never overwritten
  static const String _kLangKey = 'selectedLang';

  String _selectedLanguage = 'English';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<LanguageItem> _filteredLanguages = [];

  final List<LanguageItem> _languages = [
    LanguageItem(flag: '🇺🇸', name: 'English', code: 'en'),
    LanguageItem(flag: '🇪🇸', name: 'Español', code: 'es'),
    LanguageItem(flag: '🇩🇪', name: 'Deutsch', code: 'de'),
    LanguageItem(flag: '🇫🇷', name: 'Français', code: 'fr'),
    LanguageItem(flag: '🇮🇩', name: 'Bahasa Indonesia', code: 'id'),
    LanguageItem(flag: '🇹🇷', name: 'Türkçe', code: 'tr'),
    LanguageItem(flag: '🇵🇹', name: 'Português', code: 'pt'),
    LanguageItem(flag: '🇮🇳', name: 'हिन्दी', code: 'hi'),
  ];

  @override
  void initState() {
    super.initState();
    _filteredLanguages = List.from(_languages);
    _searchController.addListener(_filterLanguages);
    _loadSavedLanguage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Filter ────────────────────────────────────────────────────────────────

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredLanguages = query.isEmpty
          ? List.from(_languages)
          : _languages.where((l) {
              return l.name.toLowerCase().contains(query) ||
                  l.flag.contains(query);
            }).toList();
    });
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _saveLang(LanguageItem val) async {
    final prefs = await SharedPreferences.getInstance();
    // Save the language NAME so we can restore selection on next open
    await prefs.setString(_kLangKey, val.name);
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Read saved name — default to 'English' if nothing saved yet
    final savedName = prefs.getString(_kLangKey) ?? 'English';
    if (mounted) {
      setState(() => _selectedLanguage = savedName);
    }
    // Scroll to selected language after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  // ── Scroll to selected ────────────────────────────────────────────────────

  void _scrollToSelected() {
    final index = _filteredLanguages.indexWhere(
      (l) => l.name == _selectedLanguage,
    );
    if (index == -1 || !_scrollController.hasClients) return;

    // Each item is roughly 72px tall — scroll so it sits near the top
    const double itemHeight = 72.0;
    final double offset = (index * itemHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ── Select ────────────────────────────────────────────────────────────────

  void _onSelectLanguage(LanguageItem language) {
    setState(() => _selectedLanguage = language.name);
    _saveLang(language);
    ref.read(langPro.notifier).handleLang(Locale(language.code));
    NavigatorExt(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? DarkModeColors.darkPrimary
        : LightModeColors.lightPrimary;

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: MyAppbar(
        text: context.locale.selectLang,
        fontWeight: FontWeight.w600,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Container(
              decoration: BoxDecoration(
                color:
                    context.theme.colorScheme.surfaceContainerHighest
                        ?.withValues(alpha: 0.5) ??
                    Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search language',
                  hintStyle: GoogleFonts.montserrat(
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  // ✅ Clear button when typing
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _filterLanguages();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),

          // ── Selected language indicator ─────────────────────────────────
          if (_searchController.text.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  // ✅ Flag emoji of the currently selected language
                  Text(
                    _languages
                        .firstWhere(
                          (l) => l.name == _selectedLanguage,
                          orElse: () => _languages.first,
                        )
                        .flag,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Current: $_selectedLanguage',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      color: primaryColor.withValues(alpha: 0.8),
                      fontWeight: .w500,
                    ),
                  ),
                ],
              ),
            ),

          // ── Language list ───────────────────────────────────────────────
          Expanded(
            child: _filteredLanguages.isEmpty
                ? Center(
                    child: Text(
                      'No language found',
                      style: GoogleFonts.montserrat(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    // ✅ scrollable so selected item is reachable
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    itemCount: _filteredLanguages.length,
                    separatorBuilder: (_, __) =>
                        Divider(indent: 20.r, height: 20.r),
                    itemBuilder: (context, index) {
                      final language = _filteredLanguages[index];
                      final isSelected = language.name == _selectedLanguage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.07)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? primaryColor.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                language.flag,
                                style: TextStyle(fontSize: 22.sp),
                              ),
                            ),
                          ),
                          title: Text(
                            language.name,
                            style: GoogleFonts.montserrat(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? primaryColor
                                  : context.theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 22.r,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked_rounded,
                                  color: context.theme.colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                                  size: 22.r,
                                ),
                          onTap: () => _onSelectLanguage(language),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
