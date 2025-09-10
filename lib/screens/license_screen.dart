import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseScreen extends StatefulWidget {
  final bool readOnly;
  const LicenseScreen({this.readOnly = false, Key? key}) : super(key: key);

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  String? policyText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    final lang = context.locale.languageCode;
    String assetPath = 'assets/policy/privacy_policy_en.txt';
    if (lang == 'ru') assetPath = 'assets/policy/privacy_policy_ru.txt';
    if (lang == 'uk') assetPath = 'assets/policy/privacy_policy_uk.txt';
    if (lang == 'fr') assetPath = 'assets/policy/privacy_policy_fr.txt';
    if (lang == 'it') assetPath = 'assets/policy/privacy_policy_it.txt';
    if (lang == 'de') assetPath = 'assets/policy/privacy_policy_de.txt';
    if (lang == 'es') assetPath = 'assets/policy/privacy_policy_es.txt';
    if (lang == 'jp') assetPath = 'assets/policy/privacy_policy_jp.txt';
    if (lang == 'pl') assetPath = 'assets/policy/privacy_policy_pl.txt';
    if (lang == 'zh-CN') assetPath = 'assets/policy/privacy_policy_zh-CN.txt';
    if (lang == 'zh-TW') assetPath = 'assets/policy/privacy_policy_zh-TW.txt';
    if (lang == 'ar') assetPath = 'assets/policy/privacy_policy_ar.txt';
    if (lang == 'tr') assetPath = 'assets/policy/privacy_policy_tr.txt';
    if (lang == 'pt') assetPath = 'assets/policy/privacy_policy_pt.txt';
    if (lang == 'ko') assetPath = 'assets/policy/privacy_policy_ko.txt';
    if (lang == 'id') assetPath = 'assets/policy/privacy_policy_id.txt';
    if (lang == 'af') assetPath = 'assets/policy/privacy_policy_af.txt';
    if (lang == 'th') assetPath = 'assets/policy/privacy_policy_th.txt';
    if (lang == 'vi') assetPath = 'assets/policy/privacy_policy_vi.txt';
    if (lang == 'hu') assetPath = 'assets/policy/privacy_policy_hu.txt';
    if (lang == 'fa') assetPath = 'assets/policy/privacy_policy_fa.txt';
    if (lang == 'az') assetPath = 'assets/policy/privacy_policy_az.txt';
    if (lang == 'bg') assetPath = 'assets/policy/privacy_policy_bg.txt';
    if (lang == 'be') assetPath = 'assets/policy/privacy_policy_be.txt';
    if (lang == 'cs') assetPath = 'assets/policy/privacy_policy_cs.txt';
    if (lang == 'da') assetPath = 'assets/policy/privacy_policy_da.txt';
    if (lang == 'et') assetPath = 'assets/policy/privacy_policy_et.txt';
    if (lang == 'fil') assetPath = 'assets/policy/privacy_policy_fil.txt';
    if (lang == 'gb') assetPath = 'assets/policy/privacy_policy_gb.txt';
    if (lang == 'he') assetPath = 'assets/policy/privacy_policy_he.txt';
    if (lang == 'hr') assetPath = 'assets/policy/privacy_policy_hr.txt';
    if (lang == 'hy') assetPath = 'assets/policy/privacy_policy_hy.txt';
    if (lang == 'ka') assetPath = 'assets/policy/privacy_policy_ka.txt';
    if (lang == 'kn') assetPath = 'assets/policy/privacy_policy_kn.txt';
    if (lang == 'lb') assetPath = 'assets/policy/privacy_policy_lb.txt';
    if (lang == 'bn') assetPath = 'assets/policy/privacy_policy_bn.txt';
    if (lang == 'lv') assetPath = 'assets/policy/privacy_policy_lv.txt';
    if (lang == 'mk') assetPath = 'assets/policy/privacy_policy_mk.txt';
    if (lang == 'ml') assetPath = 'assets/policy/privacy_policy_ml.txt';
    if (lang == 'bs') assetPath = 'assets/policy/privacy_policy_bs.txt';
    if (lang == 'nl') assetPath = 'assets/policy/privacy_policy_nl.txt';
    if (lang == 'cy') assetPath = 'assets/policy/privacy_policy_cy.txt';
    if (lang == 'ga') assetPath = 'assets/policy/privacy_policy_ga.txt';
    if (lang == 'gu') assetPath = 'assets/policy/privacy_policy_gu.txt';
    if (lang == 'ha') assetPath = 'assets/policy/privacy_policy_ha.txt';
    if (lang == 'ig') assetPath = 'assets/policy/privacy_policy_ig.txt';
    if (lang == 'ne') assetPath = 'assets/policy/privacy_policy_ne.txt';
    if (lang == 'mn') assetPath = 'assets/policy/privacy_policy_mn.txt';
    if (lang == 'mt') assetPath = 'assets/policy/privacy_policy_mt.txt';
    if (lang == 'pa') assetPath = 'assets/policy/privacy_policy_pa.txt';
    if (lang == 'sk') assetPath = 'assets/policy/privacy_policy_sk.txt';
    if (lang == 'ro') assetPath = 'assets/policy/privacy_policy_ro.txt';
    if (lang == 'si') assetPath = 'assets/policy/privacy_policy_si.txt';
    if (lang == 'sl') assetPath = 'assets/policy/privacy_policy_sl.txt';
    if (lang == 'sr') assetPath = 'assets/policy/privacy_policy_sr.txt';
    if (lang == 'sv') assetPath = 'assets/policy/privacy_policy_sv.txt';
    if (lang == 'ta') assetPath = 'assets/policy/privacy_policy_ta.txt';
    if (lang == 'te') assetPath = 'assets/policy/privacy_policy_te.txt';
    if (lang == 'tg') assetPath = 'assets/policy/privacy_policy_tg.txt';
    if (lang == 'uz') assetPath = 'assets/policy/privacy_policy_uz.txt';
    if (lang == 'yo') assetPath = 'assets/policy/privacy_policy_yo.txt';
    if (lang == 'zu') assetPath = 'assets/policy/privacy_policy_zu.txt';
    if (lang == 'sq') assetPath = 'assets/policy/privacy_policy_sq.txt';
    if (lang == 'sw') assetPath = 'assets/policy/privacy_policy_sw.txt';
    if (lang == 'tk') assetPath = 'assets/policy/privacy_policy_tk.txt';
    if (lang == 'ur') assetPath = 'assets/policy/privacy_policy_ur.txt';
    if (lang == 'no') assetPath = 'assets/policy/privacy_policy_no.txt';
    if (lang == 'ms') assetPath = 'assets/policy/privacy_policy_ms.txt';
    if (lang == 'hi') assetPath = 'assets/policy/privacy_policy_hi.txt';
    if (lang == 'fi') assetPath = 'assets/policy/privacy_policy_fi.txt';
    if (lang == 'en-GB') assetPath = 'assets/policy/privacy_policy_en-GB.txt';
    if (lang == 'pt-BR') assetPath = 'assets/policy/privacy_policy_pt-BR.txt';
    if (lang == 'fr-CA') assetPath = 'assets/policy/privacy_policy_fr-CA.txt';
    if (lang == 'es-MX') assetPath = 'assets/policy/privacy_policy_es-MX.txt';
    if (lang == 'zh-HK') assetPath = 'assets/policy/privacy_policy_zh-HK.txt';
    final text = await DefaultAssetBundle.of(context).loadString(assetPath);
    setState(() {
      policyText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('privacy_policy'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: policyText == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Text(
                            policyText!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, height: 1.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.readOnly) ...[
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('privacyAccepted', true);
                              Navigator.of(context).pop(true);
                            },
                            child: Text('accept'.tr(),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('decline'.tr(),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('close'.tr()),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
