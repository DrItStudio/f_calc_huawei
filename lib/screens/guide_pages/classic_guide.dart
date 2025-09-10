import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'bf_manual_guide.dart';
import '../main_screen.dart';

class ClassicGuideScreen extends StatelessWidget {
  const ClassicGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('m3_ai_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('m3_ai_title_m3'.tr(),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Image.asset('assets/images/manualm31.jpg'),
            const SizedBox(height: 12),
            Text('m3_main_elements'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...[
              'm3_el_burger',
              'm3_el_pro',
              'm3_el_method',
              'm3_el_species',
              'm3_el_grade',
              'm3_el_cost',
              'm3_el_length',
              'm3_el_diameter',
              'm3_el_units',
              'm3_el_qty',
              'm3_el_vol_out',
              'm3_el_add',
              'm3_el_price_out',
              'm3_el_table',
              'm3_el_total_logs',
              'm3_el_total_vol',
              'm3_el_total_cost',
              'm3_el_export',
              'm3_el_clear',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 24),
            Text('m3_df_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('m3_method_btn'.tr()),
            const SizedBox(height: 8),
            Image.asset('assets/images/man_m3_method.jpg'),
            const SizedBox(height: 8),
            Text('1. ${'m3_method1'.tr()}'),
            Text('2. ${'m3_method2'.tr()}'),
            const SizedBox(height: 12),
            Text('m3_weight_settings'.tr(),
                style: Theme.of(context).textTheme.titleSmall),
            Image.asset('assets/images/man_m3_method2.jpg'),
            ...[
              'm3_ws_moisture',
              'm3_ws_pack',
              'm3_ws_total_bark',
              'm3_ws_total_no_bark',
              'm3_ws_vol_bark',
              'm3_ws_ok',
            ]
                .asMap()
                .entries
                .map((e) => Text('${e.key + 1}. ${e.value.tr()}'))
                .toList(),
            const SizedBox(height: 12),
            Text('m3_weight_output'.tr(),
                style: Theme.of(context).textTheme.titleSmall),
            Image.asset('assets/images/weight_show.jpg'),
            ...[
              'm3_wo_vol_bark',
              'm3_wo_vol_net',
              'm3_wo_vol_bark2',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_species_sel'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Image.asset('assets/images/man_m3_species.jpg'),
            ...[
              'm3_species1',
              'm3_species2',
              'm3_species3',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_species_add'.tr(),
                style: Theme.of(context).textTheme.titleSmall),
            Image.asset('assets/images/man_m3_species_castom.jpg'),
            ...[
              'm3_sa_name',
              'm3_sa_density',
              'm3_sa_bark',
              'm3_sa_ok',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_species_filter'.tr(),
                style: Theme.of(context).textTheme.titleSmall),
            Image.asset('assets/images/man_m3_species_filter.jpg'),
            ...[
              'm3_sf_search',
              'm3_sf_type',
              'm3_sf_region',
              'm3_sf_density',
              'm3_sf_show_density',
              'm3_sf_show_bark',
              'm3_sf_checkboxes',
              'm3_sf_ok',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_grade_sel'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Image.asset('assets/images/man_grade.jpg'),
            ...[
              'm3_grade1',
              'm3_grade2',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_grade_add'.tr(),
                style: Theme.of(context).textTheme.titleSmall),
            Image.asset('assets/images/man_grade_castom.jpg'),
            ...[
              'm3_ga_name',
              'm3_ga_ok',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_cost_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Image.asset('assets/images/man_price.jpg'),
            ...[
              'm3_cost1',
              'm3_cost2',
              'm3_cost3',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_units_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Image.asset('assets/images/man_m3_settings.jpg'),
            ...[
              'm3_units1',
              'm3_units2',
              'm3_units3',
              'm3_units4',
              'm3_units5',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_table_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Image.asset('assets/images/man_table.jpg'),
            ...[
              'm3_table1',
              'm3_table2',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_save_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Image.asset('assets/images/man_save.jpg'),
            ...[
              'm3_save1',
              'm3_save2',
              'm3_save3',
              'm3_save4',
            ].asMap().entries.map((e) => Text('${e.key + 1}. ${e.value.tr()}')),
            const SizedBox(height: 12),
            Text('m3_autosave_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            Text('m3_autosave_text'.tr()),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Можно добавить кнопку "Назад" слева, если нужно
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BfManualGuideScreen()),
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
