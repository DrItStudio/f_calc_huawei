import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Удалено: import 'package:huawei_iap/huawei_iap.dart';
import 'screens/splash_screen.dart';
import 'themes/green_theme.dart';
import 'themes/gold_black_theme.dart';
import 'themes/premium_theme.dart';
import 'themes/classic_green_theme.dart';
import 'themes/brown_beige_theme.dart';
import 'themes/blue_gold_theme.dart';
import 'themes/purple_lavender_theme.dart';
import 'themes/copper_peach_theme.dart';
import 'themes/sky_blue_theme.dart';
import 'themes/neon_lime_theme.dart';
import 'themes/spring_grass_theme.dart';
import 'themes/forest_theme.dart';
import 'themes/classic_dark_theme.dart';

// --- Импорт контроллера рекламы ---
import 'ads_controller.dart';

// --- Импорт классов для работы с покупками и подписками ---
import 'huawei_iap.dart';
import 'billing_manager.dart';

// --- Импорт класса для проверки обновлений из AppGallery ---
import 'huawei_update.dart';

// Все темы (PRO и стандартные)
final themeList = [
  greenTheme,
  goldBlackTheme,
  premiumTheme,
  classicGreenTheme,
  brownBeigeTheme,
  blueGoldTheme,
  purpleLavenderTheme,
  copperPeachTheme,
  skyBlueTheme,
  neonLimeTheme,
  springGrassTheme,
  forestTheme,
  classicDarkTheme
];

final themeNames = [
  'green',
  'gold_black',
  'premium',
  'classic_green',
  'brown_beige',
  'blue_gold',
  'purple_lavender',
  'copper_peach',
  'sky_blue',
  'neon_lime',
  'spring_grass',
  'forest',
  'classic_dark'
];

// По умолчанию — forestTheme
final themeNotifier = ValueNotifier<int>(themeList.indexOf(forestTheme));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // --- Инициализация подписки через BillingManager ---
  try {
    // Инициализация менеджера подписок для Huawei
    await BillingManager.initialize();
    print('BillingManager initialized successfully');
  } catch (e) {
    print('BillingManager initialization error: $e');
  }

  // --- Инициализация рекламы ---
  try {
    await AdsController().init();
    print('AdsController initialized successfully');
  } catch (e) {
    print('AdsController initialization error: $e');
  }

  // --- Проверка обновлений из AppGallery (Требуется для публикации в Huawei AppGallery) ---
  try {
    print('🚀 INITIALIZING HUAWEI APPGALLERY UPDATE API');

    // Вызов метода проверки обновлений - это основное требование модерации AppGallery
    final updateResult = await HuaweiUpdate.checkForUpdates();
    print('📱 AppGallery Update API result: $updateResult');

    if (updateResult == 'UPDATE_API_AVAILABLE') {
      print('✅ AppGallery Update API is ready and functional');
    } else {
      print('⚠️ AppGallery Update API status: $updateResult');
    }

    print('🔄 AppGallery checkUpdate API integration complete');
    await HuaweiUpdate.checkForUpdates();
    print('Update check initiated');
  } catch (e) {
    print('Error checking for updates: $e');
  }

  // --- Загрузка сохранённой темы до запуска приложения ---
  final prefs = await SharedPreferences.getInstance();
  final savedThemeIndex = prefs.getInt('selected_theme_index');
  final defaultThemeIndex = themeList.indexOf(forestTheme);
  final safeThemeIndex = (savedThemeIndex != null &&
          savedThemeIndex >= 0 &&
          savedThemeIndex < themeList.length)
      ? savedThemeIndex
      : defaultThemeIndex;
  themeNotifier.value = safeThemeIndex;

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('en-GB'),
        Locale('ru'),
        Locale('uk'),
        Locale('de'),
        Locale('fr'),
        Locale('fr-CA'),
        Locale('es'),
        Locale('es-MX'),
        Locale('it'),
        Locale('pt'),
        Locale('pt-BR'),
        Locale('nl'),
        Locale('no'),
        Locale('sv'),
        Locale('fi'),
        Locale('da'),
        Locale('pl'),
        Locale('cs'),
        Locale('sk'),
        Locale('hu'),
        Locale('ro'),
        Locale('bg'),
        Locale('hr'),
        Locale('sr'),
        Locale('bs'),
        Locale('sl'),
        Locale('mk'),
        Locale('sq'),
        Locale('be'),
        Locale('et'),
        Locale('lv'),
        Locale('ga'),
        Locale('cy'),
        Locale('gb'),
        Locale('tr'),
        Locale('mt'),
        Locale('lb'),
        Locale('zh-CN'),
        Locale('zh-TW'),
        Locale('zh-HK'),
        Locale('jp'),
        Locale('ko'),
        Locale('th'),
        Locale('vi'),
        Locale('id'),
        Locale('ms'),
        Locale('fil'),
        Locale('hi'),
        Locale('bn'),
        Locale('ta'),
        Locale('te'),
        Locale('kn'),
        Locale('ml'),
        Locale('gu'),
        Locale('pa'),
        Locale('si'),
        Locale('ne'),
        Locale('ur'),
        Locale('ar'),
        Locale('he'),
        Locale('fa'),
        Locale('hy'),
        Locale('ka'),
        Locale('az'),
        Locale('uz'),
        Locale('tg'),
        Locale('tk'),
        Locale('mn'),
        Locale('af'),
        Locale('sw'),
        Locale('ha'),
        Locale('yo'),
        Locale('ig'),
        Locale('zu'),
      ],
      path: 'assets',
      fallbackLocale: Locale('ru'),
      saveLocale: true,
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    try {
      // Освобождаем ресурсы
      AdsController().dispose();
      BillingManager.dispose();
      print('Resources disposed successfully');
    } catch (e) {
      print('Error disposing resources: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: themeNotifier,
      builder: (context, themeIndex, _) => MaterialApp(
        key: ValueKey(context.locale.languageCode),
        title: 'Wood Volume Calculator',
        theme: themeList[themeIndex],
        darkTheme: classicDarkTheme,
        themeMode: ThemeMode.system,
        home: SplashScreenWrapper(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
