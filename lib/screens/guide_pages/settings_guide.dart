import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../main_screen.dart';
import 'tables_guide.dart';

class SettingsGuideScreen extends StatelessWidget {
  const SettingsGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('s1_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              's1_hint'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Image.asset('assets/images/settings.jpg'),
            const SizedBox(height: 12),
            Text('s1_elements'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...[
              'm3_el_burger',
              'm3_el_pro',
              's2',
              's3',
              's4',
              's5',
            ]
                .asMap()
                .entries
                .map((e) => Text('${e.key + 1}. ${e.value.tr()}'))
                .toList(),
            const SizedBox(height: 12),
            Text('st_title'.tr(),
                style: Theme.of(context).textTheme.titleSmall),
            Image.asset('assets/images/temp_new.jpg'),
            ...[
              'm3_el_pro',
              'st2',
              'st3',
              'st4',
              'st5',
              'st6',
              'st7',
              'st8',
              'st9',
              'st10',
              'st11',
            ]
                .asMap()
                .entries
                .map((e) => Text('${e.key + 1}. ${e.value.tr()}'))
                .toList(),
            const SizedBox(height: 12),
            Text('s2_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => TablesGuideScreen()),
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
                  child: Text('Finish'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
