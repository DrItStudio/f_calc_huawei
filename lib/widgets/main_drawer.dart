import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screens/calculator_manual_screen.dart';
import '../screens/calculator_bf_manual_screen.dart';
import '../screens/calculator_buttons_screen.dart';
import '../screens/calculator_bf_buttons_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/license_screen.dart';
import '../screens/table_manager_screen.dart';
import '../screens/WeightResultScreen.dart';
import '../screens/guide_screen.dart';
import '../screens/main_screen.dart';
import '../ads_controller.dart';
import '../screens/vip.dart';

class MainDrawer extends StatelessWidget {
  final List<String> initialSpeciesList;
  final Map<String, double> initialSpeciesDensity;
  final String initialLengthUnit;
  final String initialDiameterUnit;
  final String initialWeightUnit;
  final List<String> initialSpeciesListBf;
  final Map<String, double> initialSpeciesDensityBf;
  final String initialLengthUnitBf;
  final String initialDiameterUnitBf;
  final String initialWeightUnitBf;
  final String currentScreen;

  const MainDrawer({
    super.key,
    required this.initialSpeciesList,
    required this.initialSpeciesDensity,
    required this.initialLengthUnit,
    required this.initialDiameterUnit,
    required this.initialWeightUnit,
    required this.initialSpeciesListBf,
    required this.initialSpeciesDensityBf,
    required this.initialLengthUnitBf,
    required this.initialDiameterUnitBf,
    required this.initialWeightUnitBf,
    required this.currentScreen,
  });

  Widget _bottomInfoBlock(BuildContext context) {
    return Column(
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
  }

  Widget _drawerButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final textStyle = theme.listTileTheme.textColor != null
        ? TextStyle(color: theme.listTileTheme.textColor)
        : theme.textTheme.bodyLarge;

    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: isActive
            ? textStyle?.copyWith(
                decoration: TextDecoration.underline,
                decorationThickness: 2,
                decorationColor: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              )
            : textStyle,
      ),
      selected: isActive,
      onTap: onTap,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MainScreen()),
                (route) => false,
              );
            },
            child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
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
                              color: Colors.white,
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
                              color: Colors.white,
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
                                  const SizedBox(width: 10),
                                  Text(
                                    'pro_offer_title'.tr(),
                                    style: const TextStyle(
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFFFFD700)),
                                      const SizedBox(width: 8),
                                      Text('pro_feature_export'.tr(),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFFFFD700)),
                                      const SizedBox(width: 8),
                                      Text('pro_feature_no_ads'.tr(),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFFFFD700)),
                                      const SizedBox(width: 8),
                                      Text('pro_feature_templates'.tr(),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('later_btn'.tr(),
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD700),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    textStyle: const TextStyle(
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
                                      const Icon(Icons.workspace_premium,
                                          color: Colors.black),
                                      const SizedBox(width: 8),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdsController().isSubscribed
                              ? const Color(0xFFFFD700)
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
          ),
          _drawerButton(
            context,
            icon: Icons.calculate,
            label: 'drawer_menu_classic'.tr(),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CalculatorManualScreen())),
            isActive: currentScreen == 'manual_calculator',
          ),
          _drawerButton(
            context,
            icon: Icons.calculate,
            label: 'drawer_menu_bf_manual'.tr(),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CalculatorBfManualScreen())),
            isActive: currentScreen == 'manual_calculator_bf',
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
            isActive: currentScreen == 'quick_calc',
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
            isActive: currentScreen == 'quick_calc_bf',
          ),
          _drawerButton(
            context,
            icon: Icons.history,
            label: 'drawer_menu_history'.tr(),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => HistoryScreen())),
            isActive: currentScreen == 'file_history',
          ),
          _drawerButton(
            context,
            icon: Icons.table_chart,
            label: 'drawer_menu_tables'.tr(),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => TableManagerScreen())),
            isActive: currentScreen == 'table_editor',
          ),
          _drawerButton(
            context,
            icon: Icons.settings,
            label: 'drawer_menu_settings'.tr(),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsScreen())),
            isActive: currentScreen == 'menu_settings',
          ),
          _drawerButton(
            context,
            icon: Icons.help,
            label: 'drawer_menu_guide'.tr(),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => GuideScreen())),
            isActive: currentScreen == 'guide',
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
          _bottomInfoBlock(context),
        ],
      ),
    );
  }
}
