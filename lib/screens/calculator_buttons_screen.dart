import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import '../data/species_meta.dart' as meta;
import '../widgets/GOST_2708_75_table.dart';
import '../widgets/ISO_4480_83__table.dart';
import '../widgets/jasTable.dart';
import '../utlits/recalcRow.dart';
import '../ads_controller.dart';
import '../screens/vip.dart';
import '../widgets/main_drawer.dart';
import 'package:auto_size_text/auto_size_text.dart';

const Map<String, String> methodMap = {
  'ГОСТ 2708-75': 'GOST_2708_75',
  'ISO_4480_83': 'ISO_4480_83',
  'Неллера (х0.785)': 'neller',
  'Неллера (упрощённая)': 'neller_simple',
  'Формула цилиндра (формула)': 'cylinder_formula',
  'Среднеарифметический диаметр (формула)': 'mean_diameter_formula',
  'Смалиана (формула)': 'smalian_formula',
  'Губера (формула)': 'huber_formula',
  'Ньютона (формула)': 'newton_formula',
  'JAS Scale (формула)': 'jas_formula',
  'JAS Scale (таблица)': 'jas_table',
};

class CalculatorButtonsScreen extends StatefulWidget {
  final List<String> initialSpeciesList;
  final Map<String, double> initialSpeciesDensity;
  final String initialLengthUnit;
  final String initialDiameterUnit;
  final String initialWeightUnit;
  final bool showGrossWeightColumn;
  final bool showNetWeightColumn;
  final bool showBarkVolumeColumn;

  const CalculatorButtonsScreen({
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
  _CalculatorButtonsScreenState createState() =>
      _CalculatorButtonsScreenState();
}

class _CalculatorButtonsScreenState extends State<CalculatorButtonsScreen> {
  // Пользовательские настройки
  late List<String> speciesList;
  late Map<String, double> speciesDensity;

  late String lengthUnit;
  late String diameterUnit;
  late String weightUnit;
  late final Map<String, meta.SpeciesMeta> speciesMeta;

  final List<String> lengthUnits = ['м', 'см'];
  final List<String> diameterUnits = ['см', 'мм'];
  final List<String> volumeUnits = [
    'м³',
  ];
  final List<String> weightUnits = ['кг', 'т'];

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

  List<Map<String, dynamic>> tableData = [];
  List<int> get diameters {
    if (diameterUnit == 'мм') {
      return List.generate(60, (i) => (2 + i * 2) * 10);
    } else {
      return List.generate(60, (i) => 2 + i * 2);
    }
  }

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

  String selectedCurrency = 'USD';

  // Для отображения столбцов
  bool showMethodColumn = true;
  bool showSpeciesColumn = true;
  bool showGradeColumn = true;
  bool showDensityColumn = true;
  bool showPriceColumn = true;
  bool showD2 = false;
  bool showDMiddle = false;
  bool showTotalPriceColumn = true;
  // Для чекбоксов веса и объема с корой
  bool showWithBark = false;
  double woodMoisture = 20.0; // влажность, если нужно
  double packageWeight = 0.0; // вес упаковки, если нужно
  double volumeWithBark = 0.0;

  @override
  void initState() {
    super.initState();
    speciesList = List<String>.from(widget.initialSpeciesList);
    speciesDensity = Map<String, double>.from(widget.initialSpeciesDensity);
    lengthUnit = widget.initialLengthUnit;
    diameterUnit = widget.initialDiameterUnit;
    weightUnit = widget.initialWeightUnit;
    selectedSpeciesList = List<String>.from(speciesList);

    speciesMeta = meta.speciesMeta;

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

  double volumeNeller(double diameter, double length) {
    const double pi = 3.1416;
    return (pi / 4) * diameter * diameter * length * 0.785;
  }

// --- Вспомогательные функции для единиц ---
  double toMeters(double value, String unit) {
    if (unit == 'м') return value; // Уже в метрах
    if (unit == 'см') return value / 100; // Преобразуем сантиметры в метры
    if (unit == 'мм') return value / 1000; // Преобразуем миллиметры в метры
    throw ArgumentError('Неизвестная единица измерения: $unit');
  }

  double toCentimeters(double value, String unit) {
    if (unit == 'м') return value * 100; // Преобразуем метры в сантиметры
    if (unit == 'см') return value; // Уже в сантиметрах
    if (unit == 'мм') return value / 10; // Преобразуем миллиметры в сантиметры
    throw ArgumentError('Неизвестная единица измерения: $unit');
  }

  double toMillimeters(double value, String unit) {
    if (unit == 'м') return value * 1000; // Преобразуем метры в миллиметры
    if (unit == 'см') return value * 10; // Преобразуем сантиметры в миллиметры
    if (unit == 'мм') return value; // Уже в миллиметрах
    throw ArgumentError('Неизвестная единица измерения: $unit');
  }

  double toKg(double value, String unit) {
    if (unit == 'кг') return value;
    if (unit == 'т') return value * 1000;
    return value;
  }

  double fromKg(double value, String unit) {
    if (unit == 'кг') return value;
    if (unit == 'т') return value / 1000;
    return value;
  }

// --- Основная функция добавления строки ---
  void calculateAndAdd(int diameterRaw) {
    if (length == null || selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите корректные данные для расчета'.tr())),
      );
      return;
    }

    // Преобразуем длину в метры и диаметр в сантиметры
    double lengthMeters = toMeters(length!, lengthUnit); // Длина в метрах
    int diameterCM = (toCentimeters(diameterRaw.toDouble(), diameterUnit))
        .round(); // Диаметр в сантиметрах

    int qty = quantity ?? 1;
    double oneVol = 0.0;

    // --- Расчёт объёма по методу ---
    if (selectedMethod == 'GOST_2708_75') {
      String lengthKey = lengthMeters.toStringAsFixed(1); // Длина в метрах
      print('GOST ключ длины: $lengthKey, ключ диаметра: $diameterCM');
      print('GOST таблица: ${GOST_2708_75_TABLE}');
      oneVol = GOST_2708_75_TABLE[lengthKey]?[diameterCM] ?? 0.0;
      print('GOST значение объема: $oneVol');
    } else if (selectedMethod == 'ISO_4480_83') {
      String lengthKey = lengthMeters.toStringAsFixed(1); // Длина в метрах
      print('ISO ключ длины: $lengthKey, ключ диаметра: $diameterCM');
      print('ISO таблица: ${ISO_4480_83_TABLE}');
      oneVol = ISO_4480_83_TABLE[lengthKey]?[diameterCM] ?? 0.0;
      print('ISO значение объема: $oneVol');
    } else if (selectedMethod == 'jas_formula') {
      double dCm = diameterCM.toDouble(); // Диаметр в сантиметрах
      oneVol = (dCm * dCm * lengthMeters) / 10000; // Формула JAS
      print('JAS формула объем: $oneVol');
    } else if (selectedMethod == 'jas_table') {
      double dCm = diameterCM.toDouble(); // Диаметр в сантиметрах
      double jasDiameter =
          roundDiameterForJAS(dCm); // Округляем диаметр для JAS
      double jas = (jasDiameter * jasDiameter * lengthMeters) / 10000;

      // Пытаемся найти коэффициент для выбранной породы
      double? coef = getJasCoef(
        lengthMeters,
        jasDiameter,
        species: selectedSpecies ?? 'radiata_pine',
        density: selectedJasDensityRange ?? '0.8-1.19',
      );

      // Если не найдено — пробуем для дефолтной породы
      if (coef == null || coef <= 0) {
        coef = getJasCoef(
          lengthMeters,
          jasDiameter,
          species: 'radiata_pine',
          density: selectedJasDensityRange ?? '0.8-1.19',
        );
      }

      if (coef != null && coef > 0) {
        oneVol = jas / coef;
      } else {
        oneVol = 0.0;
      }
      print('JAS таблица объем: $oneVol');
    } else if (selectedMethod == 'neller') {
      double dCm = diameterCM.toDouble(); // диаметр в сантиметрах!
      oneVol = (3.14159 * dCm * dCm * 0.785 / 40000) * lengthMeters;
    } else if (selectedMethod == 'neller_simple') {
      double dCm = diameterCM.toDouble();
      oneVol = (3.14159 * dCm * dCm / 40000) * lengthMeters;
    } else if (selectedMethod == 'cylinder_formula') {
      oneVol = 3.14159 *
          (diameterCM / 200.0) *
          (diameterCM / 200.0) *
          lengthMeters; // Диаметр в метрах
    } else if (selectedMethod == 'mean_diameter_formula') {
      double d2 = diameterCM / 100.0; // Диаметр в метрах
      oneVol = (3.14159 / 4) *
          ((diameterCM / 100.0) * (diameterCM / 100.0) +
              (diameterCM / 100.0) * d2 +
              d2 * d2) *
          lengthMeters;
    } else if (selectedMethod == 'smalian_formula') {
      double d2 = diameterCM / 100.0; // Диаметр в метрах
      oneVol = (3.14159 / 4) *
          lengthMeters *
          ((diameterCM / 100.0) * (diameterCM / 100.0) + d2 * d2) /
          2;
    } else if (selectedMethod == 'huber_formula') {
      double dMiddle = diameterCM / 100.0; // Средний диаметр в метрах
      oneVol = (3.14159 / 4) * dMiddle * dMiddle * lengthMeters;
    } else if (selectedMethod == 'newton_formula') {
      double dMiddle = diameterCM / 100.0; // Средний диаметр в метрах
      oneVol = (3.14159 * lengthMeters / 24) *
          ((diameterCM / 100.0) * (diameterCM / 100.0) +
              4 * dMiddle * dMiddle +
              (diameterCM / 100.0) * (diameterCM / 100.0));
    }

    double volumeLocal = oneVol * qty;
    double totalPriceLocal = volumeLocal * (price ?? 0);

    print('Рассчитанный объем: $volumeLocal');
    print('Рассчитанная цена: $totalPriceLocal');

    setState(() {
      final newRow = {
        'Метод': selectedMethod,
        'Порода': selectedSpecies ?? '',
        'Сорт': selectedGrade ?? '',
        'Длина': length,
        'Диаметр': diameterRaw,
        'Количество': qty,
        'Цена за м³': price ?? 0,
        'Объем': volumeLocal,
        'Итоговая цена': totalPriceLocal,
        'Плотность':
            selectedSpecies != null && speciesMeta.containsKey(selectedSpecies)
                ? speciesMeta[selectedSpecies]!.density ?? 600
                : (speciesDensity[selectedSpecies] ?? 600),
      };
      recalcRow(
        newRow,
        speciesDensity,
        speciesMeta,
        packageWeight,
        weightUnit,
        lengthUnit,
        diameterUnit,
        woodMoisture,
      );
      tableData.add(newRow);
      grossWeight = parseNum(newRow['Брутто']);
      netWeight = parseNum(newRow['Нетто']);
      volumeWithBark = parseNum(newRow['Объем с корой']);
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

  Future<Directory> getButtonsTablesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/tables/mm');
    if (!await tablesDir.exists()) {
      await tablesDir.create(recursive: true);
    }
    return tablesDir;
  }

  Future<void> _saveTable({bool auto = false}) async {
    final dir = await getButtonsTablesDirectory();

    String fileName;
    if (auto) {
      final now = DateTime.now();
      final dateStr =
          '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}';
      fileName = 'cb_mm_data_${dateStr}_$timeStr.csv';
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

    // Используйте ваши флаги для отображения колонок:
    // Например:
    // bool showMethodColumn = ...;
    // bool showSpeciesColumn = ...;
    // и т.д.

    final headers = [
      if (showMethodColumn) 'Метод',
      if (showSpeciesColumn) 'Порода',
      if (showGradeColumn) 'Сорт',
      'Длина',
      'Диаметр',
      if (showD2) 'd2',
      if (showDMiddle) 'dMiddle',
      'Количество',
      if (showPriceColumn) 'Цена за м³',
      'Объем',
      if (showTotalPriceColumn) 'Итоговая цена',
      if (showGrossWeightColumn) 'Брутто',
      if (showNetWeightColumn) 'Нетто',
      if (showBarkVolumeColumn) 'Объем с корой',
    ];

    final csvRows = <String>[];
    csvRows.add(headers.join(','));
    for (final row in tableData) {
      csvRows.add([
        if (showMethodColumn) row['Метод'] ?? '',
        if (showSpeciesColumn) row['Порода'] ?? '',
        if (showGradeColumn) row['Сорт'] ?? '',
        row['Длина'] ?? '',
        row['Диаметр'] ?? '',
        if (showD2) row['d2']?.toString() ?? '',
        if (showDMiddle) row['dMiddle']?.toString() ?? '',
        row['Количество']?.toString() ?? '',
        if (showPriceColumn) row['Цена за м³']?.toString() ?? '',
        row['Объем'] != null ? parseNum(row['Объем']).toStringAsFixed(3) : '',
        if (showTotalPriceColumn)
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
    final dir = await getButtonsTablesDirectory();
    // Только файлы с cb_mm_data и .csv
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
      tableData = lines.skip(1).map((line) {
        final values = line.split(',');
        final map = <String, dynamic>{};
        for (int i = 0; i < headers.length && i < values.length; i++) {
          map[headers[i]] = values[i];
        }
        recalcRow(
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
    });
    if (!auto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('load_success'.tr(args: [file.uri.pathSegments.last]))),
      );
    }
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
          row['Цена за м³'] != null
              ? parseNum(row['Цена за м³']).toStringAsFixed(2)
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
          row['Цена за м³'] != null
              ? parseNum(row['Цена за м³']).toStringAsFixed(2)
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
  } // ...внутри _CalculatorButtonsScreenState...

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
                                    // ...existing code...
                                    Text(
                                      '(${'bark'.tr()}: +${(speciesMeta[s]!.barkCorrection! * 100).round()}%)',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.green),
                                    ),
                                    // ...existing code...
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
      if (newLengthUnit != null && length != null) {
        if (lengthUnit == 'см') length = length! / 100;
        if (lengthUnit == 'мм') length = length! / 1000;
        if (newLengthUnit == 'см') length = length! * 100;
        if (newLengthUnit == 'мм') length = length! * 1000;
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
      double density = 600; // Значение по умолчанию
      if (selectedSpecies != null &&
          speciesDensity.containsKey(selectedSpecies)) {
        density = speciesDensity[selectedSpecies]!;
      }
      setState(() {
        grossWeight =
            volume * density * (1 + woodMoisture / 100) + packageWeight;
        netWeight = volume * density * (1 + woodMoisture / 100);
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
      lengthUnit = prefs.getString('selectedLengthUnit') ?? 'м';
      diameterUnit = prefs.getString('selectedDiameterUnit') ?? 'см';
      weightUnit = prefs.getString('selectedWeightUnit') ?? 'кг';
    });
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
// Локальные переменные для настроек внутри диалога

    return WillPopScope(
        onWillPop: () async {
          await AdsController().showInterstitialIfNeeded();
          return true;
        },
        child: Scaffold(
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor, //верхний цвет
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  await AdsController().showInterstitialIfNeeded();
                  Scaffold.of(context).openDrawer();
                },
              ),
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
                    'quick_calc'.tr(), // или другой ключ для кнопочного экрана
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
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
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
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor, //фон
          ),
          drawer: MainDrawer(
            currentScreen: 'quick_calc',
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final methods = [
                              'ГОСТ 2708-75',
                              'ISO_4480_83',
                              'Неллера (х0.785)',
                              'Неллера (упрощённая)',
                              'Формула цилиндра (формула)',
                              'Губера (формула)',
                              'JAS Scale (формула)',
                              'JAS Scale (таблица)',
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
                                    final isSelected =
                                        selectedMethod == methodMap[method];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedMethod =
                                              methodMap[method] ?? method;
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
                                          // Показываем настройки сразу
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
                                    )
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
                          Icons.nature,
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
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1.5,
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
                          color: selectedGrade == null
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
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1.5,
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
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'length_label'.tr() + ' ($lengthUnit)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            length = double.tryParse(value);
                          });
                        },
                      ),
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
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  title: Text('units_settings'.tr()),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButton<String>(
                                          value: tempLengthUnit,
                                          items: ['м', 'см', 'мм']
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
                                          items: ['мм', 'см']
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
                                          items: ['кг', 'т']
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
                        builder: (context) => TableScreen(
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
                                  field == 'Цена за м³') {
                                final numValue = double.tryParse(
                                    newValue.replaceAll(',', '.'));
                                tableData[index][field] = numValue ?? 0.0;
                              } else if (field == 'Порода') {
                                tableData[index][field] = newValue;
                                tableData[index]['Плотность'] =
                                    speciesMeta.containsKey(newValue)
                                        ? speciesMeta[newValue]!.density ?? 600
                                        : (speciesDensity[newValue] ?? 600);
                              } else if (field == 'Плотность') {
                                final numValue = double.tryParse(
                                    newValue.replaceAll(',', '.'));
                                tableData[index][field] = numValue ?? 600;
                              } else {
                                tableData[index][field] = newValue;
                              }
                              recalcRow(
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
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const minButtonWidth = 80.0;
                      final crossAxisCount =
                          (constraints.maxWidth / minButtonWidth)
                              .floor()
                              .clamp(2, 6);

                      final dList = this.diameters;

                      return GridView.builder(
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
                if (totalVolume > 0 &&
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
                    Text('${'total_count'.tr()}: $totalCount',
                        style: TextStyle(fontSize: 16)),
                    Text(
                        '${'total_sum'.tr()}: ${totalSum.toStringAsFixed(2)} $selectedCurrency',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.save, color: Colors.green),
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
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'save',
                          child: Row(children: [
                            Icon(Icons.save, color: Colors.green),
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
                        '${'volume_col'.tr()} ($lengthUnit³): ${totalVolume.toStringAsFixed(3)}',
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

class TableScreen extends StatefulWidget {
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
  final Map<String, meta.SpeciesMeta> speciesMeta;
  final double packageWeight;

  const TableScreen({
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
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
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
                'Total m³'.tr(), // или другой ключ для кнопочного экрана
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
                          methodMap.entries
                              .firstWhere(
                                (e) => e.value == row['Метод'],
                                orElse: () => const MapEntry('-', '-'),
                              )
                              .key
                              .tr(),
                        )),
                      if (widget.showSpeciesColumn)
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
                          Text('${row['Цена за м³'] ?? '-'}'),
                          showEditIcon: true,
                          onTap: () async {
                            final newValue = await _showEditDialog(
                                context,
                                'price_col'.tr(),
                                row['Цена за м³']?.toString());
                            if (newValue != null)
                              widget.onEdit(index, 'Цена за м³', newValue);
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
                              ? parseNum(row['Итоговая цена'])
                                  .toStringAsFixed(2)
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
          if (totalVolume > 0 &&
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
              Text('${'total_count'.tr()}: $totalCount',
                  style: TextStyle(fontSize: 16)),
              Text(
                  '${'total_sum'.tr()}: ${totalSum.toStringAsFixed(2)} ${widget.selectedCurrency}',
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
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'save',
                    child: Row(children: [
                      Icon(Icons.save, color: Colors.green),
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
