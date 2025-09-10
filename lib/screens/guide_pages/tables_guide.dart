import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wood_volume_calculator/screens/guide_pages/history_guide.dart';
import 'package:wood_volume_calculator/screens/guide_pages/settings_guide.dart';
import '../main_screen.dart';

class TablesGuideScreen extends StatelessWidget {
  const TablesGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('t1_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              't1_hint'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Image.asset('assets/images/table_editot.jpg'),
            const SizedBox(height: 12),
            Text('t1_elements'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...[
              'm3_el_burger',
              't1',
              't2',
              't3',
              't4',
              't5',
              't6',
              "t7",
              't8',
            ]
                .asMap()
                .entries
                .map((e) => Text('${e.key + 1}. ${e.value.tr()}'))
                .toList(),
            const SizedBox(height: 12),
            Text('tb_title'.tr(),
                style: Theme.of(context).textTheme.titleSmall),
            Image.asset('assets/images/table_editor1.jpg'),
            ...[
              'tb1',
              'tb2',
              'tb3',
              'tb4',
              'tb5',
            ]
                .asMap()
                .entries
                .map((e) => Text('${e.key + 1}. ${e.value.tr()}'))
                .toList(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HistoryGuideScreen()),
                    );
                  },
                  child: Text('back'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => MainScreen()),
                      (route) => false,
                    );
                  },
                  child: Text('main_screen'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsGuideScreen()),
                    );
                  },
                  child: Text('m3_next'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
