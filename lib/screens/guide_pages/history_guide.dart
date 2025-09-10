import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wood_volume_calculator/screens/guide_pages/bf_calc_guide.dart';
import 'package:wood_volume_calculator/screens/guide_pages/tables_guide.dart';
import '../main_screen.dart';

class HistoryGuideScreen extends StatelessWidget {
  const HistoryGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('history_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'history_hint'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Image.asset('assets/images/history.jpg'),
            const SizedBox(height: 12),
            Text('history_elements'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...[
              'm3_el_burger',
              'h1',
              'h2',
              'h3',
              'h4',
              'h5',
              'h6',
              "h7",
            ]
                .asMap()
                .entries
                .map((e) => Text('${e.key + 1}. ${e.value.tr()}'))
                .toList(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => BfCalcGuideScreen()),
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
                      MaterialPageRoute(builder: (_) => TablesGuideScreen()),
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
