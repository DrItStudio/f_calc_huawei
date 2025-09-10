import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../main.dart';
import 'license_screen.dart';
import 'document_template_screen.dart';
import '../ads_controller.dart';
import '../screens/vip.dart';
import '../widgets/main_drawer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int themeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadThemeIndex();
  }

  Future<void> _loadThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      themeIndex = prefs.getInt('selected_theme_index') ?? 11;
    });
    themeNotifier.value = themeIndex;
  }

  Future<void> _saveThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_theme_index', index);
    setState(() {
      themeIndex = index;
    });
    themeNotifier.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await AdsController().showInterstitialIfNeeded();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () async {
                await AdsController().showInterstitialIfNeeded();
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: Row(
            children: [
              Image.asset(
                'assets/icons/appbar_icon.png',
                height: 32,
                width: 32,
                color: Theme.of(context).iconTheme.color,
              ),
              SizedBox(width: 12),
              Expanded(
                child: AutoSizeText(
                  'menu_settings'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  minFontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!AdsController().isSubscribed) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        title: Row(
                          children: [
                            Icon(Icons.workspace_premium,
                                color: Color(0xFFFFD700), size: 28),
                            SizedBox(width: 10),
                            Text(
                              'pro_offer_title'.tr(),
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'pro_offer_desc'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFFFFD700)),
                                SizedBox(width: 8),
                                Text('pro_feature_export'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFFFFD700)),
                                SizedBox(width: 8),
                                Text('pro_feature_no_ads'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFFFFD700)),
                                SizedBox(width: 8),
                                Text('pro_feature_templates'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('later_btn'.tr(),
                                style: TextStyle(color: Colors.white70)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => VipScreen()));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium,
                                    color: Colors.black),
                                SizedBox(width: 8),
                                Text('buy_pro_btn'.tr()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdsController().isSubscribed
                        ? Color(0xFFFFD700)
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AdsController().isSubscribed ? 'PRO' : 'Lite',
                    style: TextStyle(
                      color: AdsController().isSubscribed
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        drawer: MainDrawer(
          currentScreen: 'menu_settings',
          initialSpeciesList: const [],
          initialSpeciesDensity: const {},
          initialLengthUnit: '',
          initialDiameterUnit: '',
          initialWeightUnit: '',
          initialSpeciesListBf: [],
          initialSpeciesDensityBf: {},
          initialLengthUnitBf: '',
          initialDiameterUnitBf: '',
          initialWeightUnitBf: '',
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 420,
                  minHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (Theme.of(context).brightness != Brightness.dark)
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Верхняя часть: настройки и кнопки
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<int>(
                          tooltip: 'Выбрать тему',
                          icon: Icon(Icons.color_lens,
                              color: Theme.of(context).colorScheme.primary),
                          initialValue: themeIndex,
                          onSelected: (index) async {
                            final isPro = AdsController().isSubscribed;
                            // Forest (индекс 11) и Classic Dark (индекс 12) всегда доступны
                            if (index == 11 || index == 12 || isPro) {
                              await _saveThemeIndex(index);
                            } else {
                              // Показываем стандартный PRO-призыв
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                  title: Row(
                                    children: [
                                      Icon(Icons.workspace_premium,
                                          color: Color(0xFFFFD700), size: 28),
                                      SizedBox(width: 10),
                                      Text(
                                        'pro_offer_title'.tr(),
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'pro_offer_desc'.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Color(0xFFFFD700)),
                                          SizedBox(width: 8),
                                          Text('pro_feature_export'.tr(),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Color(0xFFFFD700)),
                                          SizedBox(width: 8),
                                          Text('pro_feature_no_ads'.tr(),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Color(0xFFFFD700)),
                                          SizedBox(width: 8),
                                          Text('pro_feature_templates'.tr(),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('later_btn'.tr(),
                                          style:
                                              TextStyle(color: Colors.white70)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFFD700),
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => VipScreen()));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.workspace_premium,
                                              color: Colors.black),
                                          SizedBox(width: 8),
                                          Text('buy_pro_btn'.tr()),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) {
                            final isPro = AdsController().isSubscribed;
                            return [
                              // 0 - Green White (greenTheme)
                              PopupMenuItem(
                                value: 0,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF388E3C)),
                                    SizedBox(width: 8),
                                    Text('Green White'),
                                    if (themeIndex == 0) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check, color: Colors.green),
                                    ]
                                  ],
                                ),
                              ),
                              // 1 - Golden (goldBlackTheme)
                              PopupMenuItem(
                                value: 1,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFFFFD700)),
                                    SizedBox(width: 8),
                                    Text('Golden'),
                                    if (themeIndex == 1) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFFFFD700)),
                                    ]
                                  ],
                                ),
                              ),
                              // 2 - Neon Night (premiumTheme)
                              PopupMenuItem(
                                value: 2,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF8A2BE2)),
                                    SizedBox(width: 8),
                                    Text('Neon Night'),
                                    if (themeIndex == 2) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF8A2BE2)),
                                    ]
                                  ],
                                ),
                              ),
                              // 3 - Classic Green (classicGreenTheme)
                              PopupMenuItem(
                                value: 3,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF388E3C)
                                              .withOpacity(0.7)),
                                    SizedBox(width: 8),
                                    Text('Classic Green'),
                                    if (themeIndex == 3) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF388E3C)
                                              .withOpacity(0.7)),
                                    ]
                                  ],
                                ),
                              ),
                              // 4 - Earth & Sand (brownBeigeTheme)
                              PopupMenuItem(
                                value: 4,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF8B4513)),
                                    SizedBox(width: 8),
                                    Text('Earth & Sand'),
                                    if (themeIndex == 4) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF8B4513)),
                                    ]
                                  ],
                                ),
                              ),
                              // 5 - Auric Blue (blueGoldTheme)
                              PopupMenuItem(
                                value: 5,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF1565C0)),
                                    SizedBox(width: 8),
                                    Text('Auric Blue'),
                                    if (themeIndex == 5) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF1565C0)),
                                    ]
                                  ],
                                ),
                              ),
                              // 6 - Violet Void (purpleLavenderTheme)
                              PopupMenuItem(
                                value: 6,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF6A1B9A)),
                                    SizedBox(width: 8),
                                    Text('Violet Void'),
                                    if (themeIndex == 6) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF6A1B9A)),
                                    ]
                                  ],
                                ),
                              ),
                              // 7 - Copper Peach (copperPeachTheme)
                              PopupMenuItem(
                                value: 7,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFFB87333)),
                                    SizedBox(width: 8),
                                    Text('Copper Peach'),
                                    if (themeIndex == 7) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFFB87333)),
                                    ]
                                  ],
                                ),
                              ),
                              // 8 - Endless Sky (skyBlueTheme)
                              PopupMenuItem(
                                value: 8,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF0288D1)),
                                    SizedBox(width: 8),
                                    Text('Endless Sky'),
                                    if (themeIndex == 8) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF0288D1)),
                                    ]
                                  ],
                                ),
                              ),
                              // 9 - Neon Lime (neonLimeTheme)
                              PopupMenuItem(
                                value: 9,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF32CD32)),
                                    SizedBox(width: 8),
                                    Text('Neon Lime'),
                                    if (themeIndex == 9) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF32CD32)),
                                    ]
                                  ],
                                ),
                              ),
                              // 10 - Spring Grass (springGrassTheme)
                              PopupMenuItem(
                                value: 10,
                                enabled: true,
                                child: Row(
                                  children: [
                                    if (!isPro)
                                      Icon(Icons.lock, color: Color(0xFFFFD700))
                                    else
                                      Icon(Icons.circle,
                                          color: Color(0xFF4CAF50)),
                                    SizedBox(width: 8),
                                    Text('Spring Grass'),
                                    if (themeIndex == 10) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF4CAF50)),
                                    ]
                                  ],
                                ),
                              ),
                              // 11 - Forest (forestTheme) - ВСЕГДА ДОСТУПЕН
                              PopupMenuItem(
                                value: 11,
                                enabled: true,
                                child: Row(
                                  children: [
                                    Icon(Icons.circle,
                                        color: Color(0xFF1B5E20)),
                                    SizedBox(width: 8),
                                    Text('Forest'),
                                    if (themeIndex == 11) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF1B5E20)),
                                    ]
                                  ],
                                ),
                              ),
                              // 12 - Classic Dark (classicDarkTheme) - ВСЕГДА ДОСТУПЕН
                              PopupMenuItem(
                                value: 12,
                                enabled: true,
                                child: Row(
                                  children: [
                                    Icon(Icons.circle,
                                        color: Color(0xFF1565C0)),
                                    SizedBox(width: 8),
                                    Text('Classic Dark'),
                                    if (themeIndex == 12) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.check,
                                          color: Color(0xFF1565C0)),
                                    ]
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsButton(
                          icon: Icons.language,
                          label: 'select_language'.tr(),
                          onPressed: () async {
                            final locale = await showDialog<Locale>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor:
                                    Theme.of(context).dialogBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                title: Text('select_language'.tr()),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // Основные европейские языки
                                      ListTile(
                                        title: Text('English'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('en')),
                                      ),
                                      ListTile(
                                        title: Text('English (UK)'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('en-GB')),
                                      ),
                                      ListTile(
                                        title: Text('Russian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ru')),
                                      ),
                                      ListTile(
                                        title: Text('Ukrainian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('uk')),
                                      ),
                                      ListTile(
                                        title: Text('German'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('de')),
                                      ),
                                      ListTile(
                                        title: Text('French'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('fr')),
                                      ),
                                      ListTile(
                                        title: Text('French (Canada)'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('fr-CA')),
                                      ),
                                      ListTile(
                                        title: Text('Spanish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('es')),
                                      ),
                                      ListTile(
                                        title: Text('Spanish (Mexico)'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('es-MX')),
                                      ),
                                      ListTile(
                                        title: Text('Italian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('it')),
                                      ),
                                      ListTile(
                                        title: Text('Portuguese'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('pt')),
                                      ),
                                      ListTile(
                                        title: Text('Portuguese (Brazil)'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('pt-BR')),
                                      ),
                                      ListTile(
                                        title: Text('Dutch'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('nl')),
                                      ),

                                      // Северные европейские языки
                                      ListTile(
                                        title: Text('Norwegian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('no')),
                                      ),
                                      ListTile(
                                        title: Text('Swedish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('sv')),
                                      ),
                                      ListTile(
                                        title: Text('Finnish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('fi')),
                                      ),
                                      ListTile(
                                        title: Text('Danish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('da')),
                                      ),

                                      // Центральная и Восточная Европа
                                      ListTile(
                                        title: Text('Polish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('pl')),
                                      ),
                                      ListTile(
                                        title: Text('Czech'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('cs')),
                                      ),
                                      ListTile(
                                        title: Text('Slovak'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('sk')),
                                      ),
                                      ListTile(
                                        title: Text('Hungarian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('hu')),
                                      ),
                                      ListTile(
                                        title: Text('Romanian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ro')),
                                      ),
                                      ListTile(
                                        title: Text('Bulgarian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('bg')),
                                      ),
                                      ListTile(
                                        title: Text('Croatian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('hr')),
                                      ),
                                      ListTile(
                                        title: Text('Serbian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('sr')),
                                      ),
                                      ListTile(
                                        title: Text('Bosnian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('bs')),
                                      ),
                                      ListTile(
                                        title: Text('Slovenian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('sl')),
                                      ),
                                      ListTile(
                                        title: Text('Macedonian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('mk')),
                                      ),
                                      ListTile(
                                        title: Text('Albanian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('sq')),
                                      ),
                                      ListTile(
                                        title: Text('Belarusian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('be')),
                                      ),
                                      ListTile(
                                        title: Text('Estonian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('et')),
                                      ),
                                      ListTile(
                                        title: Text('Latvian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('lv')),
                                      ),

                                      // Кельтские языки
                                      ListTile(
                                        title: Text('Irish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ga')),
                                      ),
                                      ListTile(
                                        title: Text('Welsh'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('cy')),
                                      ),
                                      ListTile(
                                        title: Text('Scottish Gaelic'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('gb')),
                                      ),

                                      // Другие европейские языки
                                      ListTile(
                                        title: Text('Greek'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('gr')),
                                      ),
                                      ListTile(
                                        title: Text('Turkish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('tr')),
                                      ),
                                      ListTile(
                                        title: Text('Maltese'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('mt')),
                                      ),
                                      ListTile(
                                        title: Text('Luxembourgish'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('lb')),
                                      ),

                                      // Азиатские языки
                                      ListTile(
                                        title: Text('Chinese (Simplified)'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('zh-CN')),
                                      ),
                                      ListTile(
                                        title: Text('Chinese (Traditional)'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('zh-TW')),
                                      ),
                                      ListTile(
                                        title: Text('Chinese (Hong Kong)'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('zh-HK')),
                                      ),
                                      ListTile(
                                        title: Text('Japanese'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('jp')),
                                      ),
                                      ListTile(
                                        title: Text('Korean'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ko')),
                                      ),
                                      ListTile(
                                        title: Text('Thai'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('th')),
                                      ),
                                      ListTile(
                                        title: Text('Vietnamese'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('vi')),
                                      ),
                                      ListTile(
                                        title: Text('Indonesian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('id')),
                                      ),
                                      ListTile(
                                        title: Text('Malay'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ms')),
                                      ),
                                      ListTile(
                                        title: Text('Filipino'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('fil')),
                                      ),

                                      // Индийский субконтинент
                                      ListTile(
                                        title: Text('Hindi'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('hi')),
                                      ),
                                      ListTile(
                                        title: Text('Bengali'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('bn')),
                                      ),
                                      ListTile(
                                        title: Text('Tamil'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ta')),
                                      ),
                                      ListTile(
                                        title: Text('Telugu'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('te')),
                                      ),
                                      ListTile(
                                        title: Text('Kannada'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('kn')),
                                      ),
                                      ListTile(
                                        title: Text('Malayalam'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ml')),
                                      ),
                                      ListTile(
                                        title: Text('Gujarati'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('gu')),
                                      ),
                                      ListTile(
                                        title: Text('Punjabi'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('pa')),
                                      ),
                                      ListTile(
                                        title: Text('Sinhala'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('si')),
                                      ),
                                      ListTile(
                                        title: Text('Nepali'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ne')),
                                      ),
                                      ListTile(
                                        title: Text('Urdu'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ur')),
                                      ),

                                      // Средний Восток и Кавказ
                                      ListTile(
                                        title: Text('Arabic'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ar')),
                                      ),
                                      ListTile(
                                        title: Text('Hebrew'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('he')),
                                      ),
                                      ListTile(
                                        title: Text('Persian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('fa')),
                                      ),
                                      ListTile(
                                        title: Text('Armenian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('hy')),
                                      ),
                                      ListTile(
                                        title: Text('Georgian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ka')),
                                      ),
                                      ListTile(
                                        title: Text('Azerbaijani'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('az')),
                                      ),

                                      // Центральная Азия
                                      ListTile(
                                        title: Text('Uzbek'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('uz')),
                                      ),
                                      ListTile(
                                        title: Text('Tajik'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('tg')),
                                      ),
                                      ListTile(
                                        title: Text('Turkmen'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('tk')),
                                      ),
                                      ListTile(
                                        title: Text('Mongolian'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('mn')),
                                      ),

                                      // Африканские языки
                                      ListTile(
                                        title: Text('Afrikaans'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('af')),
                                      ),
                                      ListTile(
                                        title: Text('Swahili'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('sw')),
                                      ),
                                      ListTile(
                                        title: Text('Hausa'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ha')),
                                      ),
                                      ListTile(
                                        title: Text('Yoruba'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('yo')),
                                      ),
                                      ListTile(
                                        title: Text('Igbo'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('ig')),
                                      ),
                                      ListTile(
                                        title: Text('Zulu'),
                                        onTap: () => Navigator.pop(
                                            context, Locale('zu')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            if (locale != null) {
                              context.setLocale(locale);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsButton(
                          icon: Icons.privacy_tip,
                          label: 'ad_consent_settings'.tr(),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            bool? adConsent =
                                await MainScreen.showAdConsentDialog(context);
                            if (adConsent != null) {
                              await prefs.setBool('adConsent', adConsent);
                              await AdsController()
                                  .init(personalized: adConsent);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    adConsent
                                        ? 'ad_personalized_enabled'.tr()
                                        : 'ad_personalized_disabled'.tr(),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsButton(
                          icon: Icons.description,
                          label: 'Настроить шаблон документа'.tr(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DocumentTemplateScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsButton(
                          icon: Icons.privacy_tip,
                          label: 'privacy_policy'.tr(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      LicenseScreen(readOnly: true)),
                            );
                          },
                        ),
                      ],
                    ),
                    // Нижняя часть: лого и подписи
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        children: [
                          Image.asset(
                            Theme.of(context).brightness == Brightness.dark
                                ? 'assets/icons/logo_dark.png'
                                : 'assets/icons/logo_light.png',
                            height: 64,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'F.C. by DR.IT Studio LLC',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DR.IT Studio LLC',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'support@dr-it.studio',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'copyright_notice'.tr(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: textColor),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(
            color: buttonColor,
            width: 2,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
