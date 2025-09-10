import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// Импортируем все экраны-подсказки
import 'guide_pages/classic_guide.dart';
import 'guide_pages/bf_manual_guide.dart';
import 'guide_pages/fast_guide.dart';
import 'guide_pages/bf_calc_guide.dart';
import 'guide_pages/history_guide.dart';
import 'guide_pages/tables_guide.dart';
import 'guide_pages/settings_guide.dart';

class GuideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget customNavButton({
      required IconData icon,
      required String label,
      VoidCallback? onTap,
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

    return Scaffold(
      appBar: AppBar(
        title: Text('guide_title'.tr()),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 18),
              Text(
                'guide_hint'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              // --- Classic calculator подпись ---
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 4),
                child: Text(
                  'classic_calculator_label'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        customNavButton(
                          icon: Icons.calculate,
                          label: 'menu_classic',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ClassicGuideScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'classic_calculator_desc'.tr(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        customNavButton(
                          icon: Icons.calculate,
                          label: 'menu_bf_manual',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BfManualGuideScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'bf_manual_calculator_desc'.tr(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // --- Fast calculator подпись ---
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 4),
                child: Text(
                  'fast_calculator_label'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        customNavButton(
                          icon: Icons.touch_app,
                          label: 'menu_fast',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => FastGuideScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'fast_calculator_desc'.tr(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        customNavButton(
                          icon: Icons.touch_app,
                          label: 'menu_bf_calc',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BfCalcGuideScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'bf_calc_calculator_desc'.tr(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // История с подписью
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        customNavButton(
                          icon: Icons.history,
                          label: 'menu_history',
                          centerText: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HistoryGuideScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'history_desc'.tr(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Таблицы с подписью
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        customNavButton(
                          icon: Icons.table_chart,
                          label: 'menu_tables',
                          centerText: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TablesGuideScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'tables_desc'.tr(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Настройки с подписью
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        customNavButton(
                          icon: Icons.settings,
                          label: 'menu_settings',
                          centerText: true,
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SettingsGuideScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'settings_desc'.tr(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
