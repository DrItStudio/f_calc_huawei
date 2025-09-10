import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import '../ads_controller.dart';
import '../screens/vip.dart';
import '../data/species_meta BF.dart' as meta_bf;
import '../widgets/doyle_log_rule_table.dart';
import '../widgets/International_Inch_Log_Rule_Table.dart';
import '../widgets/Scribner-Log-Volume-Table.dart';
import '../utlits/recalcRowBf.dart';
import '../widgets/main_drawer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math' as math;

// После import-ов, до классов:

class CalculatorBfButtonsScreen extends StatefulWidget {
  final List<String> initialSpeciesList;
  final Map<String, double> initialSpeciesDensity;
  final String initialLengthUnit;
  final String initialDiameterUnit;
  final String initialWeightUnit;
  final bool showGrossWeightColumn;
  final bool showNetWeightColumn;
  final bool showBarkVolumeColumn;

  const CalculatorBfButtonsScreen({
    Key? key,
    required this.initialSpeciesList,
    required this.initialSpeciesDensity,
    required this.initialLengthUnit,
    required this.initialDiameterUnit,
    required this.initialWeightUnit,
    this.showGrossWeightColumn = false,
    this.showNetWeightColumn = false,
    this.showBarkVolumeColumn = false,
  }) : super(key: key);

  @override
  _CalculatorBfButtonsScreenState createState() =>
      _CalculatorBfButtonsScreenState();
}

class _CalculatorBfButtonsScreenState extends State<CalculatorBfButtonsScreen> {
  // Пользовательские настройки
  late List<String> speciesList;
  late Map<String, double> speciesDensity;

  late final Map<String, meta_bf.SpeciesMeta> speciesMeta;

  List<String> customSpecies = [];
  List<String> selectedSpeciesList = [];

  // Основные переменные
  String? selectedJasDensityRange;
  String? selectedMethod;
  String? selectedSpecies;
  String? selectedGrade;
  double? length;
  int? quantity = 1;
  double? price;
  double volume = 0;
  double totalPrice = 0;
  double grossWeight = 0.0;
  double netWeight = 0.0;
  bool showGrossWeightColumn = false;
  bool showNetWeightColumn = false;
  bool showBarkVolumeColumn = false;
  String lengthUnit = 'ft';
  String diameterUnit = 'in';
  String weightUnit = 'lb';

  bool isTableMethod() {
    return selectedMethod == 'Doyle Log Rule (table)' ||
        selectedMethod == 'International 1/4-Inch Log Rule (table)' ||
        selectedMethod == 'Scribner Log Volume Table';
  }

  List<int> getCurrentDiameters() {
    if (selectedMethod == 'Doyle Log Rule (table)') return doyleDiameters;
    if (selectedMethod == 'International 1/4-Inch Log Rule (table)')
      return intlInchDiameters;
    if (selectedMethod == 'Scribner Log Volume Table') return scribnerDiameters;
    // Для обычных методов — стандартный диапазон
    return [for (int d = 2; d <= 120; d += 2) d];
  }

  List<int> getCurrentLengths() {
    if (selectedMethod == 'Doyle Log Rule (table)') return doyleLengths;
    if (selectedMethod == 'International 1/4-Inch Log Rule (table)')
      return intlInchLengths;
    if (selectedMethod == 'Scribner Log Volume Table') return scribnerLengths;
    return [];
  }

  List<Map<String, dynamic>> tableData = [];

  List<String> gradeList = ['1', '2', '3'];
  List<String> methodList = [
    'GOST_2708_75',
    'ISO_4480_83',
    'neller',
    'cylinder_formula'
  ];
  final List<String> currencies = [
    'USD', // Доллар США
    'EUR', // Евро
    'CNY', // Китайский юань
    'JPY', // Японская иена
    'INR', // Индийская рупия
    'GBP', // Британский фунт
    'RUB', // Российский рубль
    'UAH', // Украинская гривна
    'KZT', // Казахстанский тенге
    'BYN', // Белорусский рубль
    'PLN', // Польский злотый
    'TRY', // Турецкая лира
    'BRL', // Бразильский реал
    'KRW', // Южнокорейская вона
    'VND', // Вьетнамский донг
    'IDR', // Индонезийская рупия
    'THB', // Тайский бат
    'CAD', // Канадский доллар
    'AUD', // Австралийский доллар
    'CHF', // Швейцарский франк
    'SEK', // Шведская крона
    'NOK', // Норвежская крона
    'DKK', // Датская крона
    'CZK', // Чешская крона
    'HUF', // Венгерский форинт
    'SGD', // Сингапурский доллар
    'HKD', // Гонконгский доллар
    'MYR', // Малайзийский ринггит
    'ZAR', // Южноафриканский рэнд
    'MXN', // Мексиканское песо
    'ILS', // Израильский шекель
    'SAR', // Саудовский риял
    'AED', // Дирхам ОАЭ
    'EGP', // Египетский фунт
    'NGN', // Нигерийская найра
    'ARS', // Аргентинское песо
    'CLP', // Чилийское песо
    'COP', // Колумбийское песо
    'NZD', // Новозеландский доллар
    'PKR', // Пакистанская рупия
    'BDT', // Бангладешская така
    'PHP', // Филиппинское песо
    'TWD', // Тайваньский доллар
    'RON', // Румынский лей
    'BGN', // Болгарский лев
    'HRK', // Хорватская куна
    'MAD', // Марокканский дирхам
    'DZD', // Алжирский динар
    'QAR', // Катарский риал
    'KWD', // Кувейтский динар
    'OMR', // Оманский риал
    'JOD', // Иорданский динар
    'LBP', // Ливанский фунт
    'SDG', // Суданский фунт
    'GEL', // Грузинский лари
    'AZN', // Азербайджанский манат
    'UZS', // Узбекский сум
    'AMD', // Армянский драм
    'MDL', // Молдавский лей
    'KGS', // Киргизский сом
    'TJS', // Таджикский сомони
    'MNT', // Монгольский тугрик
    'ISK', // Исландская крона
    'LKR', // Шри-ланкийская рупия
    'MMK', // Мьянманский кьят
    'KHR', // Камбоджийский риель
    'LAK', // Лаосский кип
    'BHD', // Бахрейнский динар
    'BAM', // Боснийская марка
    'MKD', // Македонский денар
    'RSD', // Сербский динар
    'ALL', // Албанский лек
    'UYU', // Уругвайское песо
    'PEN', // Перуанский соль
    'BOB', // Боливийский боливиано
    'PYG', // Парагвайский гуарани
    'CRC', // Костариканский колон
    'DOP', // Доминиканское песо
    'GTQ', // Гватемальский кетсаль
    'HNL', // Гондурасская лемпира
    'NIO', // Никарагуанская кордоба
    'SVC', // Сальвадорский колон
    'BZD', // Белизский доллар
    'JMD', // Ямайский доллар
    'TTD', // Тринидадский доллар
    'XOF', // Франк КФА BCEAO (Западная Африка)
    'XAF', // Франк КФА BEAC (Центральная Африка)
    'CDF', // Конголезский франк
    'KES', // Кенийский шиллинг
    'TZS', // Танзанийский шиллинг
    'UGX', // Угандийский шиллинг
    'ZMW', // Замбийская квача
    'MWK', // Малавийская квача
    'MZN', // Мозамбикский метикал
    'IRR', // Иранский риал
    'NPR', // Непальская рупия
    'TMT', // Туркменский манат
    // ...добавьте другие по необходимости
  ];

  final List<String> lengthUnits = ['ft'];
  final List<String> diameterUnits = ['in'];
  final List<String> weightUnits = ['lb'];

  final methods = [
    'Doyle Log Rule',
    'Doyle Log Rule (table)',
    'International 1/4-Inch Log Rule',
    'International 1/4-Inch Log Rule (table)',
    'Scribner Log Rule',
    'Scribner Log Volume Table',
  ];

  final List<int> doyleDiameters = [
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44
  ];
  final List<int> intlInchDiameters = [
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30
  ];
  final List<int> scribnerDiameters = [
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30
  ];
  final List<int> doyleLengths = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17];
  final List<int> intlInchLengths = [8, 10, 12, 14, 16];
  final List<int> scribnerLengths = [
    10,
    12,
    16,
    18,
    20,
    24,
    26,
    28,
    30,
    32,
    34,
    36,
    38,
    40
  ];

  String selectedCurrency = 'USD';

  // Для отображения столбцов
  bool showMethodColumn = true;
  bool showSpeciesColumn = true;
  bool showGradeColumn = true;
  bool showDensityColumn = true;
  bool showPriceColumn = true;
  bool showD2 = true; // or false, depending on your requirements
  bool showDMiddle = true; // or false, depending on your requirements
  bool showTotalPriceColumn = true; // or false, depending on your needs

  // Для чекбоксов веса и объема с корой
  bool showWithBark = false;
  double woodMoisture = 12.0; // влажность, если нужно
  double packageWeight = 0.0; // вес упаковки, если нужно
  double volumeWithBark = 0.0;

  double? selectedLength;

  double calculateDoyleBF(double diameterInches, double lengthFeet) {
    if (diameterInches <= 4) return 0;
    return ((diameterInches - 4) * (diameterInches - 4) * lengthFeet) / 16;
  }

  double calculateInternationalBF(double diameterInches, double lengthFeet) {
    double coeff = lengthFeet / 4;
    return 0.199 * diameterInches * diameterInches * coeff -
        0.642 * diameterInches * coeff -
        1.0 * coeff;
  }

  double calculateScribnerBF(double diameterInches, double lengthFeet) {
    double volume = ((diameterInches * diameterInches * lengthFeet) / 16) -
        (0.033 * diameterInches * (diameterInches - 1));
    return volume;
  }

  @override
  void initState() {
    super.initState();
    speciesList = List<String>.from(widget.initialSpeciesList);
    speciesDensity = Map<String, double>.from(widget.initialSpeciesDensity);
    lengthUnit = widget.initialLengthUnit;
    diameterUnit = widget.initialDiameterUnit;
    weightUnit = widget.initialWeightUnit;
    selectedSpeciesList = List<String>.from(speciesList);

    speciesMeta = meta_bf.speciesMeta;

    _ensureTablesDir();
    _loadTable(auto: true);

    // --- ДОБАВЬТЕ ЭТИ ВЫЗОВЫ ---
    _loadSelectedSpeciesList();
    _loadUserUnits();
  }

  void showAdThen(Function afterAd) {
    if (AdsController().canUsePremium()) {
      afterAd();
      AdsController().tryUsePremium();
    } else {
      AdsController().showRewardedForPremium(() {
        afterAd();
        AdsController().tryUsePremium();
      });
      // Можно показать диалог с предложением купить подписку, если нужно
    }
  }

  Future<bool?> showRewardedInfoDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text(
              'pro_or_video_title'.tr(),
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'pro_or_video_desc'.tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFD700),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('buy_pro_btn'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('watch_video_btn'.tr()),
          ),
        ],
      ),
    );
  }

  void _addCustomSpecies() {
    showDialog(
      context: context,
      builder: (context) {
        String? customSpecies;
        String? densityStr;
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          title: Text('add_custom_species'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'species_name'.tr()),
                onChanged: (value) => customSpecies = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'density_label'.tr()),
                keyboardType: TextInputType.number,
                onChanged: (value) => densityStr = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (customSpecies != null && customSpecies!.isNotEmpty) {
                  setState(() {
                    speciesList.add(customSpecies!);
                    selectedSpecies = customSpecies;
                    if (densityStr != null &&
                        double.tryParse(densityStr!) != null) {
                      speciesDensity[customSpecies!] =
                          double.parse(densityStr!);
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: Text('ok'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _removeCustomSpecies(String species) {
    setState(() {
      speciesList.remove(species);
      speciesDensity.remove(species);
      if (selectedSpecies == species) selectedSpecies = null;
    });
  }

  void _addCustomGrade() {
    showDialog(
      context: context,
      builder: (context) {
        String? customGrade;
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          title: Text('add_custom_grade'.tr()),
          content: TextFormField(
            onChanged: (value) {
              customGrade = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (customGrade != null && customGrade!.isNotEmpty) {
                  setState(() {
                    gradeList.add(customGrade!);
                    selectedGrade = customGrade;
                  });
                }
                Navigator.pop(context);
              },
              child: Text('ok'.tr()),
            ),
          ],
        );
      },
    );
  }

// --- Основная функция добавления строки ---
  void calculateAndAdd(int diameterRaw) {
    if (length == null || selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите корректные данные для расчета'.tr())),
      );
      return;
    }

    int qty = quantity ?? 1;
    double diameterInches = diameterRaw.toDouble();
    double lengthFeet = length ?? 0;
    double oneVol = 0.0;

    // --- Американские методы: сначала таблица, если нет — формула ---
    if (selectedMethod == 'Doyle Log Rule (table)') {
      oneVol = getDoyleLogRuleValue(diameterInches.round(), lengthFeet.round())
              ?.toDouble() ??
          calculateDoyleBF(diameterInches, lengthFeet);
    } else if (selectedMethod == 'Doyle Log Rule') {
      oneVol = calculateDoyleBF(diameterInches, lengthFeet);
    } else if (selectedMethod == 'International 1/4-Inch Log Rule (table)') {
      oneVol = getInternationalInchLogRuleValue(
                  diameterInches.round(), lengthFeet.round())
              ?.toDouble() ??
          calculateInternationalBF(diameterInches, lengthFeet);
    } else if (selectedMethod == 'International 1/4-Inch Log Rule') {
      oneVol = calculateInternationalBF(diameterInches, lengthFeet);
    } else if (selectedMethod == 'Scribner Log Volume Table') {
      oneVol = scribnerLogVolumeTable[lengthFeet.round()]
                  ?[diameterInches.round()]
              ?.toDouble() ??
          calculateScribnerBF(diameterInches, lengthFeet);
    } else if (selectedMethod == 'Scribner Log Rule') {
      oneVol = calculateScribnerBF(diameterInches, lengthFeet);
    } else {
      oneVol = 0.0;
    }

    double volumeLocal = oneVol * qty;
    double totalPriceLocal = volumeLocal * (price ?? 0);

    // --- Расчёт веса и объёма с корой ---
    double density = 50;
    if (selectedSpecies != null && speciesMeta.containsKey(selectedSpecies)) {
      density = speciesMeta[selectedSpecies!]!.density ?? 50;
    } else if (selectedSpecies != null &&
        speciesDensity.containsKey(selectedSpecies)) {
      density = speciesDensity[selectedSpecies!]!;
    }
    double barkPercent = 0.0;
    if (selectedSpecies != null && speciesMeta.containsKey(selectedSpecies)) {
      barkPercent = speciesMeta[selectedSpecies!]!.barkCorrection ?? 0.0;
    }
    double volumeWithBarkLocal = volumeLocal * (1 + barkPercent);
    double moistureCoef = 1 + (woodMoisture / 100);

    double netWeightLocal = (volumeLocal / 12) * density * moistureCoef;
    double grossWeightLocal =
        (volumeWithBarkLocal / 12) * density * moistureCoef + packageWeight;

    setState(() {
      final newRow = {
        'Метод': selectedMethod,
        'Порода': selectedSpecies ?? '',
        'Сорт': selectedGrade ?? '',
        'Длина': length,
        'Диаметр': diameterRaw,
        'Количество': qty,
        'Цена за BF': price ?? 0,
        'Объем': volumeLocal,
        'Итоговая цена': totalPriceLocal,
        'Плотность': density,
        'Брутто': grossWeightLocal,
        'Нетто': netWeightLocal,
        'Объем с корой': volumeWithBarkLocal,
      };
      tableData.add(newRow);
      grossWeight = grossWeightLocal;
      netWeight = netWeightLocal;
      volumeWithBark = volumeWithBarkLocal;
      _saveTable(auto: true);
    });
  }

  void _clearTable() {
    setState(() {
      tableData.clear();
      _saveTable(auto: true);
    });
  }

  Future<void> _ensureTablesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/wood_tables');
    if (!await tablesDir.exists()) {
      await tablesDir.create(recursive: true);
    }
  }

  Future<String?> _askFileName() async {
    String? fileName;
    await showDialog<String>(
      context: context,
      builder: (context) {
        String tempName = '';
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          title: Text('Введите имя файла'),
          content: TextFormField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Имя файла'),
            onChanged: (value) => tempName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Отмена
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                fileName = tempName.trim();
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    return fileName;
  }

  Future<Directory> getBfTablesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/tables/bf');
    if (!await tablesDir.exists()) {
      await tablesDir.create(recursive: true);
    }
    return tablesDir;
  }

// Также исправляем метод сохранения для корректного имени файлов
  Future<void> _saveTable({bool auto = false}) async {
    final dir = await getBfTablesDirectory();

    String fileName;
    if (auto) {
      final now = DateTime.now();
      final dateStr =
          '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}';
      fileName =
          'cb_mm_data_${dateStr}_$timeStr.csv'; // Используем cb_mm_data для BF экранов тоже
    } else {
      fileName = await _askFileName() ?? '';
      if (fileName.trim().isEmpty) return;
      if (!fileName.contains('cb_mm_data')) {
        fileName = 'cb_mm_data_$fileName';
      }
      if (!fileName.endsWith('.csv')) {
        fileName += '.csv';
      }
      final now = DateTime.now();
      final dateStr =
          '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
      if (!fileName.contains(dateStr)) {
        fileName = fileName.replaceFirst('.csv', '_$dateStr.csv');
      }
    }

    final file = File('${dir.path}/$fileName');

    final headers = [
      '№',
      if (showMethodColumn) 'Метод',
      if (showSpeciesColumn) 'Порода',
      if (showGradeColumn) 'Сорт',
      'Длина',
      'Диаметр',
      'Количество',
      if (showPriceColumn) 'Цена за BF',
      'Объем',
      if (showPriceColumn) 'Итоговая цена',
      if (showGrossWeightColumn) 'Брутто',
      if (showNetWeightColumn) 'Нетто',
      if (showBarkVolumeColumn) 'Объем с корой',
    ];

    final csvRows = <String>[];
    csvRows.add(headers.join(','));

    for (int i = 0; i < tableData.length; i++) {
      final row = tableData[i];
      csvRows.add([
        (i + 1).toString(),
        if (showMethodColumn) row['Метод'] ?? '',
        if (showSpeciesColumn) row['Порода'] ?? '',
        if (showGradeColumn) row['Сорт'] ?? '',
        row['Длина']?.toString() ?? '',
        row['Диаметр']?.toString() ?? '',
        row['Количество']?.toString() ?? '',
        if (showPriceColumn) row['Цена за BF']?.toString() ?? '',
        row['Объем'] != null ? parseNum(row['Объем']).toStringAsFixed(3) : '',
        if (showPriceColumn)
          row['Итоговая цена'] != null
              ? parseNum(row['Итоговая цена']).toStringAsFixed(2)
              : '',
        if (showGrossWeightColumn)
          row['Брутто'] != null
              ? parseNum(row['Брутто']).toStringAsFixed(3)
              : '',
        if (showNetWeightColumn)
          row['Нетто'] != null ? parseNum(row['Нетто']).toStringAsFixed(3) : '',
        if (showBarkVolumeColumn)
          row['Объем с корой'] != null
              ? parseNum(row['Объем с корой']).toStringAsFixed(3)
              : '',
      ].join(','));
    }

    await file.writeAsString(csvRows.join('\n'));
    if (!auto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('save_success'.tr(args: [fileName]))),
      );
    }
  }

  Future<void> _loadTable({bool auto = false}) async {
    final dir = await getBfTablesDirectory();
    // Только файлы с cb_mm_data и .csv (исправлено с cb_bf_data)
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('cb_mm_data') && f.path.endsWith('.csv'))
        .toList();

    String? selectedFile;
    if (auto) {
      if (files.isEmpty) return;
      // Самый свежий файл
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      selectedFile = files.first.path;
    } else {
      if (files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('no_saved_tables'.tr())),
        );
        return;
      }
      selectedFile = await showDialog<String>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('select_file'.tr()),
            children: files
                .map((f) => SimpleDialogOption(
                      child: Text(f.uri.pathSegments.last),
                      onPressed: () => Navigator.pop(context, f.path),
                    ))
                .toList(),
          );
        },
      );
      if (selectedFile == null) return;
    }

    final file = File(selectedFile);
    final lines = await file.readAsLines();
    if (lines.isEmpty) return;
    final headers = lines.first.split(',');

    setState(() {
      tableData =
          lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
        final values = line.split(',');
        final map = <String, dynamic>{};

        // Правильное сопоставление заголовков со значениями
        for (int i = 0; i < headers.length && i < values.length; i++) {
          map[headers[i]] = values[i];
        }

        // Преобразуем числовые поля с правильными ключами
        if (map.containsKey('Объем')) {
          map['Объем'] =
              double.tryParse(map['Объем'].toString().replaceAll(',', '.')) ??
                  0.0;
        }
        if (map.containsKey('Количество')) {
          map['Количество'] = int.tryParse(map['Количество'].toString()) ?? 1;
        }
        if (map.containsKey('Брутто')) {
          map['Брутто'] =
              double.tryParse(map['Брутто'].toString().replaceAll(',', '.')) ??
                  0.0;
        }
        if (map.containsKey('Нетто')) {
          map['Нетто'] =
              double.tryParse(map['Нетто'].toString().replaceAll(',', '.')) ??
                  0.0;
        }
        if (map.containsKey('Объем с корой')) {
          map['Объем с корой'] = double.tryParse(
                  map['Объем с корой'].toString().replaceAll(',', '.')) ??
              0.0;
        }
        if (map.containsKey('Итоговая цена')) {
          map['Итоговая цена'] = double.tryParse(
                  map['Итоговая цена'].toString().replaceAll(',', '.')) ??
              0.0;
        }
        if (map.containsKey('Длина')) {
          map['Длина'] = double.tryParse(map['Длина'].toString()) ?? 0.0;
        }
        if (map.containsKey('Диаметр')) {
          map['Диаметр'] = int.tryParse(map['Диаметр'].toString()) ?? 0;
        }
        if (map.containsKey('Цена за BF')) {
          map['Цена за BF'] = double.tryParse(
                  map['Цена за BF'].toString().replaceAll(',', '.')) ??
              0.0;
        }

        // ВАЖНО: Пересчитываем каждую строку после загрузки
        recalcRowBf(
          map,
          speciesDensity,
          speciesMeta,
          packageWeight,
          weightUnit,
          lengthUnit,
          diameterUnit,
          woodMoisture,
        );

        return map;
      }).toList();

      // Пересчитываем итоги после загрузки всех строк
      _recalculateTotals();
    });

    if (!auto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('load_success'.tr(args: [file.uri.pathSegments.last]))),
      );
    }
  }

// Добавляем метод для пересчета итогов
  void _recalculateTotals() {
    // Этот метод должен пересчитывать итоги, если это необходимо
    // В данном случае итоги рассчитываются динамически в build методе,
    // поэтому просто обновляем состояние
    setState(() {});
  }

  double parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty || s == '-' || s.toLowerCase() == 'null') return 0.0;
      return double.tryParse(s.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

// ...existing code...
  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    final font =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));

    final int totalCount = tableData.fold<int>(
      0,
      (sum, row) =>
          sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
    );
    final double totalSum = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Итоговая цена']),
    );
    final double totalVolume = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем']),
    );
    final double totalGross = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Брутто']),
    );
    final double totalNet = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Нетто']),
    );
    final double totalWithBark = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем с корой']),
    );

    // --- Заголовки ---
    final headers = [
      '№',
      if (showMethodColumn) 'method_col'.tr(),
      if (showSpeciesColumn) 'species_col'.tr(),
      if (showGradeColumn) 'grade_col'.tr(),
      'length_col'.tr(),
      'diameter_col'.tr(),
      'quantity_col'.tr(),
      if (showPriceColumn) 'price_col'.tr() + ' ($selectedCurrency)',
      '${'volume_col'.tr()} ($lengthUnit³)',
      if (showPriceColumn) 'sum_col'.tr() + ' ($selectedCurrency)',
      if (showGrossWeightColumn) 'gross_weight_col'.tr() + ' ($weightUnit)',
      if (showNetWeightColumn) 'net_weight_col'.tr() + ' ($weightUnit)',
      if (showBarkVolumeColumn) '${'bark_volume_col'.tr()} ($lengthUnit³)',
    ];

    // --- Данные ---
    final data = tableData.asMap().entries.map((entry) {
      int index = entry.key;
      final row = entry.value;
      return [
        (index + 1).toString(),
        if (showMethodColumn) row['Метод'] ?? '',
        if (showSpeciesColumn)
          (row['Порода'] is String && speciesList.contains(row['Порода']))
              ? (row['Порода'] as String).tr()
              : (row['Порода']?.toString() ?? ''),
        if (showGradeColumn) row['Сорт'] ?? '',
        row['Длина'] ?? '',
        row['Диаметр'] ?? '',
        row['Количество'] ?? '',
        if (showPriceColumn)
          row['Цена за BF'] != null
              ? parseNum(row['Цена за BF']).toStringAsFixed(2)
              : '',
        (row['Объем'] != null) ? parseNum(row['Объем']).toStringAsFixed(3) : '',
        if (showPriceColumn)
          (row['Итоговая цена'] != null)
              ? parseNum(row['Итоговая цена']).toStringAsFixed(2)
              : '',
        if (showGrossWeightColumn)
          (row['Брутто'] != null)
              ? parseNum(row['Брутто']).toStringAsFixed(3)
              : '',
        if (showNetWeightColumn)
          (row['Нетто'] != null)
              ? parseNum(row['Нетто']).toStringAsFixed(3)
              : '',
        if (showBarkVolumeColumn)
          (row['Объем с корой'] != null)
              ? parseNum(row['Объем с корой']).toStringAsFixed(3)
              : '',
      ];
    }).toList();

    // --- Итоговая строка ---
    final totalRow = <String>[];
    int col = 0;
    totalRow.add('total'.tr());
    col++;
    if (showMethodColumn) {
      totalRow.add('');
      col++;
    }
    if (showSpeciesColumn) {
      totalRow.add('');
      col++;
    }
    if (showGradeColumn) {
      totalRow.add('');
      col++;
    }
    totalRow.add('');
    col++; // length
    totalRow.add('');
    col++; // diameter
    totalRow.add(totalCount.toString());
    col++; // quantity
    if (showPriceColumn) {
      totalRow.add('');
      col++;
    }
    totalRow.add(totalVolume.toStringAsFixed(3));
    col++; // volume
    if (showPriceColumn) {
      totalRow.add(totalSum.toStringAsFixed(2));
      col++;
    }
    if (showGrossWeightColumn) {
      totalRow.add(totalGross.toStringAsFixed(3));
      col++;
    }
    if (showNetWeightColumn) {
      totalRow.add(totalNet.toStringAsFixed(3));
      col++;
    }
    if (showBarkVolumeColumn) {
      totalRow.add(totalWithBark.toStringAsFixed(3));
      col++;
    }
    data.add(totalRow);

    // --- АВТОМАТИЧЕСКОЕ УМЕНЬШЕНИЕ ШРИФТА ---
    final rowCount = data.length;
    final colCount = headers.length;
    double fontSize = 10;
    if (rowCount > 30 || colCount > 12) {
      fontSize = 7;
    } else if (rowCount > 15 || colCount > 8) {
      fontSize = 8;
    }

    // Разбиваем на страницы по 30 строк
    const rowsPerPage = 30;
    for (int i = 0; i < data.length; i += rowsPerPage) {
      final pageRows = data.skip(i).take(rowsPerPage).toList();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headers: headers,
              data: pageRows,
              cellStyle: pw.TextStyle(font: font, fontSize: fontSize),
              headerStyle: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: fontSize + 1),
            );
          },
        ),
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/table.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'export_pdf'.tr());
  }

  Future<void> _exportExcel() async {
    final int totalCount = tableData.fold<int>(
      0,
      (sum, row) =>
          sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
    );
    final double totalSum = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Итоговая цена']),
    );
    final double totalVolume = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем']),
    );
    final double totalGross = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Брутто']),
    );
    final double totalNet = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Нетто']),
    );
    final double totalWithBark = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем с корой']),
    );

    var excel = Excel.createExcel();
    var sheetObject = excel['Sheet1'];

    // Динамические заголовки
    final headers = [
      '№',
      if (showMethodColumn) 'method_col'.tr(),
      if (showSpeciesColumn) 'species_col'.tr(),
      if (showGradeColumn) 'grade_col'.tr(),
      'length_col'.tr(),
      'diameter_col'.tr(),
      'quantity_col'.tr(),
      if (showPriceColumn) 'price_col'.tr() + ' ($selectedCurrency)',
      '${'volume_col'.tr()} ($lengthUnit³)',
      if (showPriceColumn) 'sum_col'.tr() + ' ($selectedCurrency)',
      if (showGrossWeightColumn) 'gross_weight_col'.tr() + ' ($weightUnit)',
      if (showNetWeightColumn) 'net_weight_col'.tr() + ' ($weightUnit)',
      if (showBarkVolumeColumn) '${'bark_volume_col'.tr()} ($lengthUnit³)',
    ];
    sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Динамические строки
    for (var i = 0; i < tableData.length; i++) {
      final row = tableData[i];
      final excelRow = [
        (i + 1).toString(),
        if (showMethodColumn) row['Метод'] ?? '',
        if (showSpeciesColumn)
          (row['Порода'] is String && speciesList.contains(row['Порода']))
              ? (row['Порода'] as String).tr()
              : (row['Порода']?.toString() ?? ''),
        if (showGradeColumn) row['Сорт'] ?? '',
        row['Длина'] ?? '',
        row['Диаметр'] ?? '',
        row['Количество'] ?? '',
        if (showPriceColumn)
          row['Цена за BF'] != null
              ? parseNum(row['Цена за BF']).toStringAsFixed(2)
              : '',
        (row['Объем'] != null) ? parseNum(row['Объем']).toStringAsFixed(3) : '',
        if (showPriceColumn)
          (row['Итоговая цена'] != null)
              ? parseNum(row['Итоговая цена']).toStringAsFixed(2)
              : '',
        if (showGrossWeightColumn)
          (row['Брутто'] != null)
              ? parseNum(row['Брутто']).toStringAsFixed(3)
              : '',
        if (showNetWeightColumn)
          (row['Нетто'] != null)
              ? parseNum(row['Нетто']).toStringAsFixed(3)
              : '',
        if (showBarkVolumeColumn)
          (row['Объем с корой'] != null)
              ? parseNum(row['Объем с корой']).toStringAsFixed(3)
              : '',
      ];
      sheetObject
          .appendRow(excelRow.map((v) => TextCellValue(v.toString())).toList());
    }

    // Итоговая строка
    final totalRow = <String>[];
    int col = 0;
    totalRow.add('total'.tr());
    col++;
    if (showMethodColumn) {
      totalRow.add('');
      col++;
    }
    if (showSpeciesColumn) {
      totalRow.add('');
      col++;
    }
    if (showGradeColumn) {
      totalRow.add('');
      col++;
    }
    totalRow.add('');
    col++; // length
    totalRow.add('');
    col++; // diameter
    totalRow.add(totalCount.toString());
    col++; // quantity
    if (showPriceColumn) {
      totalRow.add('');
      col++;
    }
    totalRow.add(totalVolume.toStringAsFixed(3));
    col++; // volume
    if (showPriceColumn) {
      totalRow.add(totalSum.toStringAsFixed(2));
      col++;
    }
    if (showGrossWeightColumn) {
      totalRow.add(totalGross.toStringAsFixed(3));
      col++;
    }
    if (showNetWeightColumn) {
      totalRow.add(totalNet.toStringAsFixed(3));
      col++;
    }
    if (showBarkVolumeColumn) {
      totalRow.add(totalWithBark.toStringAsFixed(3));
      col++;
    }
    sheetObject.appendRow(totalRow.map((v) => TextCellValue(v)).toList());

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/table.xlsx');
    await file.writeAsBytes(excel.encode()!);
    await Share.shareXFiles([XFile(file.path)], text: 'export_excel'.tr());
  }

  Future<void> _showSpeciesFilterDialog() async {
    Set<String> tempSelected = Set<String>.from(selectedSpeciesList);
    String search = '';
    String filterType = 'all'; // 'all', 'hardwood', 'softwood'
    String? filterRegion;
    double? filterMinDensity;
    double? filterMaxDensity;
    bool showDensityLocal = true;
    bool showBarkLocal = true;

    // Собираем все регионы из speciesMeta
    final allRegions = <String>{
      for (final meta in speciesMeta.values) ...meta.countries
    }.toList()
      ..sort();

    // Собираем все породы (включая кастомные)
    List<String> allSpecies = [
      ...speciesMeta.keys,
      ...customSpecies,
    ]..sort();

    List<String> filteredSpecies() {
      return allSpecies.where((s) {
        final meta = speciesMeta[s];
        // Для кастомных пород фильтруем только по поиску
        if (meta == null) {
          if (search.isNotEmpty &&
              !s.toLowerCase().contains(search.toLowerCase()) &&
              !(s.tr().toLowerCase().contains(search.toLowerCase()))) {
            return false;
          }
          return true;
        }
        if (search.isNotEmpty &&
            !s.toLowerCase().contains(search.toLowerCase()) &&
            !(s.tr().toLowerCase().contains(search.toLowerCase()))) {
          return false;
        }
        if (filterType == 'hardwood' && meta.type != 'hardwood') return false;
        if (filterType == 'softwood' && meta.type != 'softwood') return false;
        if ((filterRegion ?? '').isNotEmpty &&
            !meta.countries.contains(filterRegion)) return false;
        if (filterMinDensity != null && (meta.density ?? 0) < filterMinDensity!)
          return false;
        if (filterMaxDensity != null && (meta.density ?? 0) > filterMaxDensity!)
          return false;
        return true;
      }).toList();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filtered = filteredSpecies();
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              title: Text('select_species'.tr()),
              content: SizedBox(
                width: 500,
                height: 600,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'search'.tr(),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (v) => setStateDialog(() => search = v),
                        ),
                      ),
                      // ...existing code...
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ChoiceChip(
                                label: Text('all_types'.tr()),
                                selected: filterType == 'all',
                                onSelected: (_) =>
                                    setStateDialog(() => filterType = 'all'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              ChoiceChip(
                                label: Text('hardwood'.tr()),
                                selected: filterType == 'hardwood',
                                onSelected: (_) => setStateDialog(
                                    () => filterType = 'hardwood'),
                              ),
                              SizedBox(width: 8),
                              ChoiceChip(
                                label: Text('softwood'.tr()),
                                selected: filterType == 'softwood',
                                onSelected: (_) => setStateDialog(
                                    () => filterType = 'softwood'),
                              ),
                            ],
                          ),
                        ],
                      ),
// ...existing code...
                      DropdownButton<String>(
                        value: filterRegion,
                        hint: Text('region'.tr()),
                        isExpanded: true,
                        items: allRegions
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) =>
                            setStateDialog(() => filterRegion = v),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'min_density'.tr()),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => setStateDialog(
                                  () => filterMinDensity = double.tryParse(v)),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'max_density'.tr()),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => setStateDialog(
                                  () => filterMaxDensity = double.tryParse(v)),
                            ),
                          ),
                        ],
                      ),
                      CheckboxListTile(
                        value: showDensityLocal,
                        onChanged: (v) =>
                            setStateDialog(() => showDensityLocal = v ?? false),
                        title: Text('show_density'.tr()),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      CheckboxListTile(
                        value: showBarkLocal,
                        onChanged: (v) =>
                            setStateDialog(() => showBarkLocal = v ?? false),
                        title: Text('show_bark'.tr()),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      if (filterType == 'all') ...[
                        if (filtered
                            .where((s) => speciesMeta[s]?.type == 'hardwood')
                            .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('hardwood'.tr(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ...filtered
                            .where((s) => speciesMeta[s]?.type == 'hardwood')
                            .map((s) => CheckboxListTile(
                                  value: tempSelected.contains(s),
                                  onChanged: (v) {
                                    setStateDialog(() {
                                      if (v == true) {
                                        tempSelected.add(s);
                                      } else {
                                        tempSelected.remove(s);
                                      }
                                    });
                                  },
                                  title: Row(
                                    children: [
                                      Flexible(child: Text(s.tr())),
                                      if (showDensityLocal &&
                                          speciesMeta[s]?.density != null) ...[
                                        SizedBox(width: 6),
                                        Text(
                                            '(ρ: ${speciesMeta[s]!.density!.toStringAsFixed(0)})',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                      if (showBarkLocal &&
                                          speciesMeta[s]?.barkCorrection !=
                                              null) ...[
                                        SizedBox(width: 6),
                                        Text(
                                          '(${'bark'.tr()}: +${(speciesMeta[s]!.barkCorrection! * 100).round()}%)',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ],
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                )),
                        if (filtered
                            .where((s) => speciesMeta[s]?.type == 'softwood')
                            .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('softwood'.tr(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ...filtered
                            .where((s) => speciesMeta[s]?.type == 'softwood')
                            .map((s) => CheckboxListTile(
                                  value: tempSelected.contains(s),
                                  onChanged: (v) {
                                    setStateDialog(() {
                                      if (v == true) {
                                        tempSelected.add(s);
                                      } else {
                                        tempSelected.remove(s);
                                      }
                                    });
                                  },
                                  title: Row(
                                    children: [
                                      Flexible(child: Text(s.tr())),
                                      if (showDensityLocal &&
                                          speciesMeta[s]?.density != null) ...[
                                        SizedBox(width: 6),
                                        Text(
                                            '(ρ: ${speciesMeta[s]!.density!.toStringAsFixed(0)})',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                      if (showBarkLocal &&
                                          speciesMeta[s]?.barkCorrection !=
                                              null) ...[
                                        SizedBox(width: 6),
                                        Text(
                                          '(${'bark'.tr()}: +${(speciesMeta[s]!.barkCorrection! * 100).round()}%)',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ],
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                )),
                        // Кастомные породы (без типа)
                        if (filtered
                            .where((s) => speciesMeta[s] == null)
                            .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('custom_species'.tr(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ...filtered
                            .where((s) => speciesMeta[s] == null)
                            .map((s) => CheckboxListTile(
                                  value: tempSelected.contains(s),
                                  onChanged: (v) {
                                    setStateDialog(() {
                                      if (v == true) {
                                        tempSelected.add(s);
                                      } else {
                                        tempSelected.remove(s);
                                      }
                                    });
                                  },
                                  title: Text(s),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                )),
                      ] else ...[
                        ...filtered.map((s) => CheckboxListTile(
                              value: tempSelected.contains(s),
                              onChanged: (v) {
                                setStateDialog(() {
                                  if (v == true) {
                                    tempSelected.add(s);
                                  } else {
                                    tempSelected.remove(s);
                                  }
                                });
                              },
                              title: Row(
                                children: [
                                  Flexible(child: Text(s.tr())),
                                  if (showDensityLocal &&
                                      speciesMeta[s]?.density != null) ...[
                                    SizedBox(width: 6),
                                    Text(
                                        '(ρ: ${speciesMeta[s]!.density!.toStringAsFixed(0)})',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                  if (showBarkLocal &&
                                      speciesMeta[s]?.barkCorrection !=
                                          null) ...[
                                    SizedBox(width: 6),
                                    Text(
                                      '(${'bark'.tr()}: +${(speciesMeta[s]!.barkCorrection! * 100).round()}%)',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.green),
                                    ),
                                  ],
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            )),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel_btn'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedSpeciesList = tempSelected.toList();
                      // Обновить выбранную породу, если нужно
                      if (selectedSpecies == null ||
                          !selectedSpeciesList.contains(selectedSpecies)) {
                        selectedSpecies = selectedSpeciesList.isNotEmpty
                            ? selectedSpeciesList.first
                            : null;
                      }
                    });
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setStringList(
                          'selectedSpeciesList', selectedSpeciesList);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('ok_btn'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveUserUnits() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lengthUnit', lengthUnit);
    prefs.setString('diameterUnit', diameterUnit);
    prefs.setString('weightUnit', weightUnit);
  }

  void _applyUnitChanges({String? newLengthUnit, String? newDiameterUnit}) {
    setState(() {
      if (newLengthUnit != null) {
        lengthUnit = newLengthUnit;
      }
      if (newDiameterUnit != null) {
        diameterUnit = newDiameterUnit;
      }
    });
  }

  void calculateVolumeWithBark() {
    double percentage = 0.0;
    if (selectedSpecies != null && speciesMeta.containsKey(selectedSpecies)) {
      percentage = speciesMeta[selectedSpecies!]?.barkCorrection ?? 0.0;
    }
    setState(() {
      volumeWithBark = volume > 0 ? volume * (1 + percentage) : 0.0;
    });
  }

  void calculateWeights() {
    if (volume > 0) {
      double density = 50; // Значение по умолчанию (lb/ft³)
      if (selectedSpecies != null && speciesMeta.containsKey(selectedSpecies)) {
        density = speciesMeta[selectedSpecies!]!.density ?? 50;
      } else if (selectedSpecies != null &&
          speciesDensity.containsKey(selectedSpecies)) {
        density = speciesDensity[selectedSpecies!]!;
      }
      double moistureCoef = 1 + (woodMoisture / 100);

      setState(() {
        netWeight = (volume / 12) * density * moistureCoef;
        grossWeight = (volumeWithBark > 0
                ? (volumeWithBark / 12) * density * moistureCoef
                : (volume / 12) * density * moistureCoef) +
            packageWeight;
      });
    } else {
      setState(() {
        grossWeight = 0.0;
        netWeight = 0.0;
      });
    }
  }

  Future<void> _loadSelectedSpeciesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList('selectedSpeciesList');
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        speciesList = saved;
        selectedSpeciesList = saved;
        selectedSpecies = selectedSpeciesList.first;
      });
    }
  }

  Future<void> _loadUserUnits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lengthUnit = prefs.getString('selectedLengthUnit') ?? 'ft';
      diameterUnit = prefs.getString('selectedDiameterUnit') ?? 'in';
      weightUnit = prefs.getString('selectedWeightUnit') ?? 'lb';
    });
  }

  final List<int> diameters = [for (int d = 6; d <= 60; d += 2) d];

  Widget _lengthInput() {
    List<int> lengths = [];
    bool isTable = false;
    if (selectedMethod == 'Doyle Log Rule (table)') {
      lengths = doyleLengths;
      isTable = true;
    } else if (selectedMethod == 'International 1/4-Inch Log Rule (table)') {
      lengths = intlInchLengths;
      isTable = true;
    } else if (selectedMethod == 'Scribner Log Volume Table') {
      lengths = scribnerLengths;
      isTable = true;
    }

    if (isTable) {
      return GestureDetector(
        onTap: () async {
          final selected = await showDialog<double>(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).dialogBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      'L',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '($lengthUnit)',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  // Ограничиваем максимальную высоту (например, 240, можно меньше)
                  height: 240,
                  width: double.maxFinite,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // или адаптивно, если хотите
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: lengths.length,
                    itemBuilder: (context, index) {
                      final l = lengths[index];
                      final isSelected = selectedLength == l.toDouble();
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, l.toDouble());
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.15)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(0),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
          if (selected != null) {
            setState(() {
              selectedLength = selected;
              length = selected;
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.secondary, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Text(
            selectedLength != null ? selectedLength!.toString() : '—',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      // Обычный ввод для остальных методов
      return TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          labelText: 'length_label'.tr(),
          suffixText: lengthUnit,
        ),
        keyboardType: TextInputType.number,
        initialValue: length?.toString() ?? '',
        onChanged: (value) {
          setState(() {
            length = double.tryParse(value);
            selectedLength = length;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = tableData.fold<int>(
      0,
      (sum, row) =>
          sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
    );
    double parseNum(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final s = value.trim();
        if (s.isEmpty || s == '-' || s.toLowerCase() == 'null') return 0.0;
        return double.tryParse(s.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    final double totalVolume = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем']),
    );
    final double totalSum = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Итоговая цена']),
    );
    final double totalGross = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Брутто']),
    );
    final double totalNet = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Нетто']),
    );
    final double totalWithBark = tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем с корой']),
    );
    final currentLengths = getCurrentLengths();
    if (isTableMethod() &&
        selectedLength != null &&
        !currentLengths.contains(selectedLength!.toInt())) {
      selectedLength = null;
      length = null;
    }
// Локальные переменные для настроек внутри диалога

    return WillPopScope(
        onWillPop: () async {
          await AdsController().showInterstitialIfNeeded();
          return true;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () async {
                    await AdsController().showInterstitialIfNeeded();
                    Scaffold.of(context).openDrawer();
                  }),
            ),
            title: Row(
              children: [
                Image.asset(
                  'assets/icons/appbar_icon.png',
                  height: 32,
                  width: 32,
                  color: Theme.of(context).iconTheme.color,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AutoSizeText(
                    'quick_calc_bf'
                        .tr(), // или другой ключ для кнопочного экрана
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    minFontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
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
          drawer: MainDrawer(
            currentScreen: 'quick_calc_bf',
            initialSpeciesList: selectedSpeciesList,
            initialSpeciesDensity: speciesDensity,
            initialLengthUnit: lengthUnit,
            initialDiameterUnit: diameterUnit,
            initialWeightUnit: weightUnit,
            initialSpeciesListBf: [], // или свой список для BF, если есть
            initialSpeciesDensityBf: {}, // или свою карту для BF, если есть
            initialLengthUnitBf: '', // или своё значение
            initialDiameterUnitBf: '', // или своё значение
            initialWeightUnitBf: '', // или своё значение
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: IconButton(
                      icon: Icon(
                        Icons.straighten,
                        color: selectedMethod == null
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5)
                            : Theme.of(context).iconTheme.color,
                      ),
// ...внутри build, в onPressed: () { ... } для IconButton с иконкой straighten...
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final methods = [
                              'Doyle Log Rule',
                              'Doyle Log Rule (table)',
                              'International 1/4-Inch Log Rule',
                              'International 1/4-Inch Log Rule (table)',
                              'Scribner Log Rule',
                              'Scribner Log Volume Table',
                            ];
                            return AlertDialog(
                              backgroundColor:
                                  Theme.of(context).dialogBackgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              title: Text('select_method'.tr()),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 300,
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 3,
                                  ),
                                  itemCount: methods.length,
                                  itemBuilder: (context, index) {
                                    final method = methods[index];
                                    final isSelected = selectedMethod == method;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedMethod = method;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green[100]
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.green, width: 2)
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            method.tr(), // Локализованный текст
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.green
                                                  : Colors.black,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.settings,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                      tooltip: 'settings'.tr(),
                                      onPressed: () async {
                                        if (AdsController().canUsePremium()) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              double localMoisture =
                                                  woodMoisture;
                                              double localPackageWeight =
                                                  packageWeight;
                                              bool localShowGrossWeightColumn =
                                                  showGrossWeightColumn;
                                              bool localShowNetWeightColumn =
                                                  showNetWeightColumn;
                                              bool localShowBarkVolumeColumn =
                                                  showBarkVolumeColumn;
                                              bool localShowWithBark =
                                                  showWithBark;
                                              return StatefulBuilder(
                                                builder:
                                                    (context, setStateDialog) {
                                                  return AlertDialog(
                                                    backgroundColor: Theme.of(
                                                            context)
                                                        .dialogBackgroundColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      side: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    title: Text(
                                                        'weight_pack_settings'
                                                            .tr()),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'moisture_label'
                                                                      .tr()),
                                                              Expanded(
                                                                child: Slider(
                                                                  value:
                                                                      localMoisture,
                                                                  min: 0,
                                                                  max: 100,
                                                                  divisions:
                                                                      100,
                                                                  label:
                                                                      '${localMoisture.toStringAsFixed(0)}%',
                                                                  onChanged: (v) =>
                                                                      setStateDialog(() =>
                                                                          localMoisture =
                                                                              v),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  '${localMoisture.toStringAsFixed(0)}%'),
                                                            ],
                                                          ),
                                                          TextFormField(
                                                            initialValue:
                                                                localPackageWeight
                                                                    .toString(),
                                                            decoration:
                                                                InputDecoration(
                                                                    labelText:
                                                                        'package_weight_label'
                                                                            .tr()),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onChanged: (v) =>
                                                                setStateDialog(
                                                                    () {
                                                              localPackageWeight =
                                                                  double.tryParse(
                                                                          v) ??
                                                                      0;
                                                            }),
                                                          ),
                                                          CheckboxListTile(
                                                            value:
                                                                localShowGrossWeightColumn,
                                                            onChanged: (v) =>
                                                                setStateDialog(() =>
                                                                    localShowGrossWeightColumn =
                                                                        v ??
                                                                            false),
                                                            title: Text(
                                                                'show_gross_weight_col'
                                                                    .tr()),
                                                            dense: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          CheckboxListTile(
                                                            value:
                                                                localShowNetWeightColumn,
                                                            onChanged: (v) =>
                                                                setStateDialog(() =>
                                                                    localShowNetWeightColumn =
                                                                        v ??
                                                                            false),
                                                            title: Text(
                                                                'show_net_weight_col'
                                                                    .tr()),
                                                            dense: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          CheckboxListTile(
                                                            value:
                                                                localShowBarkVolumeColumn,
                                                            onChanged: (v) =>
                                                                setStateDialog(() =>
                                                                    localShowBarkVolumeColumn =
                                                                        v ??
                                                                            false),
                                                            title: Text(
                                                                'show_bark_volume_col'
                                                                    .tr()),
                                                            dense: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            woodMoisture =
                                                                localMoisture;
                                                            packageWeight =
                                                                localPackageWeight;
                                                            showGrossWeightColumn =
                                                                localShowGrossWeightColumn;
                                                            showNetWeightColumn =
                                                                localShowNetWeightColumn;
                                                            showBarkVolumeColumn =
                                                                localShowBarkVolumeColumn;
                                                            showWithBark =
                                                                localShowWithBark;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('ok'.tr()),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                          AdsController().tryUsePremium();
                                        } else {
                                          final result =
                                              await showRewardedInfoDialog(
                                                  context);
                                          if (result == true) {
                                            AdsController()
                                                .showRewardedForPremium(() {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  double localMoisture =
                                                      woodMoisture;
                                                  double localPackageWeight =
                                                      packageWeight;
                                                  bool
                                                      localShowGrossWeightColumn =
                                                      showGrossWeightColumn;
                                                  bool
                                                      localShowNetWeightColumn =
                                                      showNetWeightColumn;
                                                  bool
                                                      localShowBarkVolumeColumn =
                                                      showBarkVolumeColumn;
                                                  bool localShowWithBark =
                                                      showWithBark;
                                                  return StatefulBuilder(
                                                    builder: (context,
                                                        setStateDialog) {
                                                      return AlertDialog(
                                                        backgroundColor: Theme
                                                                .of(context)
                                                            .dialogBackgroundColor,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                          side: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        title: Text(
                                                            'weight_pack_settings'
                                                                .tr()),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text('moisture_label'
                                                                      .tr()),
                                                                  Expanded(
                                                                    child:
                                                                        Slider(
                                                                      value:
                                                                          localMoisture,
                                                                      min: 0,
                                                                      max: 100,
                                                                      divisions:
                                                                          100,
                                                                      label:
                                                                          '${localMoisture.toStringAsFixed(0)}%',
                                                                      onChanged:
                                                                          (v) =>
                                                                              setStateDialog(() => localMoisture = v),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                      '${localMoisture.toStringAsFixed(0)}%'),
                                                                ],
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    localPackageWeight
                                                                        .toString(),
                                                                decoration: InputDecoration(
                                                                    labelText:
                                                                        'package_weight_label'
                                                                            .tr()),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                onChanged: (v) =>
                                                                    setStateDialog(
                                                                        () {
                                                                  localPackageWeight =
                                                                      double.tryParse(
                                                                              v) ??
                                                                          0;
                                                                }),
                                                              ),
                                                              CheckboxListTile(
                                                                value:
                                                                    localShowGrossWeightColumn,
                                                                onChanged: (v) =>
                                                                    setStateDialog(() =>
                                                                        localShowGrossWeightColumn =
                                                                            v ??
                                                                                false),
                                                                title: Text(
                                                                    'show_gross_weight_col'
                                                                        .tr()),
                                                                dense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                              CheckboxListTile(
                                                                value:
                                                                    localShowNetWeightColumn,
                                                                onChanged: (v) =>
                                                                    setStateDialog(() =>
                                                                        localShowNetWeightColumn =
                                                                            v ??
                                                                                false),
                                                                title: Text(
                                                                    'show_net_weight_col'
                                                                        .tr()),
                                                                dense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                              CheckboxListTile(
                                                                value:
                                                                    localShowBarkVolumeColumn,
                                                                onChanged: (v) =>
                                                                    setStateDialog(() =>
                                                                        localShowBarkVolumeColumn =
                                                                            v ??
                                                                                false),
                                                                title: Text(
                                                                    'show_bark_volume_col'
                                                                        .tr()),
                                                                dense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                woodMoisture =
                                                                    localMoisture;
                                                                packageWeight =
                                                                    localPackageWeight;
                                                                showGrossWeightColumn =
                                                                    localShowGrossWeightColumn;
                                                                showNetWeightColumn =
                                                                    localShowNetWeightColumn;
                                                                showBarkVolumeColumn =
                                                                    localShowBarkVolumeColumn;
                                                                showWithBark =
                                                                    localShowWithBark;
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text('ok'.tr()),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                              AdsController().tryUsePremium();
                                            });
                                          } else if (result == false) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => VipScreen()),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.park,
                          color: selectedSpecies == null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5)
                              : Theme.of(context).iconTheme.color,
                        ),
                        tooltip: selectedSpecies ?? 'select_species'.tr(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final speciesDropdownList = [
                                ...speciesList,
                              ];
                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).dialogBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                title: Text('select_species'.tr()),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 300,
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 3,
                                    ),
                                    itemCount: speciesDropdownList.length + 2,
                                    itemBuilder: (context, index) {
                                      if (index == speciesDropdownList.length) {
                                        // Кнопка "Добавить породу"
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _addCustomSpecies();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Icon(Icons.add,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color),
                                            ),
                                          ),
                                        );
                                      }
                                      if (index ==
                                          speciesDropdownList.length + 1) {
                                        // Кнопка "Фильтр"
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showSpeciesFilterDialog();
                                            setState(() {});
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                                child: Icon(Icons.filter_list,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color)),
                                          ),
                                        );
                                      }
                                      // ...внутри itemBuilder для speciesDropdownList...

                                      final species =
                                          speciesDropdownList[index];
                                      // Показываем иконку удаления только для кастомных пород
                                      final isCustom =
                                          customSpecies.contains(species);

                                      return Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedSpecies = species;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedSpecies == species
                                                        ? Colors.green[100]
                                                        : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border:
                                                    selectedSpecies == species
                                                        ? Border.all(
                                                            color: Colors.green,
                                                            width: 2)
                                                        : null,
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.park,
                                                        color:
                                                            selectedSpecies ==
                                                                    species
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    7,
                                                                    61,
                                                                    9)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    56,
                                                                    238,
                                                                    11)),
                                                    SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        species.tr(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color:
                                                              selectedSpecies ==
                                                                      species
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .black,
                                                          fontWeight:
                                                              selectedSpecies ==
                                                                      species
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isCustom)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                icon: Icon(Icons.close,
                                                    color: Colors.red,
                                                    size: 18),
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                tooltip: 'Удалить',
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    if (selectedSpecies ==
                                                        species)
                                                      selectedSpecies = null;
                                                    speciesList.remove(species);
                                                    speciesDensity
                                                        .remove(species);
                                                    customSpecies
                                                        .remove(species);
                                                  });
                                                },
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.sort,
                          color: selectedMethod == null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5)
                              : Theme.of(context).iconTheme.color,
                        ),
                        // ...внутри onPressed для IconButton с иконкой сортировки...
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).dialogBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                title: Text('select_grade'.tr()),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 300,
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 3,
                                    ),
                                    itemCount: gradeList.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == gradeList.length) {
                                        // Кнопка "Добавить сорт"
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _addCustomGrade();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                                child: Icon(Icons.sort,
                                                    color: selectedGrade == null
                                                        ? Theme.of(context)
                                                            .disabledColor
                                                        : Theme.of(context)
                                                            .iconTheme
                                                            .color)),
                                          ),
                                        );
                                      }
                                      final grade = gradeList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedGrade = grade;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: selectedGrade == grade
                                                ? Colors.green[100]
                                                : Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              grade.tr(),
                                              style: TextStyle(
                                                color: selectedGrade == grade
                                                    ? Colors.green
                                                    : Colors.black,
                                                fontWeight:
                                                    selectedGrade == grade
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.attach_money,
                          color: price == null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5)
                              : Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () async {
                          if (AdsController().canUsePremium()) {
                            // Открываем диалог ввода цены сразу
                            showDialog(
                              context: context,
                              builder: (context) {
                                String? localPrice = price?.toString();
                                String localCurrency = selectedCurrency;
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      backgroundColor: Theme.of(context)
                                          .dialogBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      title: Text('enter_price'.tr()),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              initialValue: localPrice,
                                              onChanged: (value) =>
                                                  localPrice = value,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          DropdownButton<String>(
                                            value: localCurrency,
                                            items: currencies
                                                .map((cur) => DropdownMenuItem(
                                                      value: cur,
                                                      child: Text(cur),
                                                    ))
                                                .toList(),
                                            onChanged: (val) {
                                              setStateDialog(() {
                                                localCurrency = val!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              price = double.tryParse(
                                                  localPrice ?? '');
                                              selectedCurrency = localCurrency;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text('ok'.tr()),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                            AdsController().tryUsePremium();
                          } else {
                            final result =
                                await showRewardedInfoDialog(context);
                            if (result == true) {
                              AdsController().showRewardedForPremium(() {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String? localPrice = price?.toString();
                                    String localCurrency = selectedCurrency;
                                    return StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        return AlertDialog(
                                          backgroundColor: Theme.of(context)
                                              .dialogBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 1.5,
                                            ),
                                          ),
                                          title: Text('enter_price'.tr()),
                                          content: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  initialValue: localPrice,
                                                  onChanged: (value) =>
                                                      localPrice = value,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              DropdownButton<String>(
                                                value: localCurrency,
                                                items: currencies
                                                    .map((cur) =>
                                                        DropdownMenuItem(
                                                          value: cur,
                                                          child: Text(cur),
                                                        ))
                                                    .toList(),
                                                onChanged: (val) {
                                                  setStateDialog(() {
                                                    localCurrency = val!;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  price = double.tryParse(
                                                      localPrice ?? '');
                                                  selectedCurrency =
                                                      localCurrency;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text('ok'.tr()),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                                AdsController().tryUsePremium();
                              });
                            } else if (result == false) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => VipScreen()),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(width: 8),
                    SizedBox(
                      width: 120, // уменьшенная ширина
                      child: _lengthInput(),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.settings,
                          color: Theme.of(context).iconTheme.color),
                      tooltip: 'units_settings'.tr(),
                      onPressed: () async {
                        String tempLengthUnit = lengthUnit;
                        String tempDiameterUnit = diameterUnit;
                        String tempWeightUnit = weightUnit;
                        bool tempShowMethodColumn = showMethodColumn;
                        bool tempShowSpeciesColumn = showSpeciesColumn;
                        bool tempShowGradeColumn = showGradeColumn;
                        bool tempShowDensityColumn = showDensityColumn;
                        bool tempShowPriceColumn = showPriceColumn;

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return AlertDialog(
                                  backgroundColor:
                                      Theme.of(context).dialogBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  title: Text('units_settings'.tr()),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButton<String>(
                                          value: tempLengthUnit,
                                          items: ['ft']
                                              .map((u) => DropdownMenuItem(
                                                  value: u,
                                                  child: Text(
                                                      'length_unit_$u'.tr())))
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null)
                                              setStateDialog(
                                                  () => tempLengthUnit = v);
                                          },
                                          hint: Text('length_unit'.tr()),
                                        ),
                                        DropdownButton<String>(
                                          value: tempDiameterUnit,
                                          items: ['in']
                                              .map((u) => DropdownMenuItem(
                                                  value: u,
                                                  child: Text(
                                                      'diameter_unit_$u'.tr())))
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null)
                                              setStateDialog(
                                                  () => tempDiameterUnit = v);
                                          },
                                          hint: Text('diameter_unit'.tr()),
                                        ),
                                        DropdownButton<String>(
                                          value: tempWeightUnit,
                                          items: ['lb', 'ton (US)', 'ton (UK)']
                                              .map((u) => DropdownMenuItem(
                                                  value: u,
                                                  child: Text(
                                                      'weight_unit_$u'.tr())))
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null)
                                              setStateDialog(
                                                  () => tempWeightUnit = v);
                                          },
                                          hint: Text('weight_unit'.tr()),
                                        ),
                                        Divider(),
                                        CheckboxListTile(
                                          value: tempShowMethodColumn,
                                          onChanged: (v) => setStateDialog(() =>
                                              tempShowMethodColumn = v ?? true),
                                          title: Text('show_method_col'.tr()),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        CheckboxListTile(
                                          value: tempShowSpeciesColumn,
                                          onChanged: (v) => setStateDialog(() =>
                                              tempShowSpeciesColumn =
                                                  v ?? true),
                                          title: Text('show_species_col'.tr()),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        CheckboxListTile(
                                          value: tempShowGradeColumn,
                                          onChanged: (v) => setStateDialog(() =>
                                              tempShowGradeColumn = v ?? true),
                                          title: Text('show_grade_col'.tr()),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        CheckboxListTile(
                                          value: tempShowPriceColumn,
                                          onChanged: (v) => setStateDialog(() =>
                                              tempShowPriceColumn = v ?? true),
                                          title: Text('show_sum_col'
                                              .tr()), // <-- добавьте такой ключ в локализацию
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        CheckboxListTile(
                                          value: tempShowPriceColumn,
                                          onChanged: (v) => setStateDialog(() =>
                                              tempShowPriceColumn = v ?? true),
                                          title: Text('show_price_col'.tr()),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _applyUnitChanges(
                                            newLengthUnit:
                                                tempLengthUnit != lengthUnit
                                                    ? tempLengthUnit
                                                    : null,
                                            newDiameterUnit:
                                                tempDiameterUnit != diameterUnit
                                                    ? tempDiameterUnit
                                                    : null,
                                          );
                                          showMethodColumn =
                                              tempShowMethodColumn;
                                          showSpeciesColumn =
                                              tempShowSpeciesColumn;
                                          showGradeColumn = tempShowGradeColumn;
                                          showPriceColumn = tempShowPriceColumn;
                                          showDensityColumn =
                                              tempShowDensityColumn;
                                          showPriceColumn = tempShowPriceColumn;
                                        });
                                        _saveUserUnits();
                                        Navigator.pop(context);
                                      },
                                      child: Text('ok'.tr()),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                IconButton(
                  icon: Icon(Icons.check_circle,
                      color: Theme.of(context).iconTheme.color, size: 40),
                  onPressed: () async {
                    await AdsController()
                        .showInterstitialIfNeeded(); // Показываем рекламу
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TableBfScreen(
                          tableData: tableData,
                          speciesList: speciesList,
                          methodList: methodList,
                          gradeList: gradeList,
                          speciesDensity: speciesDensity,
                          speciesMeta: speciesMeta,
                          packageWeight: packageWeight,
                          weightUnit: weightUnit,
                          onClear: _clearTable,
                          onSave: _saveTable,
                          onExportPDF: _exportPDF,
                          onExportExcel: _exportExcel,
                          onLoad: _loadTable,
                          showGrossWeightColumn: showGrossWeightColumn,
                          showNetWeightColumn: showNetWeightColumn,
                          showBarkVolumeColumn: showBarkVolumeColumn,
                          showMethodColumn: showMethodColumn,
                          showSpeciesColumn: showSpeciesColumn,
                          showGradeColumn: showGradeColumn,
                          showPriceColumn: showPriceColumn,
                          showDensityColumn: showDensityColumn,
                          lengthUnit: lengthUnit,
                          diameterUnit: diameterUnit,
                          selectedCurrency: selectedCurrency,
                          onEdit: (index, field, newValue) {
                            setState(() {
                              if (field == 'Длина' ||
                                  field == 'Диаметр' ||
                                  field == 'Количество' ||
                                  field == 'Цена за BF') {
                                final numValue = double.tryParse(
                                    newValue.replaceAll(',', '.'));
                                tableData[index][field] = numValue ?? 0.0;
                              } else if (field == 'Порода') {
                                tableData[index][field] = newValue;
                                tableData[index]['Плотность'] =
                                    speciesMeta.containsKey(newValue)
                                        ? speciesMeta[newValue]!.density ?? 50
                                        : (speciesDensity[newValue] ?? 50);
                              } else if (field == 'Плотность') {
                                final numValue = double.tryParse(
                                    newValue.replaceAll(',', '.'));
                                tableData[index][field] = numValue ?? 50;
                              } else {
                                tableData[index][field] = newValue;
                              }
                              recalcRowBf(
                                tableData[index],
                                speciesDensity,
                                speciesMeta,
                                packageWeight,
                                weightUnit,
                                lengthUnit,
                                diameterUnit,
                                woodMoisture,
                              );
                              _saveTable(auto: true);
                            });
                          },
                        ),
                      ),
                    );
                    setState(() {}); // Обновление состояния после возврата
                  },
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Минимальная ширина кнопки + отступы
                      const minButtonWidth = 80.0;
                      final crossAxisCount =
                          (constraints.maxWidth / minButtonWidth)
                              .floor()
                              .clamp(2, 6);

                      final diameters = isTableMethod()
                          ? getCurrentDiameters()
                          : [for (int d = 2; d <= 120; d += 2) d];

                      return GridView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: diameters.length,
                        itemBuilder: (context, index) {
                          final d = diameters[index];
                          return ElevatedButton(
                            onPressed:
                                (selectedMethod != null && length != null)
                                    ? () {
                                        HapticFeedback.heavyImpact();
                                        calculateAndAdd(d);
                                      }
                                    : null,
                            child: Text('$d'),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (tableData.isNotEmpty &&
                    (showNetWeightColumn ||
                        showGrossWeightColumn ||
                        showBarkVolumeColumn))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (showNetWeightColumn)
                              Text(
                                '${'netto_label'.tr()}: ${totalNet.toStringAsFixed(3)} $weightUnit',
                                style: TextStyle(fontSize: 16),
                              ),
                            if (showGrossWeightColumn)
                              Text(
                                '${'brutto_label'.tr()}: ${totalGross.toStringAsFixed(3)} $weightUnit',
                                style: TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                        if (showBarkVolumeColumn)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '${'bark_volume_label'.tr()}: ${totalWithBark.toStringAsFixed(3)}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('${'quantity_label'.tr()}: $totalCount',
                        style: TextStyle(fontSize: 16)),
                    Text(
                        '${'price_label'.tr()}: ${totalSum.toStringAsFixed(2)} $selectedCurrency',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.save,
                          color: Theme.of(context).colorScheme.primary),
                      onSelected: (value) {
                        if (value == 'save') _saveTable();
                        if (value == 'load') _loadTable();
                        if (value == 'pdf') {
                          if (AdsController().canUsePremium()) {
                            _exportPDF();
                            AdsController().tryUsePremium();
                          } else {
                            showRewardedInfoDialog(context).then((result) {
                              if (result == true) {
                                AdsController().showRewardedForPremium(() {
                                  _exportPDF();
                                  AdsController().tryUsePremium();
                                });
                              } else if (result == false) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => VipScreen()),
                                );
                              }
                            });
                            // Показываем диалог-призыв
                          }
                        }
                        if (value == 'excel') {
                          if (AdsController().canUsePremium()) {
                            _exportExcel();
                            AdsController().tryUsePremium();
                          } else {
                            showRewardedInfoDialog(context).then((result) {
                              if (result == true) {
                                AdsController().showRewardedForPremium(() {
                                  _exportExcel();
                                  AdsController().tryUsePremium();
                                });
                              } else if (result == false) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => VipScreen()),
                                );
                              }
                            });
                            // Показываем диалог-призыв
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'save',
                          child: Row(children: [
                            Icon(Icons.save,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary), // исправлено
                            SizedBox(width: 8),
                            Text('save_to_folder'.tr())
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'load',
                          child: Row(children: [
                            Icon(Icons.folder_open, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('load_from_folder'.tr())
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'pdf',
                          child: Row(children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red),
                            SizedBox(width: 8),
                            Text('export_pdf'.tr())
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'excel',
                          child: Row(children: [
                            Icon(Icons.table_chart, color: Colors.green),
                            SizedBox(width: 8),
                            Text('export_excel'.tr())
                          ]),
                        ),
                      ],
                    ),
                    Text(
                        '${'bf_volume_label'.tr()}: ${totalVolume.toStringAsFixed(3)}',
                        style: TextStyle(fontSize: 16)),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: _clearTable,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

class TableBfScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tableData;
  final List<String> speciesList;
  final List<String> methodList;
  final List<String> gradeList;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onExportPDF;
  final VoidCallback onExportExcel;
  final VoidCallback onLoad;
  final String lengthUnit;
  final String diameterUnit;
  final String weightUnit;
  final String selectedCurrency;
  final void Function(int, String, String) onEdit;
  final bool showGrossWeightColumn;
  final bool showNetWeightColumn;
  final bool showBarkVolumeColumn;
  final bool showMethodColumn;
  final bool showSpeciesColumn;
  final bool showGradeColumn;
  final bool showPriceColumn;
  final bool showDensityColumn;
  final Map<String, double> speciesDensity;
  final Map<String, meta_bf.SpeciesMeta> speciesMeta;
  final double packageWeight;

  const TableBfScreen({
    required this.tableData,
    required this.speciesList,
    required this.methodList,
    required this.gradeList,
    required this.onClear,
    required this.onSave,
    required this.onExportPDF,
    required this.onExportExcel,
    required this.onLoad,
    required this.onEdit,
    required this.lengthUnit, // Передаём единицы измерения длины
    required this.diameterUnit, // Передаём единицы измерения диаметра
    required this.weightUnit, // Передаём единицы измерения веса
    required this.selectedCurrency,
    required this.showGrossWeightColumn,
    required this.showNetWeightColumn,
    required this.showBarkVolumeColumn,
    required this.showMethodColumn,
    required this.showSpeciesColumn,
    required this.showGradeColumn,
    required this.showPriceColumn,
    required this.showDensityColumn,
    required this.speciesDensity,
    required this.speciesMeta,
    required this.packageWeight,
  });

  @override
  State<TableBfScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableBfScreen> {
  bool showMethodColumn = true;
  bool showSpeciesColumn = true;
  bool showGradeColumn = true;
  bool showPriceColumn = true;
  bool get showGrossWeightColumn => widget.showGrossWeightColumn;
  bool get showNetWeightColumn => widget.showNetWeightColumn;
  bool get showBarkVolumeColumn => widget.showBarkVolumeColumn;
  double volumeWithBark = 0.0;
  double grossWeight = 0.0;
  double netWeight = 0.0;
  double parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty || s == '-' || s.toLowerCase() == 'null') return 0.0;
      return double.tryParse(s.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  Future<bool?> showRewardedInfoDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text(
              'pro_or_video_title'.tr(),
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'pro_or_video_desc'.tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFD700),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('buy_pro_btn'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('watch_video_btn'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = widget.tableData.fold<int>(
      0,
      (sum, row) =>
          sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
    );
    final double totalVolume = widget.tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем']),
    );
    final double totalSum = widget.tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Итоговая цена']),
    );
    final double totalGross = widget.tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Брутто']),
    );
    final double totalNet = widget.tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Нетто']),
    );
    final double totalWithBark = widget.tableData.fold<double>(
      0,
      (sum, row) => sum + parseNum(row['Объем с корой']),
    );

    // ... остальной build ...
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/appbar_icon.png',
              height: 32,
              width: 32,
              color: Theme.of(context).iconTheme.color,
            ),
            SizedBox(width: 12),
            Expanded(
              child: AutoSizeText(
                'Total BF'.tr(), // или другой ключ для кнопочного экрана
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                minFontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Theme.of(context)
                        .colorScheme
                        .primary, // Цвет фона заголовка
                  ),
                  headingTextStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary, // Цвет текста заголовка
                    fontWeight: FontWeight.bold,
                  ),
                  dataRowColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.surface, // Цвет строк таблицы
                  ),
                  dataTextStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface, // Цвет текста строк
                  ),
                  columns: [
                    DataColumn(label: Text('№')),
                    if (widget.showMethodColumn)
                      DataColumn(label: Text('method_col'.tr())),
                    if (widget.showSpeciesColumn)
                      DataColumn(label: Text('species_col'.tr())),
                    if (widget.showGradeColumn)
                      DataColumn(label: Text('grade_col'.tr())),
                    DataColumn(
                        label: Text(
                            '${'length_col'.tr()} (${widget.lengthUnit})')),
                    DataColumn(
                        label: Text(
                            '${'diameter_col'.tr()} (${widget.diameterUnit})')),
                    DataColumn(label: Text('quantity_col'.tr())),
                    if (widget.showPriceColumn)
                      DataColumn(
                          label: Text(
                              '${'price_per_m3_col'.tr()} ${widget.selectedCurrency}')),
                    DataColumn(
                        label: Text(
                            '${'volume_col'.tr()} (${widget.lengthUnit}³)')),
                    if (widget.showPriceColumn)
                      DataColumn(
                          label: Text(
                              '${'sum_col'.tr()} (${widget.selectedCurrency})')),
                    if (showGrossWeightColumn)
                      DataColumn(
                          label: Text(
                              '${'gross_weight_col'.tr()} (${widget.weightUnit})')),
                    if (showNetWeightColumn)
                      DataColumn(
                          label: Text(
                              '${'net_weight_col'.tr()} (${widget.weightUnit})')),
                    if (showBarkVolumeColumn)
                      DataColumn(
                          label: Text(
                              '${'bark_volume_col'.tr()} (${widget.lengthUnit}³)')),
                  ],
                  rows: widget.tableData.asMap().entries.map((entry) {
                    int index = entry.key;
                    final row = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      if (widget.showMethodColumn)
                        DataCell(Text(
                          (row['Метод'] ?? '-').toString().tr(),
                        )),
                      DataCell(Text(
                        (row['Порода'] is String &&
                                widget.speciesList.contains(row['Порода']))
                            ? (row['Порода'] as String).tr()
                            : (row['Порода']?.toString() ?? '-'),
                      )),
                      if (widget.showGradeColumn)
                        DataCell(Text(
                          (row['Сорт'] is String &&
                                  widget.gradeList.contains(row['Сорт']))
                              ? (row['Сорт'] as String).tr()
                              : (row['Сорт']?.toString() ?? '-'),
                        )),
                      DataCell(
                        Text('${row['Длина'] ?? '-'}'),
                        showEditIcon: true,
                        onTap: () async {
                          final newValue = await _showEditDialog(context,
                              'length_col'.tr(), row['Длина']?.toString());
                          if (newValue != null)
                            widget.onEdit(index, 'Длина', newValue);
                          setState(() {});
                        },
                      ),
                      DataCell(
                        Text('${row['Диаметр'] ?? '-'}'),
                        showEditIcon: true,
                        onTap: () async {
                          final newValue = await _showEditDialog(context,
                              'diameter_col'.tr(), row['Диаметр']?.toString());
                          if (newValue != null)
                            widget.onEdit(index, 'Диаметр', newValue);
                          setState(() {});
                        },
                      ),
                      DataCell(
                        Text('${row['Количество'] ?? '-'}'),
                        showEditIcon: true,
                        onTap: () async {
                          final newValue = await _showEditDialog(
                              context,
                              'quantity_col'.tr(),
                              row['Количество']?.toString());
                          if (newValue != null)
                            widget.onEdit(index, 'Количество', newValue);
                          setState(() {});
                        },
                      ),
                      if (widget.showPriceColumn)
                        DataCell(
                          Text('${row['Цена за BF'] ?? '-'}'),
                          showEditIcon: true,
                          onTap: () async {
                            final newValue = await _showEditDialog(
                                context,
                                'price_col'.tr(),
                                row['Цена за BF']?.toString());
                            if (newValue != null)
                              widget.onEdit(index, 'Цена за BF', newValue);
                            setState(() {});
                          },
                        ),
                      DataCell(Text(row['Объем'] != null &&
                              row['Объем'].toString().isNotEmpty
                          ? parseNum(row['Объем']).toStringAsFixed(3)
                          : '-')),
                      if (widget.showPriceColumn)
                        DataCell(Text(
                          row['Итоговая цена'] != null
                              ? '${parseNum(row['Итоговая цена']).toStringAsFixed(2)} ${widget.selectedCurrency}'
                              : '-',
                        )),
                      if (widget.showGrossWeightColumn)
                        DataCell(Text(row['Брутто'] != null &&
                                row['Брутто'].toString().isNotEmpty
                            ? parseNum(row['Брутто']).toStringAsFixed(3)
                            : '-')),
                      if (widget.showNetWeightColumn)
                        DataCell(Text(row['Нетто'] != null &&
                                row['Нетто'].toString().isNotEmpty
                            ? parseNum(row['Нетто']).toStringAsFixed(3)
                            : '-')),
                      if (widget.showBarkVolumeColumn)
                        DataCell(Text(row['Объем с корой'] != null &&
                                row['Объем с корой'].toString().isNotEmpty
                            ? parseNum(row['Объем с корой']).toStringAsFixed(3)
                            : '-')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          if (widget.tableData.isNotEmpty &&
              (showNetWeightColumn ||
                  showGrossWeightColumn ||
                  showBarkVolumeColumn))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  if (showNetWeightColumn)
                    Text(
                      '${'netto_label'.tr()}: ${totalNet.toStringAsFixed(3)} ${widget.weightUnit}',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (showGrossWeightColumn)
                    Text(
                      '${'brutto_label'.tr()}: ${totalGross.toStringAsFixed(3)} ${widget.weightUnit}',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (showBarkVolumeColumn)
                    Text(
                      '${'bark_volume_label'.tr()} (${widget.lengthUnit}³): ${totalWithBark.toStringAsFixed(3)}',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          // ...после таблицы и итоговой строки...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('${'quantity_label'.tr()}: $totalCount',
                  style: TextStyle(fontSize: 16)),
              Text(
                  '${'price_label'.tr()}: ${totalSum.toStringAsFixed(2)} ${widget.selectedCurrency}',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          if (showBarkVolumeColumn)
            Text(
              '${'bark_volume_label'.tr()} (${widget.lengthUnit}³): ${totalWithBark.toStringAsFixed(3)}',
              style: TextStyle(fontSize: 16),
            ),

          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PopupMenuButton<String>(
                icon: Icon(Icons.save,
                    color: Theme.of(context).colorScheme.primary),
                onSelected: (value) {
                  if (value == 'save') widget.onSave();
                  if (value == 'load') widget.onLoad();
                  if (value == 'pdf') {
                    if (AdsController().canUsePremium()) {
                      widget.onExportPDF();
                      AdsController().tryUsePremium();
                    } else {
                      showRewardedInfoDialog(context).then((result) {
                        if (result == true) {
                          AdsController().showRewardedForPremium(() {
                            widget.onExportPDF();
                            AdsController().tryUsePremium();
                          });
                        } else if (result == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VipScreen()),
                          );
                        }
                      });
                    }
                  }
                  if (value == 'excel') {
                    if (AdsController().canUsePremium()) {
                      widget.onExportExcel();
                      AdsController().tryUsePremium();
                    } else {
                      showRewardedInfoDialog(context).then((result) {
                        if (result == true) {
                          AdsController().showRewardedForPremium(() {
                            widget.onExportExcel();
                            AdsController().tryUsePremium();
                          });
                        } else if (result == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VipScreen()),
                          );
                        }
                      }); // Показываем диалог-призыв
                    }
                  }
                  if (value == 'excel') {
                    if (AdsController().canUsePremium()) {
                      widget.onExportExcel();
                      AdsController().tryUsePremium();
                    } else {
                      showRewardedInfoDialog(context).then((result) {
                        if (result == true) {
                          AdsController().showRewardedForPremium(() {
                            widget.onExportExcel();
                            AdsController().tryUsePremium();
                          });
                        } else if (result == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VipScreen()),
                          );
                        }
                      }); // Показываем диалог-призыв
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'save',
                    child: Row(children: [
                      Icon(Icons.save,
                          color: Theme.of(context)
                              .colorScheme
                              .primary), // исправлено
                      SizedBox(width: 8),
                      Text('save_to_folder'.tr())
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'load',
                    child: Row(children: [
                      Icon(Icons.folder_open, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('load_from_folder'.tr())
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'pdf',
                    child: Row(children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 8),
                      Text('export_pdf'.tr())
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'excel',
                    child: Row(children: [
                      Icon(Icons.table_chart, color: Colors.green),
                      SizedBox(width: 8),
                      Text('export_excel'.tr())
                    ]),
                  ),
                ],
              ),
              Text(
                  '${'volume_col'.tr()} (${widget.lengthUnit}³): ${totalVolume.toStringAsFixed(3)}',
                  style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  widget.onClear();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _showEditDialog(
      BuildContext context, String field, String? currentValue) async {
    String? newValue = currentValue;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          title: Text('${'edit_value'.tr()} $field'),
          content: TextFormField(
            initialValue: currentValue ?? '',
            onChanged: (value) {
              newValue = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, newValue),
              child: Text('ok'.tr()),
            ),
          ],
        );
      },
    );
  }
}
