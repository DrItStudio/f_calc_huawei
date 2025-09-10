import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // <--- добавьте эту строку
import '../utlits/file_saver.dart';
import '../widgets/ISO_4480_83__table.dart';
import '../helpers/storage_permission_helper.dart';
import '../widgets/GOST_2708_75_table.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/species_data.dart'; // Импортируем данные пород древесины
import '../data/species_density.dart';
import '../data/species_meta.dart'; // speciesMeta
import '../widgets/jasTable.dart';
import '../ads_controller.dart'; // filepath: d:\Work\Flutte_dart\F_C\f_calc\lib\widgets\jasTable.dart
import '../screens/vip.dart';
import '../widgets/main_drawer.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CalculatorManualScreen extends StatefulWidget {
  @override
  _CalculatorManualScreenState createState() => _CalculatorManualScreenState();
}

class _CalculatorManualScreenState extends State<CalculatorManualScreen> {
  String? selectedMethod;
  String? selectedSpecies;
  String? selectedGrade;
  String? selectedJasSpecies;
  String? selectedJasLengthRange;
  String? selectedJasDiameterRange;
  String? selectedJasDensityRange;

  double? length;
  double? diameter;
  int? quantity;
  double? price;
  double volume = 0;
  double totalPrice = 0;
  double totalVolume = 0;
  bool diameterInMm = true;
  double volumeWithBark = 0.0; // Объём с корой
  bool showWithBark = false;
  double? diameter2;
  double? diameterMiddle;
  double totalSum = 0;
  int totalCount = 0;
  double woodMoisture = 20.0;
  double packageWeight = 0.0;
  bool grossWithBark = true;
  bool showGrossWeightColumn = false;
  bool showNetWeightColumn = false;
  bool showBarkVolumeColumn = false;
  bool showMethodColumn = true;
  bool showSpeciesColumn = true;
  bool showGradeColumn = true;
  bool showDensityColumn = true;
  bool showPriceColumn = true;
  bool showTotalPriceColumn = true;

  List<Map<String, dynamic>> tableData = [];
  List<String> gradeList = ['1', '2', '3'];
  List<String> customSpecies = [];
  List<String> selectedSpeciesList = [];
  final List<String> lengthUnits = ['м', 'см'];
  final List<String> diameterUnits = ['см', 'мм'];
  final List<String> volumeUnits = [
    'м³',
  ];
  final List<String> weightUnits = ['кг', 'т'];

  String lengthUnit = 'м'; // 'м', 'см', 'мм'
  String diameterUnit = 'мм'; // 'мм', 'см'
  String weightUnit = 'кг'; // 'кг', 'т'

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
    'CZK', // Чешская крона
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

  @override
  void initState() {
    super.initState();
    _loadCustomSpecies();
    _loadGradeList();
    _loadTableFromAppFolderAuto();
    _initSpeciesListByRegion('UA');
    _loadSelectedSpeciesList();
    _loadUserUnits();
  }

  void _initSpeciesListByRegion(String region) {
    final regionSpecies = speciesMeta.entries
        .where((e) => e.value.countries.contains(region))
        .map((e) => e.key)
        .toList();
    setState(() {
      selectedSpeciesList = regionSpecies;
      selectedSpecies =
          selectedSpeciesList.isNotEmpty ? selectedSpeciesList.first : null;
    });
  }

//реклама
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
            SizedBox(width: 8),
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

  Future<void> _loadSelectedSpeciesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList('selectedSpeciesList');
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        selectedSpeciesList = saved;
        selectedSpecies = selectedSpeciesList.first;
      });
    } else {
      _initSpeciesListByRegion('UA');
    }
  }

  Future<String?> _editCellDialog(
      BuildContext context, String initialValue) async {
    TextEditingController controller =
        TextEditingController(text: initialValue);
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
          title: Text('edit_value'.tr()),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('ok'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('cancel'.tr()),
            ),
          ],
        );
      },
    );
  }

  // ...existing code...

  String _weightUnitTr(BuildContext context) {
    switch (weightUnit) {
      case 'кг':
        return 'кг'.tr();
      case 'т':
        return 'т'.tr();
      default:
        return weightUnit.tr();
    }
  }

  Future<void> _exportToPDF({PdfPageFormat? pageFormat}) async {
    try {
      final showD2 = tableData.any((row) =>
          row['Метод'] != null &&
          (row['Метод'].toString().startsWith('Среднеарифметический диаметр') ||
              row['Метод'].toString().startsWith('Смалиана') ||
              row['Метод'].toString().startsWith('Ньютона')));
      final showDMiddle = tableData.any((row) =>
          row['Метод'] != null &&
          row['Метод'].toString().startsWith('Ньютона'));

      int totalCount = tableData.fold<int>(
        0,
        (sum, row) =>
            sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
      );
      double totalSum = tableData.fold<double>(
        0,
        (sum, row) =>
            sum +
            (double.tryParse(row['Итоговая цена']?.toString() ?? '0') ?? 0),
      );
      double totalVolume = tableData.fold<double>(
        0,
        (sum, row) =>
            sum + (double.tryParse(row['Объем']?.toString() ?? '0') ?? 0),
      );

      // Итоговые веса и объем с корой
      double totalNettoWeight = 0;
      double totalBruttoWeight = 0;
      double totalVolumeWithBark = 0;
      for (final row in tableData) {
        double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
        double rowDensity = 600;
        if (row['Порода'] != null &&
            speciesDensity.containsKey(row['Порода'])) {
          rowDensity = speciesDensity[row['Порода']]!;
        }
        double barkPercent = 0.0;
        if (row['Порода'] != null && speciesData.containsKey(row['Порода'])) {
          barkPercent = speciesData[row['Порода']] ?? 0.0;
        }
        double rowVolumeWithBark = rowVolume * (1 + barkPercent);
        double rowMoistureCoef = 1 + (woodMoisture / 100);

        totalNettoWeight += rowVolume * rowDensity * rowMoistureCoef;
        totalBruttoWeight +=
            rowVolumeWithBark * rowDensity * rowMoistureCoef + packageWeight;
        totalVolumeWithBark += rowVolumeWithBark;
      }
      final netWeightValue =
          weightUnit == 'т' ? totalNettoWeight / 1000 : totalNettoWeight;
      final grossWeightValue =
          weightUnit == 'т' ? totalBruttoWeight / 1000 : totalBruttoWeight;
      final weightSuffix = weightUnit == 'т' ? 'т' : 'кг';

      final List<String> exportHeaders = [
        '№',
        if (showMethodColumn) 'method_col'.tr(),
        if (showSpeciesColumn) 'species_col'.tr(),
        if (showGradeColumn) 'grade_col'.tr(),
        'length_col'.tr() + ' ($lengthUnit)',
        'diameter_col'.tr() + ' ($diameterUnit)',
        if (showD2) 'd2 ($diameterUnit)',
        if (showDMiddle) '${'dMiddle'.tr()} ($diameterUnit)',
        'quantity_col'.tr(),
        if (showPriceColumn) 'price_per_m3_col'.tr() + ' $selectedCurrency',
        'volume_col'.tr(),
        if (showTotalPriceColumn)
          'total_price_col'.tr() +
              ' $selectedCurrency', // <-- только если включено!
        if (showGrossWeightColumn)
          'brutto_label'.tr() + ' (${_weightUnitTr(context)})',
        if (showNetWeightColumn)
          'netto_label'.tr() + ' (${_weightUnitTr(context)})',
        if (showBarkVolumeColumn) 'bark_volume_label'.tr(),
      ];

      final exportData = [
        ...tableData.asMap().entries.map((entry) {
          int index = entry.key;
          final row = entry.value;
          double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
          double rowDensity = 600;
          if (row['Порода'] != null &&
              speciesDensity.containsKey(row['Порода'])) {
            rowDensity = speciesDensity[row['Порода']]!;
          }
          double barkPercent = 0.0;
          if (row['Порода'] != null && speciesData.containsKey(row['Порода'])) {
            barkPercent = speciesData[row['Порода']] ?? 0.0;
          }
          double rowVolumeWithBark = rowVolume * (1 + barkPercent);
          double rowMoistureCoef = 1 + (woodMoisture / 100);
          double rowGrossWeight = (grossWithBark && rowVolumeWithBark > 0
                      ? rowVolumeWithBark
                      : rowVolume) *
                  rowDensity *
                  rowMoistureCoef +
              packageWeight;
          double rowNetWeight = rowVolume * rowDensity * rowMoistureCoef;

          final rowGrossWeightDisplay = weightUnit == 'т'
              ? (rowGrossWeight / 1000).toStringAsFixed(3)
              : rowGrossWeight.toStringAsFixed(1);
          final rowNetWeightDisplay = weightUnit == 'т'
              ? (rowNetWeight / 1000).toStringAsFixed(3)
              : rowNetWeight.toStringAsFixed(1);

          return [
            (index + 1).toString(),
            if (showMethodColumn) row['Метод'] ?? '',
            if (showSpeciesColumn) getSpeciesDisplayName(row['Порода']),
            if (showGradeColumn) row['Сорт'] ?? '',
            row['Длина']?.toString() ?? '',
            row['Диаметр']?.toString() ?? '',
            if (showD2) row['d2']?.toString() ?? '',
            if (showDMiddle) row['dMiddle']?.toString() ?? '',
            row['Количество']?.toString() ?? '',
            if (showPriceColumn) row['Цена за м³']?.toString() ?? '',
            row['Объем'] ?? '',
            if (showTotalPriceColumn)
              row['Итоговая цена']?.toString() ??
                  '', // <-- только если включено!
            if (showGrossWeightColumn) rowGrossWeightDisplay,
            if (showNetWeightColumn) rowNetWeightDisplay,
            if (showBarkVolumeColumn) rowVolumeWithBark.toStringAsFixed(3),
          ];
        }),
        // Итоговая строка по количеству, объему, сумме
        [
          'total'.tr(),
          if (showMethodColumn) '',
          if (showSpeciesColumn) '',
          if (showGradeColumn) '',
          '',
          '',
          if (showD2) '',
          if (showDMiddle) '',
          totalCount.toString(),
          if (showPriceColumn) '',
          totalVolume.toStringAsFixed(3),
          totalSum.toStringAsFixed(2),
          if (showGrossWeightColumn) '',
          if (showNetWeightColumn) '',
          if (showBarkVolumeColumn) '',
        ],
        // Итоговая строка по объему с корой, нетто, брутто
        [
          '',
          for (int i = 1; i < exportHeaders.length; i++)
            i == exportHeaders.length - 1 && showBarkVolumeColumn
                ? '${'bark_volume_label'.tr()}: ${totalVolumeWithBark.toStringAsFixed(3)}'
                : i == exportHeaders.length - 2 && showNetWeightColumn
                    ? '${'netto_label'.tr()}: ${netWeightValue.toStringAsFixed(3)} $weightSuffix'
                    : i ==
                                exportHeaders.length -
                                    (showBarkVolumeColumn ? 3 : 2) &&
                            showGrossWeightColumn
                        ? '${'brutto_label'.tr()}: ${grossWeightValue.toStringAsFixed(3)} $weightSuffix'
                        : ''
        ],
      ];

      // --- Автоматический размер шрифта ---
      int rowCount = exportData.length;
      int colCount = exportHeaders.length;
      double fontSize = 10;
      if (rowCount > 30 || colCount > 12) {
        fontSize = 7;
      } else if (rowCount > 15 || colCount > 8) {
        fontSize = 8;
      }

      final pdf = pw.Document();

      // Загружаем шрифт из assets
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat ??
              PdfPageFormat.a4, // Можно передать PdfPageFormat.a4.landscape
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
            italic: ttf,
            boldItalic: ttf,
          ),
          build: (context) => [
            pw.Table.fromTextArray(
              headers: exportHeaders,
              data: exportData,
              cellStyle: pw.TextStyle(font: ttf, fontSize: fontSize),
              headerStyle: pw.TextStyle(
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: fontSize + 1),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();

      if (Platform.isAndroid || Platform.isIOS) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/exported_table.pdf';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(pdfBytes);
        await Share.shareXFiles([XFile(tempPath)], text: 'PDF экспорт');
      } else {
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранить PDF как...',
          fileName: 'exported_table.pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          bytes: pdfBytes,
        );
        if (outputPath != null) {
          final file = File(outputPath);
          await file.writeAsBytes(pdfBytes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('pdf_saved'.tr(args: [outputPath]))),
            );
            await Share.shareXFiles([XFile(outputPath)], text: 'PDF экспорт');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('save_cancelled'.tr())),
            );
          }
        }
      }
    } catch (e, stack) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('export_error'.tr(args: [e.toString()]))),
        );
      }
      print('PDF export error: $e\n$stack');
    }
  }

  Future<void> exportToPDFWithPaging(
      List<List<String>> exportData, List<String> exportHeaders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Table.fromTextArray(
            headers: exportHeaders,
            data: exportData.skip(1).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> _exportToExcel() async {
    final showD2 = tableData.any((row) =>
        row['Метод'] != null &&
        (row['Метод'].toString().startsWith('Среднеарифметический диаметр') ||
            row['Метод'].toString().startsWith('Смалиана') ||
            row['Метод'].toString().startsWith('Ньютона')));
    final showDMiddle = tableData.any((row) =>
        row['Метод'] != null && row['Метод'].toString().startsWith('Ньютона'));
    int totalCount = tableData.fold<int>(
      0,
      (sum, row) =>
          sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
    );
    double totalSum = tableData.fold<double>(
      0,
      (sum, row) =>
          sum + (double.tryParse(row['Итоговая цена']?.toString() ?? '0') ?? 0),
    );
    double totalVolume = tableData.fold<double>(
      0,
      (sum, row) =>
          sum + (double.tryParse(row['Объем']?.toString() ?? '0') ?? 0),
    );

    // Итоговые веса и объем с корой
    double totalNettoWeight = 0;
    double totalBruttoWeight = 0;
    double totalVolumeWithBark = 0;
    for (final row in tableData) {
      double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
      double rowDensity = 600;
      if (row['Порода'] != null && speciesDensity.containsKey(row['Порода'])) {
        rowDensity = speciesDensity[row['Порода']]!;
      }
      double barkPercent = 0.0;
      if (row['Порода'] != null && speciesData.containsKey(row['Порода'])) {
        barkPercent = speciesData[row['Порода']] ?? 0.0;
      }
      double rowVolumeWithBark = rowVolume * (1 + barkPercent);
      double rowMoistureCoef = 1 + (woodMoisture / 100);

      totalNettoWeight += rowVolume * rowDensity * rowMoistureCoef;
      totalBruttoWeight +=
          rowVolumeWithBark * rowDensity * rowMoistureCoef + packageWeight;
      totalVolumeWithBark += rowVolumeWithBark;
    }
    final netWeightValue =
        weightUnit == 'т' ? totalNettoWeight / 1000 : totalNettoWeight;
    final grossWeightValue =
        weightUnit == 'т' ? totalBruttoWeight / 1000 : totalBruttoWeight;
    final weightSuffix = weightUnit == 'т' ? 'т' : 'кг';

    final List<String> exportHeaders = [
      '№',
      if (showMethodColumn) 'method_col'.tr(),
      if (showSpeciesColumn) 'species_col'.tr(),
      if (showGradeColumn) 'grade_col'.tr(),
      'length_col'.tr() + ' ($lengthUnit)',
      'diameter_col'.tr() + ' ($diameterUnit)',
      if (showD2) 'd2 ($diameterUnit)',
      if (showDMiddle) '${'dMiddle'.tr()} ($diameterUnit)',
      'quantity_col'.tr(),
      if (showPriceColumn) 'price_per_m3_col'.tr() + ' $selectedCurrency',
      'volume_col'.tr(),
      if (showTotalPriceColumn) 'total_price_col'.tr() + ' $selectedCurrency',
      if (showGrossWeightColumn)
        'brutto_label'.tr() + ' (${_weightUnitTr(context)})',
      if (showNetWeightColumn)
        'netto_label'.tr() + ' (${_weightUnitTr(context)})',
      if (showBarkVolumeColumn) 'bark_volume_label'.tr(),
    ];

    // Формируем таблицу для Excel (List<List<dynamic>>)
    final exportData = [
      ...tableData.asMap().entries.map((entry) {
        int index = entry.key;
        final row = entry.value;
        double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
        double rowDensity = 600;
        if (row['Порода'] != null &&
            speciesDensity.containsKey(row['Порода'])) {
          rowDensity = speciesDensity[row['Порода']]!;
        }
        double barkPercent = 0.0;
        if (row['Порода'] != null && speciesData.containsKey(row['Порода'])) {
          barkPercent = speciesData[row['Порода']] ?? 0.0;
        }
        double rowVolumeWithBark = rowVolume * (1 + barkPercent);
        double rowMoistureCoef = 1 + (woodMoisture / 100);
        double rowGrossWeight = (grossWithBark && rowVolumeWithBark > 0
                    ? rowVolumeWithBark
                    : rowVolume) *
                rowDensity *
                rowMoistureCoef +
            packageWeight;
        double rowNetWeight = rowVolume * rowDensity * rowMoistureCoef;

        final rowGrossWeightDisplay = weightUnit == 'т'
            ? (rowGrossWeight / 1000).toStringAsFixed(3)
            : rowGrossWeight.toStringAsFixed(1);
        final rowNetWeightDisplay = weightUnit == 'т'
            ? (rowNetWeight / 1000).toStringAsFixed(3)
            : rowNetWeight.toStringAsFixed(1);

        return [
          (index + 1).toString(),
          if (showMethodColumn) row['Метод'] ?? '',
          if (showSpeciesColumn) getSpeciesDisplayName(row['Порода']),
          if (showGradeColumn) row['Сорт'] ?? '',
          row['Длина']?.toString() ?? '',
          row['Диаметр']?.toString() ?? '',
          if (showD2) row['d2']?.toString() ?? '',
          if (showDMiddle) row['dMiddle']?.toString() ?? '',
          row['Количество']?.toString() ?? '',
          if (showPriceColumn)
            row['Цена за м³'] != null
                ? double.tryParse(row['Цена за м³'].toString())
                        ?.toStringAsFixed(2) ??
                    ''
                : '',
          row['Объем'] ?? '',
          if (showTotalPriceColumn)
            row['Итоговая цена'] != null
                ? double.tryParse(row['Итоговая цена'].toString())
                        ?.toStringAsFixed(2) ??
                    ''
                : '',
          if (showGrossWeightColumn) rowGrossWeightDisplay,
          if (showNetWeightColumn) rowNetWeightDisplay,
          if (showBarkVolumeColumn) rowVolumeWithBark.toStringAsFixed(3),
        ];
      }),
      // Итоговая строка по количеству, объему, сумме
      [
        'total'.tr(),
        if (showMethodColumn) '',
        if (showSpeciesColumn) '',
        if (showGradeColumn) '',
        '',
        '',
        if (showD2) '',
        if (showDMiddle) '',
        totalCount.toString(),
        if (showPriceColumn) '',
        totalVolume.toStringAsFixed(3),
        if (showTotalPriceColumn) totalSum.toStringAsFixed(2),
        if (showGrossWeightColumn) '',
        if (showNetWeightColumn) '',
        if (showBarkVolumeColumn) '',
      ],
      // Итоговая строка по объему с корой, нетто, брутто
      [
        '',
        for (int i = 1; i < exportHeaders.length; i++)
          i == exportHeaders.length - 1 && showBarkVolumeColumn
              ? '${'bark_volume_label'.tr()}: ${totalVolumeWithBark.toStringAsFixed(3)}'
              : i == exportHeaders.length - 2 && showNetWeightColumn
                  ? '${'netto_label'.tr()}: ${netWeightValue.toStringAsFixed(3)} $weightSuffix'
                  : i ==
                              exportHeaders.length -
                                  (showBarkVolumeColumn ? 3 : 2) &&
                          showGrossWeightColumn
                      ? '${'brutto_label'.tr()}: ${grossWeightValue.toStringAsFixed(3)} $weightSuffix'
                      : ''
      ],
    ];

    await FileSaver.exportAndShare(
      data: exportData,
      type: 'excel',
      fileName: 'export',
      headers: exportHeaders,
    );
  }

  Future<Directory> getManualTablesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/tables/mm');
    if (!await tablesDir.exists()) {
      await tablesDir.create(recursive: true);
    }
    return tablesDir;
  }

  Future<void> _saveTableToFileInAppFolder(String? fileName) async {
    try {
      final dir = await getManualTablesDirectory();

      // Формируем имя файла для автосохранения
      String name;
      if (fileName == null || fileName == '_autosave_manual.csv') {
        final now = DateTime.now();
        final dateStr =
            '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
        final timeStr =
            '${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}';
        name = 'cl_mm_data_${dateStr}_$timeStr.csv';
      } else {
        name = fileName;
        if (!name.contains('cl_mm_data')) {
          name = 'cl_mm_data_$name';
        }
      }

      final file = File('${dir.path}/$name');

      final showD2 = tableData.any((row) =>
          row['Метод'] != null &&
          (row['Метод'].toString().startsWith('Среднеарифметический диаметр') ||
              row['Метод'].toString().startsWith('Смалиана') ||
              row['Метод'].toString().startsWith('Ньютона')));
      final showDMiddle = tableData.any((row) =>
          row['Метод'] != null &&
          row['Метод'].toString().startsWith('Ньютона'));

      // --- Формируем заголовки ---
      final headers = [
        '№',
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

      // --- Формируем строки данных ---
      final rows = tableData.asMap().entries.map((entry) {
        int index = entry.key;
        final row = entry.value;
        double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
        double rowDensity = 600;
        if (row['Порода'] != null &&
            speciesDensity.containsKey(row['Порода'])) {
          rowDensity = speciesDensity[row['Порода']]!;
        }
        double barkPercent = 0.0;
        if (row['Порода'] != null && speciesData.containsKey(row['Порода'])) {
          barkPercent = speciesData[row['Порода']] ?? 0.0;
        }
        double rowVolumeWithBark = rowVolume * (1 + barkPercent);
        double rowMoistureCoef = 1 + (woodMoisture / 100);
        double rowGrossWeight = (showWithBark && rowVolumeWithBark > 0
                    ? rowVolumeWithBark
                    : rowVolume) *
                rowDensity *
                rowMoistureCoef +
            packageWeight;
        double rowNetWeight = rowVolume * rowDensity * rowMoistureCoef;

        return [
          (index + 1).toString(),
          if (showMethodColumn) row['Метод'] ?? '',
          if (showSpeciesColumn) row['Порода'] ?? '',
          if (showGradeColumn) row['Сорт'] ?? '',
          row['Длина']?.toString() ?? '',
          row['Диаметр']?.toString() ?? '',
          if (showD2) row['d2']?.toString() ?? '',
          if (showDMiddle) row['dMiddle']?.toString() ?? '',
          row['Количество']?.toString() ?? '',
          if (showPriceColumn) row['Цена за м³']?.toString() ?? '',
          row['Объем'] ?? '',
          if (showTotalPriceColumn) row['Итоговая цена']?.toString() ?? '',
          if (showGrossWeightColumn) rowGrossWeight.toStringAsFixed(1),
          if (showNetWeightColumn) rowNetWeight.toStringAsFixed(1),
          if (showBarkVolumeColumn) rowVolumeWithBark.toStringAsFixed(3),
        ].join(',');
      }).toList();

      // --- Собираем всё для файла (БЕЗ итоговой строки!) ---
      final tableContent = [
        headers.join(','),
        ...rows,
      ].join('\n');

      await file.writeAsString(tableContent);

      if (fileName != null && fileName != '_autosave_manual.csv') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('save_table'.tr(args: [file.path]))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('save_error'.tr(args: [e.toString()]))),
      );
    }
  }

// --- Для предварительного просмотра истории используйте только headers и rows, не добавляйте totalRow ---
  Future<void> _loadTableFromAppFolderAuto() async {
    final dir = await getManualTablesDirectory();
    // Найти все файлы автосохранения с cl_mm_data
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('cl_mm_data') && f.path.endsWith('.csv'))
        .toList();

    if (files.isEmpty) return;

    // Найти самый свежий файл по дате изменения
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    final file = files.first;

    final content = await file.readAsString();
    final rows = content.split('\n');
    setState(() {
      tableData = rows
          .skip(1) // пропускаем шапку
          .where((row) => row.trim().isNotEmpty)
          .map((row) {
        final values = row.split(',');
        return <String, dynamic>{
          'Метод': values.length > 1 ? values[1] : '',
          'Порода': values.length > 2 ? values[2] : '',
          'Сорт': values.length > 3 ? values[3] : '',
          'Длина': values.length > 4 ? values[4] : '',
          'Диаметр': values.length > 5 ? values[5] : '',
          'd2': values.length > 6 ? values[6] : '',
          'dMiddle': values.length > 7 ? values[7] : '',
          'Количество': values.length > 8 ? values[8] : '1',
          'Цена за м³': values.length > 9 ? values[9] : '',
          'Объем': values.length > 10 ? values[10] : '',
          'Итоговая цена': values.length > 11 ? values[11] : '',
        };
      }).toList();

      // Пересчитываем каждую строку
      for (var row in tableData) {
        _recalculateRow(row);
      }

      // Пересчитываем итоги
      _recalculateTotals();
    });
  }

  Future<void> _saveTableToFile(String fileName) async {
    if (await StoragePermissionHelper.requestStoragePermission()) {
      try {
        final dir = await getManualTablesDirectory();
        // Имя файла: если не содержит cl_mm_data, добавим
        String name = fileName;
        if (!name.contains('cl_mm_data')) {
          name = 'cl_mm_data_$name';
        }
        // Добавим дату, если её нет в имени
        final now = DateTime.now();
        final dateStr =
            '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
        if (!name.contains(dateStr)) {
          name = name.replaceFirst('.csv', '_$dateStr.csv');
        }
        final file = File('${dir.path}/$name');
        final headers = [
          '№',
          'Метод',
          'Порода',
          'Сорт',
          'Длина',
          'Диаметр',
          'Плотность',
          'Количество',
          'Цена за м³ $selectedCurrency',
          'Объем',
          'Итоговая цена $selectedCurrency',
        ];
        final tableContent = [
          headers.join(','),
          ...tableData.asMap().entries.map((entry) {
            int index = entry.key;
            final row = entry.value;
            return [
              (index + 1).toString(),
              row['Метод'] ?? '',
              row['Порода'] ?? '',
              row['Сорт'] ?? '',
              row['Длина']?.toString() ?? '',
              row['Диаметр']?.toString() ?? '',
              row['Плотность']?.toString() ?? '',
              row['Количество']?.toString() ?? '',
              row['Цена за м³']?.toString() ?? '',
              row['Объем'] ?? '',
              row['Итоговая цена']?.toString() ?? '',
            ].join(',');
          }),
        ].join('\n');
        await file.writeAsString(tableContent);
        if (fileName != '_autosave_manual.csv') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('save_table'.tr(args: [file.path]))),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('save_error'.tr(args: [e.toString()]))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_file_access'.tr())),
      );
    }
  }

  Future<void> _loadTableFromAppFolder() async {
    final dir = await getManualTablesDirectory();
    // Только файлы с cl_mm_data и .csv
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('cl_mm_data') && f.path.endsWith('.csv'))
        .toList();

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_saved_tables'.tr())),
      );
      return;
    }

    showDialog(
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
          title: Text('select_file'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final fileName = file.path.split('/').last;
                return ListTile(
                  title: Text(fileName),
                  onTap: () async {
                    final content = await file.readAsString();
                    final rows = content.split('\n');
                    setState(() {
                      tableData = rows
                          .skip(1)
                          .where((row) => row.trim().isNotEmpty)
                          .map((row) {
                        final values = row.split(',');
                        return <String, dynamic>{
                          'Метод': values.length > 1 ? values[1] : '',
                          'Порода': values.length > 2 ? values[2] : '',
                          'Сорт': values.length > 3 ? values[3] : '',
                          'Длина': values.length > 4 ? values[4] : '',
                          'Диаметр': values.length > 5 ? values[5] : '',
                          'd2': values.length > 6 ? values[6] : '',
                          'dMiddle': values.length > 7 ? values[7] : '',
                          'Количество': values.length > 8 ? values[8] : '1',
                          'Цена за м³': values.length > 9 ? values[9] : '',
                          'Объем': values.length > 10 ? values[10] : '',
                          'Итоговая цена': values.length > 11 ? values[11] : '',
                        };
                      }).toList();

                      // Пересчитываем каждую строку
                      for (var row in tableData) {
                        _recalculateRow(row);
                      }

                      // Пересчитываем итоги
                      _recalculateTotals();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('table_loaded'.tr(args: [fileName]))),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _recalculateTotals() {
    totalVolume = tableData.fold<double>(
      0,
      (sum, row) =>
          sum + (double.tryParse(row['Объем']?.toString() ?? '0') ?? 0),
    );
    totalSum = tableData.fold<double>(
      0,
      (sum, row) =>
          sum + (double.tryParse(row['Итоговая цена']?.toString() ?? '0') ?? 0),
    );
    totalCount = tableData.fold<int>(
      0,
      (sum, row) =>
          sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
    );
  }

  Future<void> _loadCustomSpecies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSpecies = prefs.getStringList('customSpecies');
    if (savedSpecies != null) {
      setState(() {
        customSpecies = savedSpecies;
      });
    }
  }

  Future<void> _loadGradeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedGrades = prefs.getStringList('gradeList');
    if (savedGrades != null) {
      setState(() {
        gradeList = savedGrades;
      });
    }
  }

  Future<void> _saveCustomSpecies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customSpecies', customSpecies);
  }

  Future<void> _saveGradeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gradeList', gradeList);
  }

  void _addCustomSpecies() {
    showDialog(
      context: context,
      builder: (context) {
        String? customSpeciesName;
        String? densityStr;
        String? barkStr;
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
                onChanged: (value) => customSpeciesName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'density_label'.tr()),
                keyboardType: TextInputType.number,
                onChanged: (value) => densityStr = value,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'bark_correction_label'.tr()),
                keyboardType: TextInputType.number,
                onChanged: (value) => barkStr = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (customSpeciesName != null &&
                    customSpeciesName!.isNotEmpty) {
                  setState(() {
                    customSpecies.add(customSpeciesName!);
                    selectedSpecies = customSpeciesName;
                    // Добавляем плотность и % коры
                    if (densityStr != null) {
                      speciesDensity[customSpeciesName!] =
                          double.tryParse(densityStr!) ?? 600;
                    }
                    if (barkStr != null) {
                      speciesData[customSpeciesName!] =
                          (double.tryParse(barkStr!) ?? 0) / 100;
                    }
                  });
                  _saveCustomSpecies();
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
            decoration: InputDecoration(
              hintText: 'select_grade'.tr(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (customGrade != null && customGrade!.isNotEmpty) {
                  setState(() {
                    gradeList.add(customGrade!);
                    selectedGrade = customGrade;
                  });
                  _saveGradeList();
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

  double get selectedDensity {
    if (selectedSpecies != null &&
        speciesDensity.containsKey(selectedSpecies)) {
      return speciesDensity[selectedSpecies]!;
    }
    return 600; // значение по умолчанию
  }

  double get grossVolume =>
      showWithBark && volumeWithBark > 0 ? volumeWithBark : totalVolume;
  double get netVolume => totalVolume;
  double get moistureCoef => 1 + (woodMoisture / 100);
  double get grossWeight =>
      (showWithBark && volumeWithBark > 0 ? volumeWithBark : totalVolume) *
          selectedDensity *
          moistureCoef +
      packageWeight;
  double get netWeight => totalVolume * selectedDensity * moistureCoef;

  double volumeNeller(double diameter, double length) {
    const double pi = 3.1416;
    return (pi / 4) * diameter * diameter * length * 0.785;
  }

  // ...existing code...

  void calculate() {
    if (length != null && diameter != null) {
      int qty = quantity ?? 1;
      double oneVol = 0.0;

      double l = length!; // всегда в метрах
      double d1 = diameter!; // всегда в мм
      double d2 = diameter2 ?? d1;
      double dMiddle = diameterMiddle ?? d1;

      if (selectedMethod != null &&
          selectedMethod!.startsWith('ГОСТ 2708-75')) {
        String lengthKey = l.toStringAsFixed(1);
        int diameterKey = (d1 / 10).round(); // d1 в мм, переводим в см
        if (GOST_2708_75_TABLE.containsKey(lengthKey)) {
          oneVol = GOST_2708_75_TABLE[lengthKey]?[diameterKey] ?? 0.0;
        }
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('ISO_4480_83')) {
        String lengthKey = l.toStringAsFixed(1);
        int diameterKey = (d1 / 10).round();
        if (ISO_4480_83_TABLE.containsKey(lengthKey)) {
          oneVol = ISO_4480_83_TABLE[lengthKey]?[diameterKey] ?? 0.0;
        }
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('Неллера (х0.785)')) {
        double diameterMeters = d1 / 1000;
        oneVol = volumeNeller(diameterMeters, l);
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('Неллера (упрощённая)')) {
        // d1 в мм, l в м
        // Формула: (π * d^2 / 40000) * l
        double dCm = d1 / 10; // d1 в мм -> см
        oneVol = (3.14159 * dCm * dCm / 40000) * l;
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('Среднеарифметический диаметр')) {
        oneVol = (3.14159 / 4) * ((d1 * d1 + d1 * d2 + d2 * d2) / 3) * l / 1e6;
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('Смалиана')) {
        oneVol = (3.14159 / 4) * l * ((d1 * d1 + d2 * d2) / 2) / 1e6;
      } // ...внутри calculate или _recalculateRow...
      else if (selectedMethod != null &&
          selectedMethod!.startsWith('Ньютона')) {
        // d1, d2, dMiddle — в мм, переводим в метры
        double d1m = d1 / 1000;
        double d2m = d2 / 1000;
        double dmm = dMiddle / 1000;
        oneVol = (3.14159 * l / 24) * (d1m * d1m + 4 * dmm * dmm + d2m * d2m);
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('Губера')) {
        oneVol = (3.14159 / 4) * d1 * d1 * l / 1e6;
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('JAS Scale (формула)')) {
        double dCm = d1 / 10; // d1 в мм -> см
        oneVol = (dCm * dCm * l) / 10000;
      } else if (selectedMethod != null &&
          selectedMethod!.startsWith('JAS Scale (таблица)')) {
        double dCm = d1 / 10;
        double jasDiameter = roundDiameterForJAS(dCm);
        double jas = (jasDiameter * jasDiameter * l) / 10000;

        // Пытаемся найти коэффициент для выбранной породы
        double? coef = getJasCoef(
          l,
          jasDiameter,
          species: selectedSpecies ?? 'radiata_pine',
          density: selectedJasDensityRange ?? '0.8-1.19',
        );

        // Если не найдено — пробуем для дефолтной породы
        if (coef == null || coef <= 0) {
          coef = getJasCoef(
            l,
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
      } else {
        double diameterMeters = d1 / 1000;
        oneVol = 3.14159 * (diameterMeters / 2) * (diameterMeters / 2) * l;
      }

      volume = oneVol * qty;
      totalPrice = volume * (price ?? 0);

      if (showWithBark) {
        calculateVolumeWithBark();
      }

      setState(() {});
      _saveTableToFileInAppFolder('_autosave_manual.csv');
    }
  }

  String getSpeciesDisplayName(String? key) {
    if (key == null || key.isEmpty) return '-';
    // Если ключ есть в speciesMeta, используем перевод
    if (speciesMeta.containsKey(key)) return key.tr();
    // Если это кастомная порода — просто показываем как есть
    return key;
  }

// Исправленный метод _recalculateRow без двойного пересчета итогов
  void _recalculateRow(Map<String, dynamic> row) {
    double? length = double.tryParse(row['Длина']?.toString() ?? '');
    double? diameter = double.tryParse(row['Диаметр']?.toString() ?? '');
    double? diameter2 = double.tryParse(row['d2']?.toString() ?? '');
    double? diameterMiddle = double.tryParse(row['dMiddle']?.toString() ?? '');
    int quantity = int.tryParse(row['Количество']?.toString() ?? '') ?? 1;
    double? price = double.tryParse(row['Цена за м³']?.toString() ?? '');

    double volume = 0;
    double totalPrice = 0;

    if (length != null && diameter != null) {
      double l = length; // всегда в метрах
      double d1 = diameter; // всегда в мм
      double d2val = diameter2 ?? d1;
      double dMiddleVal = diameterMiddle ?? d1;

      if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('ГОСТ 2708-75')) {
        String lengthKey = l.toStringAsFixed(1);
        int diameterKey = (d1 / 10).round();
        if (GOST_2708_75_TABLE.containsKey(lengthKey)) {
          volume =
              (GOST_2708_75_TABLE[lengthKey]?[diameterKey] ?? 0.0) * quantity;
        }
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('ISO_4480_83')) {
        String lengthKey = l.toStringAsFixed(1);
        int diameterKey = (d1 / 10).round();
        if (ISO_4480_83_TABLE.containsKey(lengthKey)) {
          volume =
              (ISO_4480_83_TABLE[lengthKey]?[diameterKey] ?? 0.0) * quantity;
        }
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('Неллера (х0.785)')) {
        double diameterMeters = d1 / 1000;
        volume = volumeNeller(diameterMeters, l) * quantity;
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('Неллера (упрощённая)')) {
        double dCm = d1 / 10; // d1 в мм -> см
        volume = (3.14159 * dCm * dCm / 40000) * l * quantity;
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('Среднеарифметический диаметр')) {
        volume = (3.14159 / 4) *
            ((d1 * d1 + d1 * d2val + d2val * d2val) / 3) *
            l /
            1e6 *
            quantity;
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('Смалиана')) {
        volume = (3.14159 / 4) *
            l *
            ((d1 * d1 + d2val * d2val) / 2) /
            1e6 *
            quantity;
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('Ньютона')) {
        double d1m = d1 / 1000;
        double d2m = d2val / 1000;
        double dmm = dMiddleVal / 1000;
        volume = (3.14159 * l / 24) *
            (d1m * d1m + 4 * dmm * dmm + d2m * d2m) *
            quantity;
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('Губера')) {
        volume = (3.14159 / 4) * d1 * d1 * l / 1e6 * quantity;
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('JAS Scale (формула)')) {
        double dCm = d1 / 10;
        volume = (dCm * dCm * l) / 10000 * quantity;
      } else if (row['Метод'] != null &&
          row['Метод'].toString().startsWith('JAS Scale (таблица)')) {
        double dCm = d1 / 10;
        double jasDiameter = roundDiameterForJAS(dCm);
        double jas = (jasDiameter * jasDiameter * l) / 10000;

        double? coef = getJasCoef(
          l,
          jasDiameter,
          species: row['Порода'] ?? 'radiata_pine',
          density: row['Плотность'] ?? '0.8-1.19',
        );

        if (coef == null || coef <= 0) {
          coef = getJasCoef(
            l,
            jasDiameter,
            species: 'radiata_pine',
            density: row['Плотность'] ?? '0.8-1.19',
          );
        }

        if (coef != null && coef > 0) {
          volume = jas / coef * quantity;
        } else {
          volume = 0.0;
        }
      } else {
        double diameterMeters = d1 / 1000;
        volume = 3.14159 *
            (diameterMeters / 2) *
            (diameterMeters / 2) *
            l *
            quantity;
      }
      totalPrice = volume * (price ?? 0);
    }

    row['Объем'] = volume.toStringAsFixed(3);
    row['Итоговая цена'] = totalPrice.toStringAsFixed(2);

    // НЕ пересчитываем итоги здесь - это будет делаться один раз после загрузки
    setState(() {});
    _saveTableToFileInAppFolder('_autosave_manual.csv');
  }

  void calculateVolumeWithBark() {
    if (selectedSpecies != null && volume > 0) {
      double percentage = speciesData[selectedSpecies!] ??
          0.0; // Получаем процент для выбранной породы
      setState(() {
        volumeWithBark =
            volume * (1 + percentage); // Увеличиваем кубатуру на процент
      });
    } else {
      setState(() {
        volumeWithBark = 0.0; // Если порода не выбрана или объём равен 0
      });
    }
  }

  void _applyUnitChanges({
    String? newLengthUnit,
    String? newDiameterUnit,
  }) {
    setState(() {
      // Пересчёт длины
      if (newLengthUnit != null && length != null) {
        if (lengthUnit == 'см') length = length! / 100;
        if (lengthUnit == 'мм') length = length! / 1000;
        // Теперь length в метрах
        if (newLengthUnit == 'см') length = length! * 100;
        if (newLengthUnit == 'мм') length = length! * 1000;
        // Теперь length в новых единицах
        lengthUnit = newLengthUnit;
      }
      // Пересчёт диаметров
      if (newDiameterUnit != null) {
        void convertDiameterField(double? value, void Function(double) setter) {
          if (value == null) return;
          double mm = diameterUnit == 'см' ? value * 10 : value;
          double newValue = newDiameterUnit == 'см' ? mm / 10 : mm;
          setter(newValue);
        }

        convertDiameterField(diameter, (v) => diameter = v);
        convertDiameterField(diameter2, (v) => diameter2 = v);
        convertDiameterField(diameterMiddle, (v) => diameterMiddle = v);
        diameterUnit = newDiameterUnit;
      }
      calculate();
    });
  }

  void addToTable() {
    if (length != null && diameter != null) {
      if (quantity == null || quantity! < 1) quantity = 1;
      Map<String, dynamic> row = {
        'Метод': selectedMethod ?? '',
        'Порода': selectedSpecies ?? '',
        'Сорт': selectedGrade ?? '',
        'Длина': length?.toString() ?? '',
        'Диаметр': diameter?.toString() ?? '',
        if (selectedMethod != null &&
            (selectedMethod!.startsWith('Среднеарифметический диаметр') ||
                selectedMethod!.startsWith('Смалиана') ||
                selectedMethod!.startsWith('Ньютона')))
          'd2': diameter2?.toString() ?? '',
        if (selectedMethod != null && selectedMethod!.startsWith('Ньютона'))
          'dMiddle': diameterMiddle?.toString() ?? '',
        'Количество': quantity?.toString() ?? '1',
        'Цена за м³': price?.toString() ?? '',
        'Объем': volume.toStringAsFixed(3),
        'Итоговая цена': totalPrice.toStringAsFixed(2),
        if (selectedMethod != null &&
            selectedMethod!.startsWith('JAS Scale (таблица)'))
          'Плотность': selectedJasDensityRange ?? '0.8-1.19',
      };
      tableData.add(row);
      totalVolume += volume * quantity!;
      setState(() {});
      _saveTableToFileInAppFolder('_autosave_manual.csv');
    }
  }

  void clearTable() {
    tableData.clear();
    totalVolume = 0;
    setState(() {});
    _saveTableToFileInAppFolder('_autosave_manual.csv');
  }

  void shareData() {
    showDialog(
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
          title: Text('select_messenger'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                title: Text('WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                  _selectShareFormat('WhatsApp');
                },
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.blue),
                title: Text('Email'),
                onTap: () {
                  Navigator.pop(context);
                  _selectShareFormat('Email');
                },
              ),
              ListTile(
                leading: Icon(Icons.telegram, color: Colors.blueAccent),
                title: Text('Telegram'),
                onTap: () {
                  Navigator.pop(context);
                  _selectShareFormat('Telegram');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectShareFormat(String messenger) {
    showDialog(
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
          title: Text('select_format'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('PDF'),
                onTap: () {
                  Navigator.pop(context);
                  print('Share via $messenger as PDF');
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.blue),
                title: Text('Excel'),
                onTap: () {
                  Navigator.pop(context);
                  print('Share via $messenger as Excel');
                },
              ),
            ],
          ),
        );
      },
    );
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

    final allRegions = <String>{
      for (final meta in speciesMeta.values) ...meta.countries
    }.toList()
      ..sort();

    List<String> allSpecies = speciesMeta.keys.toList()..sort();

    List<String> filteredSpecies() {
      return allSpecies.where((s) {
        final meta = speciesMeta[s];
        if (meta == null) return false;
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
                      Row(
                        children: [
                          ChoiceChip(
                            label: Text('hardwood'.tr()),
                            selected: filterType == 'hardwood',
                            onSelected: (_) =>
                                setStateDialog(() => filterType = 'hardwood'),
                          ),
                          SizedBox(width: 4),
                          ChoiceChip(
                            label: Text('softwood'.tr()),
                            selected: filterType == 'softwood',
                            onSelected: (_) =>
                                setStateDialog(() => filterType = 'softwood'),
                          ),
                        ],
                      ),
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
                      // Список пород
                      SizedBox(
                        height: 250,
                        child: Scrollbar(
                          child: ListView(
                            children: filtered.map((s) {
                              final selected = tempSelected.contains(s);
                              final meta = speciesMeta[s];
                              return CheckboxListTile(
                                value: selected,
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
                                        meta?.density != null) ...[
                                      SizedBox(width: 6),
                                      Text(
                                          '(ρ: ${meta!.density!.toStringAsFixed(0)})',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                    ],
                                    // ...existing code...
                                    if (showBarkLocal &&
                                        meta?.barkCorrection != null) ...[
                                      SizedBox(width: 6),
                                      Text(
                                        '(${'bark'.tr()}: +${(meta!.barkCorrection! * 100).round()}%)',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.green),
                                      ),
                                    ],
                                    // ...existing code...
                                  ],
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
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
                    final newSpecies = Set<String>.from(selectedSpeciesList)
                      ..addAll(tempSelected);
                    setState(() {
                      selectedSpeciesList = newSpecies.toList();
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

  Future<void> _loadUserUnits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lengthUnit = prefs.getString('selectedLengthUnit') ?? 'м';
      diameterUnit = prefs.getString('selectedDiameterUnit') ?? 'мм';
      weightUnit = prefs.getString('weightUnit') ?? 'кг';
    });
  }

  Future<void> _saveUserUnits() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLengthUnit', lengthUnit);
    prefs.setString('selectedDiameterUnit', diameterUnit);
    prefs.setString('weightUnit', weightUnit);
  }

  @override
  Widget build(BuildContext context) {
    int totalCount = tableData.fold<int>(
      0,
      (sum, row) =>
          sum + (int.tryParse(row['Количество']?.toString() ?? '1') ?? 1),
    );
    double totalSum = tableData.fold<double>(
      0,
      (sum, row) =>
          sum + (double.tryParse(row['Итоговая цена']?.toString() ?? '0') ?? 0),
    );

    double totalNettoWeight = 0;
    double totalBruttoWeight = 0;
    double totalVolumeWithBark = 0;

    for (final row in tableData) {
      double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
      double rowDensity = 600;
      if (row['Порода'] != null && speciesDensity.containsKey(row['Порода'])) {
        rowDensity = speciesDensity[row['Порода']]!;
      }
      double barkPercent = 0.0;
      if (row['Порода'] != null && speciesData.containsKey(row['Порода'])) {
        barkPercent = speciesData[row['Порода']] ?? 0.0;
      }
      double rowVolumeWithBark = rowVolume * (1 + barkPercent);
      double rowMoistureCoef = 1 + (woodMoisture / 100);

      totalNettoWeight += rowVolume * rowDensity * rowMoistureCoef;
      totalBruttoWeight +=
          rowVolumeWithBark * rowDensity * rowMoistureCoef + packageWeight;
      totalVolumeWithBark += rowVolumeWithBark;
    }

    // Перед Expanded/DataTable:
    final showD2 = tableData.any((row) =>
        row['Метод'] != null &&
        (row['Метод'].toString().startsWith('Среднеарифметический диаметр') ||
            row['Метод'].toString().startsWith('Смалиана') ||
            row['Метод'].toString().startsWith('Ньютона')));

    final showDMiddle = tableData.any((row) =>
        row['Метод'] != null && row['Метод'].toString().startsWith('Ньютона'));

    final netWeightValue =
        weightUnit == 'т' ? totalNettoWeight / 1000 : totalNettoWeight;
    final grossWeightValue =
        weightUnit == 'т' ? totalBruttoWeight / 1000 : totalBruttoWeight;
    //final weightSuffix = weightUnit == 'т' ? 'т' : 'кг';

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
                    'manual_calculator'
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
          // ...existing code...

          drawer: MainDrawer(
            currentScreen: 'manual_calculator',
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

// ...existing code...
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Первый ряд: Метод, Порода, Сорт, Цена
                Row(
                  children: [
                    // Метод
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
                                'Среднеарифметический диаметр (формула)',
                                'Смалиана (формула)',
                                'Губера (формула)',
                                'Ньютона (формула)',
                                'JAS Scale (формула)',
                                'JAS Scale (таблица)',
                              ];
                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).dialogBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1.5,
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
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedMethod = method;
                                            calculate();
                                            if (showWithBark)
                                              calculateVolumeWithBark();
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: selectedMethod == method
                                                ? Colors.green[100]
                                                : Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              method.tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: selectedMethod == method
                                                    ? Colors.green
                                                    : Colors.black,
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
                                                bool localGrossWithBark =
                                                    grossWithBark;
                                                return StatefulBuilder(
                                                  builder: (context,
                                                      setStateDialog) {
                                                    return AlertDialog(
                                                      backgroundColor: Theme.of(
                                                              context)
                                                          .dialogBackgroundColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18),
                                                        side: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          width: 1.5,
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
                                                            TextFormField(
                                                              initialValue:
                                                                  localMoisture
                                                                      .toString(),
                                                              decoration: InputDecoration(
                                                                  labelText:
                                                                      'moisture_label'
                                                                          .tr()),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              onChanged: (v) =>
                                                                  setStateDialog(
                                                                      () {
                                                                localMoisture =
                                                                    double.tryParse(
                                                                            v) ??
                                                                        0;
                                                              }),
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
                                                                  showGrossWeightColumn,
                                                              onChanged: (v) =>
                                                                  setStateDialog(() =>
                                                                      showGrossWeightColumn =
                                                                          v ??
                                                                              false),
                                                              title: Text(
                                                                  'show_gross_weight_col'
                                                                      .tr()),
                                                            ),
                                                            CheckboxListTile(
                                                              value:
                                                                  showNetWeightColumn,
                                                              onChanged: (v) =>
                                                                  setStateDialog(() =>
                                                                      showNetWeightColumn =
                                                                          v ??
                                                                              false),
                                                              title: Text(
                                                                  'show_net_weight_col'
                                                                      .tr()),
                                                            ),
                                                            CheckboxListTile(
                                                              value:
                                                                  showBarkVolumeColumn,
                                                              onChanged: (v) =>
                                                                  setStateDialog(() =>
                                                                      showBarkVolumeColumn =
                                                                          v ??
                                                                              false),
                                                              title: Text(
                                                                  'show_bark_volume_col'
                                                                      .tr()),
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
                                                              grossWithBark =
                                                                  localGrossWithBark;
                                                            });
                                                            calculate();
                                                            if (showWithBark)
                                                              calculateVolumeWithBark();
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
                                                    bool localGrossWithBark =
                                                        grossWithBark;
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
                                                                    .circular(
                                                                        18),
                                                            side: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              width: 1.5,
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
                                                                TextFormField(
                                                                  initialValue:
                                                                      localMoisture
                                                                          .toString(),
                                                                  decoration: InputDecoration(
                                                                      labelText:
                                                                          'moisture_label'
                                                                              .tr()),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  onChanged: (v) =>
                                                                      setStateDialog(
                                                                          () {
                                                                    localMoisture =
                                                                        double.tryParse(v) ??
                                                                            0;
                                                                  }),
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
                                                                        double.tryParse(v) ??
                                                                            0;
                                                                  }),
                                                                ),
                                                                CheckboxListTile(
                                                                  value:
                                                                      showGrossWeightColumn,
                                                                  onChanged: (v) =>
                                                                      setStateDialog(() =>
                                                                          showGrossWeightColumn =
                                                                              v ?? false),
                                                                  title: Text(
                                                                      'show_gross_weight_col'
                                                                          .tr()),
                                                                ),
                                                                CheckboxListTile(
                                                                  value:
                                                                      showNetWeightColumn,
                                                                  onChanged: (v) =>
                                                                      setStateDialog(() =>
                                                                          showNetWeightColumn =
                                                                              v ?? false),
                                                                  title: Text(
                                                                      'show_net_weight_col'
                                                                          .tr()),
                                                                ),
                                                                CheckboxListTile(
                                                                  value:
                                                                      showBarkVolumeColumn,
                                                                  onChanged: (v) =>
                                                                      setStateDialog(() =>
                                                                          showBarkVolumeColumn =
                                                                              v ?? false),
                                                                  title: Text(
                                                                      'show_bark_volume_col'
                                                                          .tr()),
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
                                                                  grossWithBark =
                                                                      localGrossWithBark;
                                                                });
                                                                calculate();
                                                                if (showWithBark)
                                                                  calculateVolumeWithBark();
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  'ok'.tr()),
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
                                                    builder: (_) =>
                                                        VipScreen()),
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
                      ),
                    ),
                    // ...вместо PopupMenuButton для пород...
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
                                ...selectedSpeciesList,
                                ...customSpecies.where(
                                    (s) => !selectedSpeciesList.contains(s)),
                              ];
                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).dialogBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
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
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _showSpeciesFilterDialog();
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
                                      final species =
                                          speciesDropdownList[index];
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
                                              calculate();
                                              if (showWithBark)
                                                calculateVolumeWithBark();
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
                                                        speciesMeta.containsKey(
                                                                species)
                                                            ? species.tr()
                                                            : species,
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
                                                tooltip: 'Удалить'.tr(),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    if (selectedSpecies ==
                                                        species)
                                                      selectedSpecies = null;
                                                    customSpecies
                                                        .remove(species);
                                                  });
                                                  _saveCustomSpecies();
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
                    // Сорт
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
                        // ...внутри Expanded(child: IconButton(... для сортов ...
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
                                                          .color),
                                            ),
                                          ),
                                        );
                                      }
                                      final grade = gradeList[index];
                                      final isCustom = !['1', '2', '3']
                                          .contains(
                                              grade); // или по вашему критерию

                                      return Stack(
                                        children: [
                                          GestureDetector(
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
                                                border: selectedGrade == grade
                                                    ? Border.all(
                                                        color: Colors.green,
                                                        width: 2)
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  grade,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        selectedGrade == grade
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
                                                tooltip: 'Удалить'.tr(),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    if (selectedGrade == grade)
                                                      selectedGrade = null;
                                                    gradeList.removeAt(index);
                                                  });
                                                  _saveGradeList();
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
                    // Цена
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
                                  title: Text('enter_price'.tr()),
                                  content: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          initialValue: price?.toString() ?? '',
                                          onChanged: (value) {
                                            price = double.tryParse(value);
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      DropdownButton<String>(
                                        value: selectedCurrency,
                                        items: currencies
                                            .map((cur) => DropdownMenuItem(
                                                  value: cur,
                                                  child: Text(cur),
                                                ))
                                            .toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedCurrency = val!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        calculate();
                                      },
                                      child: Text('ok'.tr()),
                                    ),
                                  ],
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
                                    return AlertDialog(
                                      backgroundColor: Theme.of(context)
                                          .dialogBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2,
                                        ),
                                      ),
                                      title: Text('enter_price'.tr()),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              initialValue:
                                                  price?.toString() ?? '',
                                              onChanged: (value) {
                                                price = double.tryParse(value);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          DropdownButton<String>(
                                            value: selectedCurrency,
                                            items: currencies
                                                .map((cur) => DropdownMenuItem(
                                                      value: cur,
                                                      child: Text(cur),
                                                    ))
                                                .toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                selectedCurrency = val!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            calculate();
                                          },
                                          child: Text('ok'.tr()),
                                        ),
                                      ],
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
                        tooltip: 'enter_price'.tr(),
                      ),
                    ),
                  ],
                ),
                // ...existing code...
                SizedBox(height: 16),
                // Второй ряд: Длина, Диаметр, Количество
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'length_label'.tr() + ' ($lengthUnit)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          double? val = double.tryParse(value);
                          if (val != null) {
                            if (lengthUnit == 'см')
                              length = val / 100;
                            else if (lengthUnit == 'мм')
                              length = val / 1000;
                            else
                              length = val;
                            calculate();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'diameter_label'.tr() +
                                      ' ($diameterUnit)'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                double? val = double.tryParse(value);
                                if (val != null) {
                                  if (diameterUnit == 'см')
                                    diameter = val * 10;
                                  else
                                    diameter = val;
                                  calculate();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.settings,
                                color: Theme.of(context).iconTheme.color),
                            tooltip: 'units_settings'.tr(),
                            onPressed: () async {
                              // Объявляем временные переменные для диалога
                              String tempLengthUnit = lengthUnit;
                              String tempDiameterUnit = diameterUnit;
                              String tempWeightUnit =
                                  weightUnit; // ← вот здесь объявить!
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
                                      final units = ['кг', 'т'];
                                      if (!units.contains(tempWeightUnit)) {
                                        tempWeightUnit = units.first;
                                      }
                                      return AlertDialog(
                                        backgroundColor: Theme.of(context)
                                            .dialogBackgroundColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                                                    .map((u) =>
                                                        DropdownMenuItem(
                                                            value: u,
                                                            child: Text(
                                                                'length_unit_$u'
                                                                    .tr())))
                                                    .toList(),
                                                onChanged: (v) {
                                                  if (v != null)
                                                    setStateDialog(() =>
                                                        tempLengthUnit = v);
                                                },
                                                hint: Text('length_unit'.tr()),
                                              ),
                                              DropdownButton<String>(
                                                value: tempDiameterUnit,
                                                items: ['мм', 'см']
                                                    .map((u) => DropdownMenuItem(
                                                        value: u,
                                                        child: Text(
                                                            'diameter_unit_$u'
                                                                .tr())))
                                                    .toList(),
                                                onChanged: (v) {
                                                  if (v != null)
                                                    setStateDialog(() =>
                                                        tempDiameterUnit = v);
                                                },
                                                hint:
                                                    Text('diameter_unit'.tr()),
                                              ),
                                              DropdownButton<String>(
                                                value: tempWeightUnit,
                                                items: units
                                                    .map(
                                                        (u) => DropdownMenuItem(
                                                              value:
                                                                  u, // value — только 'кг' или 'т'
                                                              child: Text(
                                                                  'weight_unit_$u'
                                                                      .tr()), // перевод для отображения
                                                            ))
                                                    .toList(),
                                                onChanged: (v) {
                                                  if (v != null)
                                                    setStateDialog(() =>
                                                        tempWeightUnit = v);
                                                },
                                                hint: Text('weight_unit'.tr()),
                                              ),
                                              Divider(),
                                              CheckboxListTile(
                                                value: tempShowMethodColumn,
                                                onChanged: (v) =>
                                                    setStateDialog(() =>
                                                        tempShowMethodColumn =
                                                            v ?? true),
                                                title: Text(
                                                    'show_method_col'.tr()),
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              CheckboxListTile(
                                                value: tempShowSpeciesColumn,
                                                onChanged: (v) =>
                                                    setStateDialog(() =>
                                                        tempShowSpeciesColumn =
                                                            v ?? true),
                                                title: Text(
                                                    'show_species_col'.tr()),
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              CheckboxListTile(
                                                value: tempShowGradeColumn,
                                                onChanged: (v) =>
                                                    setStateDialog(() =>
                                                        tempShowGradeColumn =
                                                            v ?? true),
                                                title:
                                                    Text('show_grade_col'.tr()),
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              CheckboxListTile(
                                                value: tempShowPriceColumn,
                                                onChanged: (v) =>
                                                    setStateDialog(() =>
                                                        tempShowPriceColumn =
                                                            v ?? true),
                                                title:
                                                    Text('show_price_col'.tr()),
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
                                                      tempLengthUnit !=
                                                              lengthUnit
                                                          ? tempLengthUnit
                                                          : null,
                                                  newDiameterUnit:
                                                      tempDiameterUnit !=
                                                              diameterUnit
                                                          ? tempDiameterUnit
                                                          : null,
                                                );
                                                weightUnit = tempWeightUnit;
                                                showMethodColumn =
                                                    tempShowMethodColumn;
                                                showSpeciesColumn =
                                                    tempShowSpeciesColumn;
                                                showGradeColumn =
                                                    tempShowGradeColumn;
                                                showDensityColumn =
                                                    tempShowDensityColumn;
                                                showPriceColumn =
                                                    tempShowPriceColumn;
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
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.format_list_numbered,
                            color: selectedMethod == null
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5)
                                : Theme.of(context).iconTheme.color),
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
                                title: Text('quantity_label'.tr()),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 300,
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 2,
                                    ),
                                    itemCount: 21,
                                    itemBuilder: (context, index) {
                                      if (index == 20) {
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                String? customQuantity;
                                                return AlertDialog(
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .dialogBackgroundColor,
                                                  shape: RoundedRectangleBorder(
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
                                                      'custom_quantity'.tr()),
                                                  content: TextFormField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      customQuantity = value;
                                                    },
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        if (customQuantity !=
                                                                null &&
                                                            customQuantity!
                                                                .isNotEmpty) {
                                                          setState(() {
                                                            quantity = int.tryParse(
                                                                    customQuantity!) ??
                                                                1;
                                                            calculate();
                                                            if (showWithBark)
                                                              calculateVolumeWithBark();
                                                          });
                                                        }
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('ok'.tr()),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Icon(Icons.edit,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        );
                                      }
                                      final qty = index + 1;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            quantity = qty;
                                            calculate();
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: quantity == qty
                                                ? Colors.green[100]
                                                : Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$qty',
                                              style: TextStyle(
                                                color: quantity == qty
                                                    ? Colors.green
                                                    : Colors.black,
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
                  ],
                ),

                // ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ D2 и DMiddle (после второго ряда)
                if (selectedMethod != null &&
                    (selectedMethod!
                            .startsWith('Среднеарифметический диаметр') ||
                        selectedMethod!.startsWith('Смалиана') ||
                        selectedMethod!.startsWith('Ньютона')))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              decoration: InputDecoration(labelText: 'd2'.tr()),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                double? val = double.tryParse(value);
                                if (val != null) {
                                  if (diameterUnit == 'см')
                                    diameter2 = val * 10;
                                  else
                                    diameter2 = val;
                                  calculate();
                                }
                              },
                            ),
                          ),
                          if (selectedMethod != null &&
                              selectedMethod!.startsWith('Ньютона')) ...[
                            SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'dMiddle'.tr()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    double? val = double.tryParse(value);
                                    if (val != null) {
                                      if (diameterUnit == 'см')
                                        diameterMiddle = val * 10;
                                      else
                                        diameterMiddle = val;
                                      calculate();
                                    }
                                  }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                // Третий ряд: Вывод объема и цены
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${'volume_label'.tr()}: ${volume.toStringAsFixed(3)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check_circle,
                          color: Theme.of(context).iconTheme.color, size: 40),
                      onPressed: addToTable,
                    ),
                    Expanded(
                      child: Text(
                        '${'price_label'.tr()}: ${totalPrice.toStringAsFixed(2)} $selectedCurrency',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),

                // Таблица
// ... перед DataTable, внутри build:

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primary),
                        headingTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        dataRowColor: MaterialStateProperty.all(
                            Theme.of(context).cardColor),
                        dataTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        dividerThickness: 2,
                        columns: [
                          DataColumn(
                              label: Text(
                                  'number_col'.tr())), // Локализованный номер
                          if (showMethodColumn)
                            DataColumn(label: Text('method_col'.tr())),
                          if (showSpeciesColumn)
                            DataColumn(label: Text('species_col'.tr())),
                          if (showGradeColumn)
                            DataColumn(label: Text('grade_col'.tr())),
                          DataColumn(
                              label:
                                  Text('${'length_col'.tr()} ($lengthUnit)')),
                          DataColumn(
                              label: Text(
                                  '${'diameter_col'.tr()} ($diameterUnit)')),
                          if (showD2)
                            DataColumn(label: Text('d2 ($diameterUnit)')),
                          if (showDMiddle)
                            DataColumn(
                                label:
                                    Text('${'dMiddle'.tr()} ($diameterUnit)')),
                          //if (showDensityColumn) DataColumn(label: Text('density_col'.tr())),
                          DataColumn(label: Text('quantity_col'.tr())),
                          if (showPriceColumn)
                            DataColumn(
                                label: Text(
                                    '${'price_per_m3_col'.tr()} $selectedCurrency')),
                          DataColumn(label: Text('volume_col'.tr())),
                          if (showTotalPriceColumn)
                            DataColumn(
                                label: Text(
                                    '${'total_price_col'.tr()} $selectedCurrency')),
                          if (showGrossWeightColumn)
                            DataColumn(
                                label: Text(
                                    '${'gross_weight_col'.tr()} ($weightUnit)')),
                          if (showNetWeightColumn)
                            DataColumn(
                                label: Text(
                                    '${'net_weight_col'.tr()} ($weightUnit)')),
                          if (showBarkVolumeColumn)
                            DataColumn(label: Text('bark_volume_col'.tr())),
                          DataColumn(label: Text('')), // delete button
                        ],
                        // ...внутри DataTable...
                        rows: tableData.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> row = entry.value;
                          double rowVolume =
                              double.tryParse(row['Объем'] ?? '0') ?? 0;

                          double rowDensity = 600;
                          if (row['Порода'] != null &&
                              speciesDensity.containsKey(row['Порода'])) {
                            rowDensity = speciesDensity[row['Порода']]!;
                          }
                          double barkPercent = 0.0;
                          if (row['Порода'] != null &&
                              speciesData.containsKey(row['Порода'])) {
                            barkPercent = speciesData[row['Порода']] ?? 0.0;
                          }
                          double rowVolumeWithBark =
                              rowVolume * (1 + barkPercent);
                          double rowMoistureCoef = 1 + (woodMoisture / 100);
                          // ...внутри rows: tableData.asMap().entries.map((entry) { ...
                          double rowGrossWeight =
                              (grossWithBark && rowVolumeWithBark > 0
                                          ? rowVolumeWithBark
                                          : rowVolume) *
                                      rowDensity *
                                      rowMoistureCoef +
                                  packageWeight;
                          double rowNetWeight =
                              rowVolume * rowDensity * rowMoistureCoef;

                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            if (showMethodColumn)
                              DataCell(
                                Text(row['Метод'] ?? '-'),
                                showEditIcon: true,
                                onTap: () async {
                                  final newValue = await _editCellDialog(
                                      context, row['Метод'] ?? '');
                                  if (newValue != null) {
                                    setState(() {
                                      row['Метод'] = newValue;
                                      _recalculateRow(row);
                                    });
                                  }
                                },
                              ),
                            if (showSpeciesColumn)
                              DataCell(
                                Text(getSpeciesDisplayName(row['Порода'])),
                                showEditIcon: true,
                                onTap: () async {
                                  final newValue = await _editCellDialog(
                                      context, row['Порода'] ?? '');
                                  if (newValue != null) {
                                    setState(() {
                                      row['Порода'] = newValue;
                                      _recalculateRow(row);
                                    });
                                  }
                                },
                              ),
                            if (showGradeColumn)
                              DataCell(
                                Text(row['Сорт'] ?? '-'),
                                showEditIcon: true,
                                onTap: () async {
                                  final newValue = await _editCellDialog(
                                      context, row['Сорт'] ?? '');
                                  if (newValue != null) {
                                    setState(() {
                                      row['Сорт'] = newValue;
                                      _recalculateRow(row);
                                    });
                                  }
                                },
                              ),
                            DataCell(
                              Text(row['Длина'] ?? '-'),
                              showEditIcon: true,
                              onTap: () async {
                                final newValue = await _editCellDialog(
                                    context, row['Длина'] ?? '');
                                if (newValue != null) {
                                  setState(() {
                                    row['Длина'] = newValue;
                                    _recalculateRow(row);
                                  });
                                }
                              },
                            ),
                            DataCell(
                              Text(row['Диаметр'] != null
                                  ? (diameterUnit == 'см'
                                      ? ((double.tryParse(row['Диаметр']
                                                          ?.toString() ??
                                                      '0') ??
                                                  0) /
                                              10)
                                          .toStringAsFixed(1)
                                      : row['Диаметр'].toString())
                                  : '-'),
                              showEditIcon: true,
                              onTap: () async {
                                final initialValue = diameterUnit == 'см'
                                    ? ((double.tryParse(row['Диаметр']
                                                        ?.toString() ??
                                                    '0') ??
                                                0) /
                                            10)
                                        .toStringAsFixed(1)
                                    : (row['Диаметр']?.toString() ?? '');
                                final newValue = await _editCellDialog(
                                    context, initialValue);
                                if (newValue != null) {
                                  setState(() {
                                    // Сохраняем всегда в мм
                                    row['Диаметр'] = diameterUnit == 'см'
                                        ? (double.tryParse(newValue) ?? 0) * 10
                                        : double.tryParse(newValue) ?? 0;
                                    _recalculateRow(row);
                                  });
                                }
                              },
                            ),
                            if (showD2)
                              (row['Метод'] != null &&
                                      (row['Метод'].toString().startsWith(
                                              'Среднеарифметический диаметр') ||
                                          row['Метод']
                                              .toString()
                                              .startsWith('Смалиана') ||
                                          row['Метод']
                                              .toString()
                                              .startsWith('Ньютона')))
                                  ? DataCell(
                                      Text(row['d2'] != null
                                          ? (diameterUnit == 'см'
                                              ? ((double.tryParse(row['d2'] ??
                                                              '0') ??
                                                          0) /
                                                      10)
                                                  .toStringAsFixed(1)
                                              : row['d2'].toString())
                                          : '-'),
                                      showEditIcon: true,
                                      onTap: () async {
                                        final initialValue = diameterUnit ==
                                                'см'
                                            ? ((double.tryParse(row['Диаметр']
                                                                ?.toString() ??
                                                            '0') ??
                                                        0) /
                                                    10)
                                                .toStringAsFixed(1)
                                            : (row['Диаметр']?.toString() ??
                                                '');
                                        final newValue = await _editCellDialog(
                                            context, initialValue);
                                        if (newValue != null) {
                                          setState(() {
                                            // Сохраняем всегда в мм
                                            row['Диаметр'] = diameterUnit ==
                                                    'см'
                                                ? (double.tryParse(newValue) ??
                                                        0) *
                                                    10
                                                : double.tryParse(newValue) ??
                                                    0;
                                            _recalculateRow(row);
                                          });
                                        }
                                      },
                                    )
                                  : DataCell(Text('-')),
                            if (showDMiddle)
                              (row['Метод'] != null &&
                                      row['Метод']
                                          .toString()
                                          .startsWith('Ньютона'))
                                  ? DataCell(
                                      Text(row['dMiddle'] != null
                                          ? (diameterUnit == 'см'
                                              ? ((double.tryParse(
                                                              row['dMiddle'] ??
                                                                  '0') ??
                                                          0) /
                                                      10)
                                                  .toStringAsFixed(1)
                                              : row['dMiddle'].toString())
                                          : '-'),
                                      showEditIcon: true,
                                      onTap: () async {
                                        final initialValue = diameterUnit ==
                                                'см'
                                            ? ((double.tryParse(row['Диаметр']
                                                                ?.toString() ??
                                                            '0') ??
                                                        0) /
                                                    10)
                                                .toStringAsFixed(1)
                                            : (row['Диаметр']?.toString() ??
                                                '');
                                        final newValue = await _editCellDialog(
                                            context, initialValue);
                                        if (newValue != null) {
                                          setState(() {
                                            // Сохраняем всегда в мм
                                            row['Диаметр'] = diameterUnit ==
                                                    'см'
                                                ? (double.tryParse(newValue) ??
                                                        0) *
                                                    10
                                                : double.tryParse(newValue) ??
                                                    0;
                                            _recalculateRow(row);
                                          });
                                        }
                                      },
                                    )
                                  : DataCell(Text('-')),
                            //if (showDensityColumn)
                            //DataCell(Text(row['Плотность']?.toString() ?? '-')),
                            DataCell(
                              Text(row['Количество'] ?? '-'),
                              showEditIcon: true,
                              onTap: () async {
                                final newValue = await _editCellDialog(
                                    context, row['Количество'] ?? '');
                                if (newValue != null) {
                                  setState(() {
                                    row['Количество'] = newValue;
                                    _recalculateRow(row);
                                  });
                                }
                              },
                            ),
                            if (showPriceColumn)
                              DataCell(
                                Text(row['Цена за м³']?.toString() ?? '-'),
                                showEditIcon: true,
                                onTap: () async {
                                  final newValue = await _editCellDialog(
                                      context,
                                      row['Цена за м³']?.toString() ?? '');
                                  if (newValue != null) {
                                    setState(() {
                                      row['Цена за м³'] = newValue;
                                      _recalculateRow(row);
                                    });
                                  }
                                },
                              ),
                            DataCell(Text(row['Объем'] ?? '-')),
                            if (showTotalPriceColumn)
                              DataCell(Text(
                                  row['Итоговая цена']?.toString() ?? '-')),
                            if (showGrossWeightColumn)
                              DataCell(Text((weightUnit == 'т'
                                      ? (rowGrossWeight / 1000)
                                          .toStringAsFixed(3)
                                      : rowGrossWeight.toStringAsFixed(1)) +
                                  ' $weightUnit')),
                            if (showNetWeightColumn)
                              DataCell(Text((weightUnit == 'т'
                                      ? (rowNetWeight / 1000).toStringAsFixed(3)
                                      : rowNetWeight.toStringAsFixed(1)) +
                                  ' $weightUnit')),
                            if (showBarkVolumeColumn)
                              DataCell(Text(rowVolumeWithBark > 0
                                  ? rowVolumeWithBark.toStringAsFixed(3)
                                  : '-')),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: 'delete_row'.tr(),
                                onPressed: () {
                                  setState(() {
                                    tableData.removeAt(index);
                                    totalVolume = tableData.fold<double>(
                                      0,
                                      (sum, r) =>
                                          sum +
                                          double.tryParse(
                                              r['Объем']?.toString() ?? '0')!,
                                    );
                                    totalSum = tableData.fold<double>(
                                      0,
                                      (sum, row) =>
                                          sum +
                                          (double.tryParse(row['Итоговая цена']
                                                      ?.toString() ??
                                                  '0') ??
                                              0),
                                    );
                                    totalCount = tableData.fold<int>(
                                      0,
                                      (sum, row) =>
                                          sum +
                                          (int.tryParse(row['Количество']
                                                      ?.toString() ??
                                                  '1') ??
                                              1),
                                    );
                                  });
                                  _saveTableToFileInAppFolder(
                                      '_autosave_manual.csv');
                                },
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                if (totalVolume > 0 && showBarkVolumeColumn)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        '${'bark_volume_label'.tr()}: ${totalVolumeWithBark.toStringAsFixed(3)}',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ),

                // ...перед выводом итогов и таблицы...

                if (totalVolume > 0 &&
                    (showNetWeightColumn || showGrossWeightColumn))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (showNetWeightColumn)
                          Text(
                            '${'netto_label'.tr()}: ${netWeightValue.toStringAsFixed(3)} ${_weightUnitTr(context)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        if (showGrossWeightColumn)
                          Text(
                            '${'brutto_label'.tr()}: ${grossWeightValue.toStringAsFixed(3)} ${_weightUnitTr(context)}',
                            style: TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                // Итоги
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
                // Объем с корой (если включено)
                // Кнопки управления
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.save,
                          color: Theme.of(context).iconTheme.color),
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
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              title: Text('save'.tr()),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.save,
                                        color:
                                            Theme.of(context).iconTheme.color),
                                    title: Text('save_to_folder'.tr()),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String? fileName;
                                          return AlertDialog(
                                            backgroundColor: Theme.of(context)
                                                .dialogBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 2,
                                              ),
                                            ),
                                            title: Text('save_table'.tr()),
                                            content: TextFormField(
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'enter_file_name'.tr()),
                                              onChanged: (value) {
                                                fileName = value;
                                              },
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  if (fileName != null &&
                                                      fileName!.isNotEmpty) {
                                                    _saveTableToFileInAppFolder(
                                                        '$fileName.csv');
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: Text('save'.tr()),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('cancel'.tr()),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.cloud_upload,
                                        color: Colors.orange),
                                    title: Text('load_from_folder'.tr()),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _loadTableFromAppFolder();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.picture_as_pdf,
                                        color: Colors.red),
                                    title: Text('export_pdf'.tr()),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      if (AdsController().canUsePremium()) {
                                        _exportToPDF();
                                        AdsController().tryUsePremium();
                                      } else {
                                        final result =
                                            await showRewardedInfoDialog(
                                                context);
                                        if (result == true) {
                                          AdsController()
                                              .showRewardedForPremium(() {
                                            _exportToPDF();
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
                                  ListTile(
                                    leading: Icon(Icons.table_chart,
                                        color: Colors.blue),
                                    title: Text('export_excel'.tr()),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      if (AdsController().canUsePremium()) {
                                        _exportToExcel();
                                        AdsController().tryUsePremium();
                                      } else {
                                        final result =
                                            await showRewardedInfoDialog(
                                                context);
                                        if (result == true) {
                                          AdsController()
                                              .showRewardedForPremium(() {
                                            _exportToExcel();
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
                            );
                          },
                        );
                      },
                    ),
                    Text(
                      '${'volume_label'.tr()}: ${totalVolume.toStringAsFixed(3)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.orange),
                      onPressed: clearTable,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
