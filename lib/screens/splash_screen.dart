import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/locate.dart';
import '../data/species_density.dart';
import '../data/species_data.dart';
import '../data/species_meta.dart';
import 'license_screen.dart';
import 'main_screen.dart';
import '../data/species_meta BF.dart' as meta_bf;

final Set<String> allSpecies = {
  ...speciesDensity.keys,
  ...speciesData.keys,
  ...speciesMeta.keys,
  ...meta_bf.speciesMeta.keys,
};

String getDensityForSpecies(String species) {
  final value = speciesDensity[species];
  return value != null ? value.toStringAsFixed(0) : '-';
}

String getBarkCorrectionForSpecies(String species) {
  final value = speciesData[species];
  if (value != null) {
    final percent = (value * 100).round();
    return '+$percent%';
  }
  return '-';
}

List<String> getPrioritySpeciesByCountry(String countryCode) {
  // Найти название страны по коду
  final countryName = countries.firstWhere(
        (c) => c['code'] == countryCode,
        orElse: () => {'name': ''},
      )['name'] ??
      '';

  if (countryName.isEmpty) {
    return [];
  }

  final prioritySpecies = <String>[];

  // Ищем в обычном species_meta
  prioritySpecies.addAll(
    speciesMeta.entries
        .where((e) => e.value.countries.contains(countryName))
        .map((e) => e.key)
        .toList(),
  );

  // Ищем в species_meta BF - ЭТО БЫЛО ПРОПУЩЕНО!
  prioritySpecies.addAll(
    meta_bf.speciesMeta.entries
        .where((e) => e.value.countries.contains(countryName))
        .map((e) => e.key)
        .toList(),
  );

  // Убираем дубликаты и сортируем
  final uniqueSpecies = prioritySpecies.toSet().toList()..sort();

  // Для отладки - выводим что нашли
  print('Country: $countryName, Found species: ${uniqueSpecies.length}');
  print('Species: $uniqueSpecies');

  return uniqueSpecies;
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _startSequence();
    }
  }

  Future<void> _startSequence() async {
    await Future.delayed(Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();

    String systemLang = ui.window.locale.languageCode;
    String systemCountry = ui.window.locale.countryCode ?? 'RU';

    final langShort = {
      'ru': 'RU',
      'uk': 'UA',
      'en': 'EN',
      'fr': 'FR',
      'it': 'IT',
      'de': 'DE',
      'es': 'ES',
      'jp': 'JP',
      'pl': 'PL',
      'zh-CN': 'CN',
      'zh-TW': 'TW',
      'ar': 'AR',
      'tr': 'TR',
      'pt': 'PT',
      'ko': 'KO',
      'id': 'ID',
      'af': 'AF',
      'th': 'TH',
      'vi': 'VI',
      'hu': 'HU',
      'fa': 'FA',
      'az': 'AZ',
      'bg': 'BG',
      'be': 'BE',
      'cs': 'CS',
      'da': 'DA',
      'et': 'ET',
      'fil': 'FIL',
      'gb': 'GB',
      'he': 'HE',
      'hr': 'HR',
      'hy': 'HY',
      'ka': 'KA',
      'kn': 'KN',
      'lb': 'LB',
      'bn': 'BN',
      'lv': 'LV',
      'mk': 'MK',
      'ml': 'ML',
      'bs': 'BS',
      'nl': 'NL',
      'cy': 'CY',
      'ga': 'GA',
      'gu': 'GU',
      'ha': 'HA',
      'ig': 'IG',
      'ne': 'NE',
      'mn': 'MN',
      'mt': 'MT',
      'pa': 'PA',
      'sk': 'SK',
      'ro': 'RO',
      'si': 'SI',
      'sl': 'SL',
      'sr': 'SR',
      'sv': 'SV',
      'ta': 'TA',
      'te': 'TE',
      'tg': 'TG',
      'uz': 'UZ',
      'yo': 'YO',
      'zu': 'ZU',
      'sq': 'SQ',
      'sw': 'SW',
      'tk': 'TK',
      'ur': 'UR',
      'no': 'NO',
      'ms': 'MS', // Malay
      'hi': 'HI', // Hindi
      'fi': 'FI', // Finnish
      'en-GB': 'EN-GB', // English (UK)
      'pt-BR': 'PT-BR', // Portuguese (Brazil)
      'fr-CA': 'FR-CA', // French (Canada)
      'es-MX': 'ES-MX', // Spanish (Mexico)
      'zh-HK': 'ZH-HK', // Chinese (Hong Kong)
    };
    final langCountryMap = {
      'ru': 'RU',
      'uk': 'UA',
      'en': 'EN',
      'fr': 'FR',
      'it': 'IT',
      'de': 'DE',
      'es': 'ES',
      'jp': 'JP',
      'pl': 'PL',
      'zh-CN': 'CN',
      'zh-TW': 'TW',
      'ar': 'AR',
      'tr': 'TR',
      'pt': 'PT',
      'ko': 'KO',
      'id': 'ID',
      'af': 'AF',
      'th': 'TH',
      'vi': 'VI',
      'hu': 'HU',
      'fa': 'FA',
      'az': 'AZ',
      'bg': 'BG',
      'be': 'BE',
      'cs': 'CS',
      'da': 'DA',
      'et': 'ET',
      'fil': 'FIL',
      'gb': 'GB',
      'he': 'HE',
      'hr': 'HR',
      'hy': 'HY',
      'ka': 'KA',
      'kn': 'KN',
      'lb': 'LB',
      'bn': 'BN',
      'lv': 'LV',
      'mk': 'MK',
      'ml': 'ML',
      'bs': 'BS',
      'nl': 'NL',
      'cy': 'CY',
      'ga': 'GA',
      'gu': 'GU',
      'ha': 'HA',
      'ig': 'IG',
      'ne': 'NE',
      'mn': 'MN',
      'mt': 'MT',
      'pa': 'PA',
      'sk': 'SK',
      'ro': 'RO',
      'si': 'SI',
      'sl': 'SL',
      'sr': 'SR',
      'sv': 'SV',
      'ta': 'TA',
      'te': 'TE',
      'tg': 'TG',
      'uz': 'UZ',
      'yo': 'YO',
      'zu': 'ZU',
      'sq': 'SQ',
      'sw': 'SW',
      'tk': 'TK',
      'ur': 'UR',
      'no': 'NO',
      'ms': 'MY', // Malay
      'hi': 'IN', // Hindi
      'fi': 'FI', // Finnish
      'zh-HK': 'HK', // Chinese (Hong Kong)
      'en-GB': 'GB', // English (UK)
      'pt-BR': 'BR', // Portuguese (Brazil)
      'fr-CA': 'CA', // French (Canada)
      'es-MX': 'MX', // Spanish (Mexico)
    };

    String tempLang = langShort.containsKey(systemLang) ? systemLang : 'ru';
    String tempCountry = systemCountry.isNotEmpty
        ? systemCountry
        : (langCountryMap[tempLang] ?? 'RU');

    if (!(prefs.getBool('localeCountrySelected') ?? false)) {
      Locale? locale;
      String? countryCode;

      List<String> prioritySpecies = getPrioritySpeciesByCountry(tempCountry);
      Set<String> tempSelectedSpecies = prioritySpecies.toSet();

      bool showDensity = false;
      bool showBarkCorrection = false;
      String search = '';

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                colors: [Color(0xFF232526), Color(0xFF414345)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: Offset(0, 24),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setStateDialog) {
                  tempLang = context.locale.languageCode;
                  final countryList = countries
                      .map((c) => DropdownMenuItem(
                            value: c['code'],
                            child: Text(c['name']!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ))
                      .toList();

                  // ...existing code...

// В методе _startSequence(), в части с showDialog, замените langList на:
                  final langList = [
                    DropdownMenuItem(
                        value: 'ru',
                        child: Text('Русский (RU)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'uk',
                        child: Text('Українська (UA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'en',
                        child: Text('English (EN)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'de',
                        child: Text('Deutsch (DE)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'fr',
                        child: Text('Français (FR)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'es',
                        child: Text('Español (ES)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'it',
                        child: Text('Italiano (IT)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'jp',
                        child: Text('日本語 (JP)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'pl',
                        child: Text('Polski (PL)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'zh-CN',
                        child: Text('中文简体 (CN)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'zh-TW',
                        child: Text('中文繁體 (TW)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ar',
                        child: Text('العربية (AR)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'tr',
                        child: Text('Türkçe (TR)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'pt',
                        child: Text('Português (PT)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ko',
                        child: Text('한국어 (KO)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'id',
                        child: Text('Bahasa Indonesia (ID)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'af',
                        child: Text('Afrikaans (AF)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'th',
                        child: Text('ไทย (TH)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'vi',
                        child: Text('Tiếng Việt (VI)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'hu',
                        child: Text('Magyar (HU)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'fa',
                        child: Text('فارسی (FA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'az',
                        child: Text('Azərbaycan (AZ)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'bg',
                        child: Text('Български (BG)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'be',
                        child: Text('Беларуская (BE)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'cs',
                        child: Text('Čeština (CS)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'da',
                        child: Text('Dansk (DA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'et',
                        child: Text('Eesti (ET)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'fil',
                        child: Text('Filipino (FIL)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'he',
                        child: Text('עברית (HE)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'hr',
                        child: Text('Hrvatski (HR)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'hy',
                        child: Text('Հայերեն (HY)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ka',
                        child: Text('ქართული (KA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'kn',
                        child: Text('ಕನ್ನಡ (KN)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'lb',
                        child: Text('Lëtzebuergesch (LB)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'bn',
                        child: Text('বাংলা (BN)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'lv',
                        child: Text('Latviešu (LV)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'mk',
                        child: Text('Македонски (MK)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ml',
                        child: Text('മലയാളം (ML)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'bs',
                        child: Text('Bosanski (BS)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'nl',
                        child: Text('Nederlands (NL)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'cy',
                        child: Text('Cymraeg (CY)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ga',
                        child: Text('Gaeilge (GA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'gu',
                        child: Text('ગુજરાતી (GU)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ha',
                        child: Text('Hausa (HA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ig',
                        child: Text('Igbo (IG)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ne',
                        child: Text('नेपाली (NE)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'mn',
                        child: Text('Монгол (MN)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'mt',
                        child: Text('Malti (MT)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'pa',
                        child: Text('ਪੰਜਾਬੀ (PA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'sk',
                        child: Text('Slovenčina (SK)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ro',
                        child: Text('Română (RO)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'si',
                        child: Text('සිංහල (SI)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'sl',
                        child: Text('Slovenščina (SL)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'sr',
                        child: Text('Српски (SR)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'sv',
                        child: Text('Svenska (SV)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ta',
                        child: Text('தமிழ் (TA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'te',
                        child: Text('తెలుగు (TE)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'tg',
                        child: Text('Тоҷикӣ (TG)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'uz',
                        child: Text('O\'zbekcha (UZ)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'yo',
                        child: Text('Yorùbá (YO)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'zu',
                        child: Text('isiZulu (ZU)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'sq',
                        child: Text('Shqip (SQ)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'sw',
                        child: Text('Kiswahili (SW)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'tk',
                        child: Text('Türkmen (TK)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ur',
                        child: Text('اردو (UR)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'no',
                        child: Text('Norsk (NO)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'ms',
                        child: Text('Bahasa Melayu (MS)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'hi',
                        child: Text('हिन्दी (HI)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'fi',
                        child: Text('Suomi (FI)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'zh-HK',
                        child: Text('中文 (香港) (ZH-HK)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'en-GB',
                        child: Text('English (UK) (EN-GB)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'pt-BR',
                        child: Text('Português (Brasil) (PT-BR)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'fr-CA',
                        child: Text('Français (Canada) (FR-CA)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    DropdownMenuItem(
                        value: 'es-MX',
                        child: Text('Español (México) (ES-MX)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ];

// ...existing code...

                  final speciesList = allSpecies.toList()..sort();
                  final filtered = search.isEmpty
                      ? prioritySpecies
                      : speciesList
                          .where((s) =>
                              s.toLowerCase().contains(search.toLowerCase()))
                          .toList();

                  return SizedBox(
                    width: 460,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Верхняя иконка и приветствие
                          Padding(
                            padding: const EdgeInsets.only(top: 36, bottom: 10),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFFFFD700).withOpacity(0.25),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/icons/appbar_icon.png',
                                    width: 54,
                                    height: 54,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Forest Calculator'.tr(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Professional. Simple. Accurate.'.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Блок настроек
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                    color: Color(0xFFFFD700), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'settings'.tr(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                  color: Color(0xFFFFD700),
                                                  width: 2),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: DropdownButton<String>(
                                              value: tempLang,
                                              isExpanded: true,
                                              dropdownColor: Colors.black,
                                              iconEnabledColor: Colors.white,
                                              underline: SizedBox(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                              items: langList,
                                              onChanged: (v) async {
                                                tempLang = v!;
                                                await context.setLocale(
                                                    Locale(tempLang));
                                                setStateDialog(
                                                    () {}); // обновит все .tr()
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 14),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                  color: Color(0xFFFFD700),
                                                  width: 2),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: DropdownButton<String>(
                                              value: tempCountry,
                                              isExpanded: true,
                                              dropdownColor: Colors.black,
                                              iconEnabledColor: Colors.white,
                                              underline: SizedBox(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                              items: countryList,
                                              onChanged: (v) {
                                                setStateDialog(() {
                                                  tempCountry = v!;
                                                  prioritySpecies =
                                                      getPrioritySpeciesByCountry(
                                                          tempCountry);
                                                  tempSelectedSpecies =
                                                      prioritySpecies.toSet();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    CheckboxListTile(
                                      value: showDensity,
                                      onChanged: (v) => setStateDialog(
                                          () => showDensity = v ?? false),
                                      title: Text('show_density'.tr(),
                                          style:
                                              TextStyle(color: Colors.white)),
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      side: BorderSide(
                                        color: Color(0xFFFFD700),
                                        width: 2,
                                      ),
                                      activeColor: Color(0xFFFFD700),
                                      checkColor: Colors.black,
                                    ),
                                    CheckboxListTile(
                                      value: showBarkCorrection,
                                      onChanged: (v) => setStateDialog(() =>
                                          showBarkCorrection = v ?? false),
                                      title: Text('show_bark'.tr(),
                                          style:
                                              TextStyle(color: Colors.white)),
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      side: BorderSide(
                                        color: Color(0xFFFFD700),
                                        width: 2,
                                      ),
                                      activeColor: Color(0xFFFFD700),
                                      checkColor: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Блок выбора пород
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFE8FCD9),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                    color: Color(0xFF8BC34A), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF8BC34A).withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'select_species'.tr(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF33691E),
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: 'search'.tr(),
                                        prefixIcon: Icon(Icons.search,
                                            color: Color(0xFF8BC34A)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Color(0xFF8BC34A)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Color(0xFF8BC34A)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Color(0xFF8BC34A),
                                              width: 2),
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8),
                                      ),
                                      style:
                                          TextStyle(color: Color(0xFF33691E)),
                                      onChanged: (v) =>
                                          setStateDialog(() => search = v),
                                    ),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      height: 180,
                                      child: Scrollbar(
                                        child: ListView(
                                          children: filtered.map((s) {
                                            final selected =
                                                tempSelectedSpecies.contains(s);
                                            return CheckboxListTile(
                                              value: selected,
                                              onChanged: (v) {
                                                setStateDialog(() {
                                                  if (v == true) {
                                                    tempSelectedSpecies.add(s);
                                                  } else {
                                                    tempSelectedSpecies
                                                        .remove(s);
                                                  }
                                                });
                                              },
                                              title: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      s.tr(),
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF33691E),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  if (showDensity) ...[
                                                    SizedBox(width: 6),
                                                    Text(
                                                      '(ρ: ${getDensityForSpecies(s)})',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF689F38)),
                                                    ),
                                                  ],
                                                  if (showBarkCorrection) ...[
                                                    SizedBox(width: 6),
                                                    Text(
                                                      '(кора: ${getBarkCorrectionForSpecies(s)})',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF388E3C)),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              side: BorderSide(
                                                  color: Color(0xFF8BC34A),
                                                  width: 2),
                                              activeColor: Color(0xFF8BC34A),
                                              checkColor: Colors.white,
                                              tileColor:
                                                  Colors.white.withOpacity(0.0),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        side: BorderSide(
                                            color: Color(0xFFFFD700), width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 36, vertical: 14),
                                        textStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        elevation: 6,
                                      ),
                                      onPressed: () async {
                                        final result =
                                            await showDialog<Set<String>>(
                                          context: context,
                                          builder: (context) =>
                                              _AllSpeciesDialog(
                                            selected: tempSelectedSpecies,
                                            showDensity: showDensity,
                                            showBarkCorrection:
                                                showBarkCorrection,
                                          ),
                                        );
                                        if (result != null) {
                                          setStateDialog(() {
                                            tempSelectedSpecies = result;
                                          });
                                        }
                                      },
                                      child: Text(
                                        'select_custom_species'.tr(),
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 18),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 16.0, top: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFFD700).withOpacity(0.18),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/icons/logo_light.png',
                                width: 120,
                                height: 120,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                side: BorderSide(
                                    color: Color(0xFFFFD700), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 36, vertical: 14),
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                elevation: 8,
                              ),
                              onPressed: () async {
                                locale = Locale(tempLang);
                                countryCode = tempCountry;
                                prefs.setStringList('selectedSpeciesList',
                                    tempSelectedSpecies.toList());
                                prefs.setBool('showDensity', showDensity);
                                prefs.setBool(
                                    'showBarkCorrection', showBarkCorrection);
                                await context.setLocale(locale!);
                                await prefs.setString(
                                    'selectedCountry', countryCode!);
                                await prefs.setBool(
                                    'localeCountrySelected', true);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'ok_btn'.tr(),
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    // --- ЛИЦЕНЗИЯ ---
    final accepted = prefs.getBool('licenseAccepted') ?? false;
    if (!accepted) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => LicenseScreen(),
        ),
      );
      if (result == true) {
        await prefs.setBool('licenseAccepted', true);
        _goToMain();
      }
    } else {
      _goToMain();
    }
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SplashScreen(),
    );
  }
}

// Диалог выбора всех пород (с поиском и увеличенной высотой)
class _AllSpeciesDialog extends StatefulWidget {
  final Set<String> selected;
  final bool showDensity;
  final bool showBarkCorrection;
  const _AllSpeciesDialog({
    required this.selected,
    required this.showDensity,
    required this.showBarkCorrection,
  });

  @override
  State<_AllSpeciesDialog> createState() => _AllSpeciesDialogState();
}

class _AllSpeciesDialogState extends State<_AllSpeciesDialog> {
  late Set<String> tempSelected;
  String search = '';

  @override
  void initState() {
    super.initState();
    tempSelected = Set<String>.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final speciesList = allSpecies.toList()..sort();
    final filtered = search.isEmpty
        ? speciesList
        : speciesList
            .where((s) => s.toLowerCase().contains(search.toLowerCase()))
            .toList();
    return AlertDialog(
      backgroundColor: Color(0xFFE8FCD9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Color(0xFF8BC34A), width: 2),
      ),
      title: Text('select_species'.tr(),
          style:
              TextStyle(color: Color(0xFF33691E), fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search'.tr(),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF8BC34A)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF8BC34A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF8BC34A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF8BC34A), width: 2),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                ),
                style: TextStyle(color: Color(0xFF33691E)),
                onChanged: (v) => setState(() => search = v),
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: filtered.map((s) {
                    final selected = tempSelected.contains(s);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            tempSelected.add(s);
                          } else {
                            tempSelected.remove(s);
                          }
                        });
                      },
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              s.tr(),
                              style: TextStyle(
                                color: Color(0xFF33691E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (widget.showDensity) ...[
                            SizedBox(width: 6),
                            Text('(ρ: ${getDensityForSpecies(s)})',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF689F38))),
                          ],
                          if (widget.showBarkCorrection) ...[
                            SizedBox(width: 6),
                            Text('(кора: ${getBarkCorrectionForSpecies(s)})',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF388E3C))),
                          ],
                        ],
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      side: BorderSide(color: Color(0xFF8BC34A), width: 2),
                      activeColor: Color(0xFF8BC34A),
                      checkColor: Colors.white,
                      tileColor: Colors.white.withOpacity(0.0),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF33691E),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel_btn'.tr()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            side: BorderSide(color: Color(0xFFFFD700), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 6,
          ),
          onPressed: () => Navigator.of(context).pop(tempSelected),
          child: Text(
            'ok_btn'.tr(),
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Верхняя иконка (больше)
            Image.asset(
              'assets/icons/appbar_icon.png',
              width: 140,
              height: 140,
            ),
            SizedBox(height: 28),
            // Подпись Forest Calculator (больше)
            Text(
              'Forest Calculator',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.black,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 7,
                    offset: Offset(1.5, 1.5),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 14),
            // Подпись By (больше)
            Text(
              'By',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 24),
            // Логотип студии (еще больше)
            Image.asset(
              'assets/icons/logo_light.png',
              width: 160,
              height: 160,
            ),
          ],
        ),
      ),
    );
  }
}
