import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'calculator_manual_screen.dart';
import 'calculator_buttons_screen.dart';
import 'calculator_bf_buttons_screen.dart';
import 'calculator_bf_manual_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'license_screen.dart';
import 'table_manager_screen.dart';
import 'guide_screen.dart';
import 'WeightResultScreen.dart';
import '../ads_controller.dart';
import '../screens/vip.dart';
import '../data/species_meta BF.dart' as meta_bf;
import 'package:shared_preferences/shared_preferences.dart';

class ConsentDialog extends StatelessWidget {
  const ConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ad_consent_title'.tr()),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ad_consent_text'.tr(),
            ),
            const SizedBox(height: 16),
            Text(
              'ad_consent_choice'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('no_btn'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('yes_btn'.tr()),
        ),
      ],
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();

  // Можно сделать этот метод static, чтобы вызывать из _MainScreenState
  static Future<bool?> showAdConsentDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ConsentDialog(),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      bool? adConsent = prefs.getBool('adConsent');
      if (adConsent == null) {
        adConsent = await MainScreen.showAdConsentDialog(context);
        await prefs.setBool('adConsent', adConsent ?? false);
      }
      await AdsController().init(personalized: adConsent ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- Дефолтные значения для передачи в калькуляторы ---
    final List<String> initialSpeciesList = ['oak', 'pine', 'birch'];
    final Map<String, double> initialSpeciesDensity = {
      'oak': 700,
      'pine': 500,
      'birch': 600
    };
    final String initialLengthUnit = 'м';
    final String initialDiameterUnit = 'см';
    final String initialWeightUnit = 'кг';

    final List<String> initialSpeciesListBf = meta_bf.speciesMeta.keys.toList();
    final Map<String, double> initialSpeciesDensityBf = {
      for (final entry in meta_bf.speciesMeta.entries)
        entry.key: entry.value.density ?? 50,
    };
    final String initialLengthUnitBf = 'ft';
    final String initialDiameterUnitBf = 'in';
    final String initialWeightUnitBf = 'lb';

// Drawer-кнопка
    Widget _drawerButton(
      BuildContext context, {
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.zero,
          child: InkWell(
            onTap: onTap,
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Container(
              height: 60,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(icon,
                      size: 32, color: Theme.of(context).iconTheme.color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

// Кнопка на главном экране
    Widget customNavButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? color,
      bool centerText = false,
    }) {
      final buttonColor = color ?? Theme.of(context).colorScheme.primary;
      final iconColor = Theme.of(context).iconTheme.color;
      final textColor = Theme.of(context).colorScheme.onPrimary;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: onTap,
            child: centerText
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 32, color: iconColor),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            label.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Icon(icon, size: 32, color: iconColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          label.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    Widget bottomInfoBlock = Column(
      children: [
        Image.asset(
          Theme.of(context).brightness == Brightness.dark
              ? 'assets/icons/logo_dark.png'
              : 'assets/icons/logo_light.png',
          height: 72,
        ),
        const SizedBox(height: 8),
        Text(
          'F.C. by DR.IT Studio LLC',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'DR.IT Studio LLC',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'support@dr-it.studio',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'copyright_notice'.tr(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'v1.0.0',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/appbar_icon.png',
              height: 36, // увеличено
              width: 36, // увеличено
            ),
            SizedBox(width: 12),
            Text(
              'Forest Calc',
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1.2,
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ) ??
                  TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Theme.of(context).colorScheme.primary,
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
            ),
            Spacer(),
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
                              MaterialPageRoute(builder: (_) => VipScreen()),
                            );
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
      drawer: Drawer(
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Theme.of(context)
                  .appBarTheme
                  .backgroundColor, // Цвет как у AppBar// Фиксированный чёрный фон
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                        child: Image.asset(
                          'assets/icons/appbar_icon.png',
                          height: 64,
                          width: 64,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'F.C.',
                            style: TextStyle(
                              color: Colors.white, // Белый текст на чёрном фоне
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Montserrat',
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by DR.IT Studio',
                            style: TextStyle(
                              color: Colors.white, // Белый текст на чёрном фоне
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
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
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Color(0xFFFFD700)),
                                      SizedBox(width: 8),
                                      Text('pro_feature_no_ads'.tr(),
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Color(0xFFFFD700)),
                                      SizedBox(width: 8),
                                      Text('pro_feature_templates'.tr(),
                                          style:
                                              TextStyle(color: Colors.white)),
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
                                          builder: (_) => VipScreen()),
                                    );
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                  ),
                ],
              ),
            ),
            _drawerButton(
              context,
              icon: Icons.calculate,
              label: 'drawer_menu_classic'.tr(),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalculatorManualScreen())),
            ),
            _drawerButton(
              context,
              icon: Icons.calculate,
              label: 'drawer_menu_bf_manual'.tr(),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalculatorBfManualScreen())),
            ),
            _drawerButton(
              context,
              icon: Icons.touch_app,
              label: 'drawer_menu_fast'.tr(),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalculatorButtonsScreen(
                      initialSpeciesList: initialSpeciesList,
                      initialSpeciesDensity: initialSpeciesDensity,
                      initialLengthUnit: initialLengthUnit,
                      initialDiameterUnit: initialDiameterUnit,
                      initialWeightUnit: initialWeightUnit,
                    ),
                  )),
            ),
            _drawerButton(
              context,
              icon: Icons.touch_app,
              label: 'drawer_menu_bf_calc'.tr(),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalculatorBfButtonsScreen(
                      initialSpeciesList: initialSpeciesListBf,
                      initialSpeciesDensity: initialSpeciesDensityBf,
                      initialLengthUnit: initialLengthUnitBf,
                      initialDiameterUnit: initialDiameterUnitBf,
                      initialWeightUnit: initialWeightUnitBf,
                    ),
                  )),
            ),
            _drawerButton(
              context,
              icon: Icons.history,
              label: 'drawer_menu_history'.tr(),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryScreen())),
            ),
            _drawerButton(
              context,
              icon: Icons.table_chart,
              label: 'drawer_menu_tables'.tr(),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TableManagerScreen())),
            ),
            _drawerButton(
              context,
              icon: Icons.settings,
              label: 'drawer_menu_settings'.tr(),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen())),
            ),
            _drawerButton(
              context,
              icon: Icons.info_outline,
              label: 'guide_title'.tr(),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GuideScreen())),
            ),
            _drawerButton(
              context,
              icon: Icons.privacy_tip,
              label: 'privacy_policy'.tr(),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LicenseScreen(readOnly: true))),
            ),
            const SizedBox(height: 12),
            bottomInfoBlock,
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Classic calculator подпись ---
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 4),
                child: Text(
                  'Classic calculator label'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'Montserrat', // Можно заменить на ваш красивый шрифт
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: customNavButton(
                      icon: Icons.calculate,
                      label: 'menu_classic',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CalculatorManualScreen()));
                      },
                    ),
                  ),
                  Expanded(
                    child: customNavButton(
                      icon: Icons.calculate,
                      label: 'menu_bf_manual',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CalculatorBfManualScreen()));
                      },
                    ),
                  ),
                ],
              ),
              // --- Fast calculator подпись ---
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 4),
                child: Text(
                  'Fast calculator label'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'Montserrat', // Можно заменить на ваш красивый шрифт
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: customNavButton(
                      icon: Icons.touch_app,
                      label: 'menu_fast',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalculatorButtonsScreen(
                                initialSpeciesList: initialSpeciesList,
                                initialSpeciesDensity: initialSpeciesDensity,
                                initialLengthUnit: initialLengthUnit,
                                initialDiameterUnit: initialDiameterUnit,
                                initialWeightUnit: initialWeightUnit,
                              ),
                            ));
                      },
                    ),
                  ),
                  Expanded(
                    child: customNavButton(
                      icon: Icons.touch_app,
                      label: 'menu_bf_calc',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalculatorBfButtonsScreen(
                                initialSpeciesList: initialSpeciesListBf,
                                initialSpeciesDensity: initialSpeciesDensityBf,
                                initialLengthUnit: initialLengthUnitBf,
                                initialDiameterUnit: initialDiameterUnitBf,
                                initialWeightUnit: initialWeightUnitBf,
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: customNavButton(
                      icon: Icons.history,
                      label: 'menu_history',
                      centerText: true, // центрируем
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryScreen()));
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: customNavButton(
                      icon: Icons.table_chart,
                      label: 'menu_tables',
                      centerText: true, // центрируем
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TableManagerScreen()));
                      },
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: customNavButton(
                      icon: Icons.settings,
                      label: 'menu_settings',
                      centerText: true,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsScreen()));
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: customNavButton(
                      icon: Icons.info_outline,
                      label:
                          'Инструкция', // или 'guide_title'.tr() если хотите перевод
                      centerText: true,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GuideScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              bottomInfoBlock,
            ],
          ),
        ),
      ),
    );
  }
}
