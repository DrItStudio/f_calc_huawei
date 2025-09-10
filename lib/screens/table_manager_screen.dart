import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/species_density.dart';
import '../data/species_data.dart';
import '../widgets/main_drawer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../ads_controller.dart';
import '../screens/vip.dart';

class LineData {
  String text;
  String? rightText;
  bool isSplit;
  bool bold;
  bool italic;
  bool strike;
  bool underline;
  TextAlign align;
  TextAlign rightAlign;
  double fontSize;
  LineData({
    this.text = '',
    this.rightText,
    this.isSplit = false,
    this.bold = false,
    this.italic = false,
    this.strike = false,
    this.underline = false,
    this.align = TextAlign.left,
    this.rightAlign = TextAlign.right,
    this.fontSize = 16,
  });
}

List<LineData> _linesFromJson(String? data) {
  if (data == null || data.isEmpty) return [LineData()];
  return data.split('\n').map((line) {
    final parts = line.split('\$');
    if (parts.length < 2) return LineData(text: line);
    final text = parts[0].replaceAll(r'\$', '\$');
    final rightText = parts[1].replaceAll(r'\$', '\$');
    final isSplit = parts.length > 2 ? parts[2] == '1' : false;
    final bold = parts.length > 3 ? parts[3] == '1' : false;
    final italic = parts.length > 4 ? parts[4] == '1' : false;
    final strike = parts.length > 5 ? parts[5] == '1' : false;
    final underline = parts.length > 6 ? parts[6] == '1' : false;
    final alignIndex = parts.length > 7 ? int.tryParse(parts[7]) ?? 0 : 0;
    final rightAlignIndex = parts.length > 8 ? int.tryParse(parts[8]) ?? 2 : 2;
    final fontSize =
        parts.length > 9 ? double.tryParse(parts[9]) ?? 16.0 : 16.0;
    return LineData(
      text: text,
      rightText: rightText.isNotEmpty ? rightText : null,
      isSplit: isSplit,
      bold: bold,
      italic: italic,
      strike: strike,
      underline: underline,
      align: TextAlign.values[alignIndex],
      rightAlign: TextAlign.values[rightAlignIndex],
      fontSize: fontSize,
    );
  }).toList();
}

List<String> selectedSpeciesList = [];

class TableManagerScreen extends StatefulWidget {
  @override
  State<TableManagerScreen> createState() => _TableManagerScreenState();
}

class _TableManagerScreenState extends State<TableManagerScreen> {
  List<String> columnKeys = [
    'method',
    'species',
    'grade',
    'length',
    'diameter',
    'quantity',
    'price_per_m3',
    'volume',
    'volume_with_bark',
    'net_weight',
    'gross_weight',
    'total_price'
  ];

  String selectedCurrency = 'USD'; // Доллар США по умолчанию
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
  ];
  String lengthUnit = 'м';
  String diameterUnit = 'мм';
  String volumeUnit = 'м³';
  String weightUnit = 'кг';
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    s = s.trim().toLowerCase();
    return s[0].toUpperCase() + s.substring(1);
  }

  List<String> columns = [
    'Метод',
    'Порода',
    'Сорт',
    'Длина',
    'Диаметр',
    'Кол-во',
    'Цена за м³',
    'Объем',
    'Объем с корой',
    'Вес нетто',
    'Вес брутто',
    'Итоговая цена'
  ];
  List<List<String>> table = [];
  String? selectedTemplate;
  List<String> templates = [];
  List<LineData> headerLines = [LineData()];
  List<LineData> footerLines = [LineData()];
  String? logoPath;
  double logoWidth = 48;
  double logoHeight = 48;
  bool alignLogoAndHeader = false;
  // Внутри _TableManagerScreenState:
  double get totalSum {
    int sumIdx =
        columns.indexWhere((c) => c.trim().toLowerCase() == 'итоговая цена');
    double sum = 0;
    for (final row in table) {
      if (sumIdx != -1 && sumIdx < row.length) {
        sum += double.tryParse(row[sumIdx].replaceAll(',', '.')) ?? 0;
      }
    }
    return sum;
  }

  double get totalVolume {
    int volIdx = columns.indexWhere((c) => c.trim().toLowerCase() == 'объем');
    double sum = 0;
    for (final row in table) {
      if (volIdx != -1 && volIdx < row.length) {
        sum += double.tryParse(row[volIdx]) ?? 0;
      }
    }
    return sum;
  }

  double get totalCount {
    int qtyIdx = columns.indexWhere((c) {
      final name = c.trim().toLowerCase();
      return name == 'кол-во' || name == 'количество' || name == 'quantity';
    });
    double sum = 0;
    for (final row in table) {
      print('Кол-во: ${row[qtyIdx]}');
      final val = row[qtyIdx];
      final parsed = double.tryParse(val.replaceAll(',', '.'));
      sum += parsed ?? 1;
    }
    print('Итоговое количество: $sum');
    return sum;
  }

  final Map<String, TextEditingController> _controllers = {};

  Widget _buildFormattedLines(List<LineData> lines, {double fontSize = 18}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.isSplit) {
          // Две части: левая и правая
          return Row(
            children: [
              Container(
                width: 200,
                child: Text(
                  line.text,
                  style: TextStyle(
                    fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
                    fontStyle:
                        line.italic ? FontStyle.italic : FontStyle.normal,
                    decoration: line.strike
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              Container(
                width: 200,
                child: Text(
                  line.rightText ?? '',
                  style: TextStyle(
                    fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
                    fontStyle:
                        line.italic ? FontStyle.italic : FontStyle.normal,
                    decoration: line.strike
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          );
        } else {
          // Одна часть: выравнивание по шаблону
          return Container(
            width: 400,
            child: Text(
              line.text,
              style: TextStyle(
                fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
                fontStyle: line.italic ? FontStyle.italic : FontStyle.normal,
                decoration: line.strike
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                fontSize: fontSize,
              ),
              textAlign: line.align,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    table = [];
    _loadTemplates();
    _autoLoadTable();
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

  Future<void> _autoSaveTable() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('table_columns', columns);
    prefs.setStringList('table_column_keys', columnKeys);
    prefs.setStringList('table_data', table.expand((row) => row).toList());
    prefs.setString('selected_currency', selectedCurrency.toUpperCase());
  }

  void _autoLoadTable() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCols = prefs.getStringList('table_columns');
    final savedKeys = prefs.getStringList('table_column_keys');
    final savedData = prefs.getStringList('table_data');
    final savedCurrency = prefs.getString('selected_currency');
    if (savedCurrency != null) selectedCurrency = savedCurrency.toUpperCase();

    if (savedCols != null &&
        savedData != null &&
        savedData.length % savedCols.length == 0) {
      setState(() {
        columns = List<String>.from(savedCols);
        if (savedKeys != null && savedKeys.length == savedCols.length) {
          columnKeys = List<String>.from(savedKeys);
        }
        table = [];
        for (int i = 0; i < savedData.length; i += savedCols.length) {
          // Берём только те значения, что соответствуют текущим столбцам
          var row = savedData.sublist(i, i + savedCols.length).toList();
          // Если вдруг столбцов стало меньше — обрезаем строку
          if (row.length > columns.length) {
            row = row.sublist(0, columns.length);
          }
          // Если столбцов стало больше — добавляем пустые значения
          while (row.length < columns.length) row.add('');
          table.add(row);
        }
      });
    }
  }

  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList('doc_templates') ?? [];
    templates = List<String>.from(names);

    setState(() {
      selectedTemplate = templates.isNotEmpty ? templates.first : null;
      if (selectedTemplate != null) {
        _applyTemplate(selectedTemplate!);
      }
    });
  }

  Future<void> _applyTemplate(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final headerData = prefs.getString('header_lines_$name');
    final footerData = prefs.getString('footer_lines_$name');
    if (headerData != null && footerData != null) {
      headerLines = _linesFromJson(headerData);
      footerLines = _linesFromJson(footerData);
      logoPath = prefs.getString('logo_path_$name');
      logoWidth = prefs.getDouble('logo_width_$name') ?? 48;
      logoHeight = prefs.getDouble('logo_height_$name') ?? 48;
      alignLogoAndHeader = prefs.getBool('align_logo_header_$name') ?? false;
    } else {
      headerLines = [LineData()];
      footerLines = [LineData()];
      logoPath = null;
      logoWidth = 48;
      logoHeight = 48;
      alignLogoAndHeader = false;
    }
    setState(() {
      selectedTemplate = name;
    });
  }

  void _removeRow(int index) {
    setState(() {
      table.removeAt(index);
      _autoSaveTable();
    });
  }

  void _removeColumn(int colIndex) {
    final colName = columns[colIndex].trim().toLowerCase();
    if (colName == 'длина' ||
        colName == 'диаметр' ||
        colName == 'кол-во' ||
        colName == 'объем') return;
    setState(() {
      columns.removeAt(colIndex);
      if (columnKeys.length > colIndex) columnKeys.removeAt(colIndex);
      for (var row in table) {
        if (colIndex < row.length) {
          row.removeAt(colIndex);
        }
      }
      _autoSaveTable();
    });
  }

  void _clearTable() {
    setState(() {
      columns = [
        'Метод',
        'Порода',
        'Сорт',
        'Длина',
        'Диаметр',
        'Кол-во',
        'Цена за м³',
        'Объем',
        'Объем с корой',
        'Вес нетто',
        'Вес брутто',
        'Итоговая цена'
      ];
      columnKeys = [
        'method',
        'species',
        'grade',
        'length',
        'diameter',
        'quantity',
        'price_per_m3',
        'volume',
        'volume_with_bark',
        'net_weight',
        'gross_weight',
        'total_price'
      ];
      table.clear();
      _autoSaveTable();
    });
  }

  Future<void> _saveTable() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/wood_tables');
    if (!await tablesDir.exists()) {
      await tablesDir.create(recursive: true);
    }
    final now = DateTime.now();
    final dateStr =
        '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}';
    final fileName = 'tm_data_${dateStr}_$timeStr.csv';
    final file = File('${tablesDir.path}/$fileName');

    // Преобразуем headerLines и footerLines в строки
    final headerRows = headerLines
        .where((line) =>
            line.text.isNotEmpty || (line.rightText?.isNotEmpty ?? false))
        .map((line) => line.isSplit
            ? 'HEADER:${line.text}\$${line.rightText ?? ''}'
            : 'HEADER:${line.text}')
        .toList();

    final footerRows = footerLines
        .where((line) =>
            line.text.isNotEmpty || (line.rightText?.isNotEmpty ?? false))
        .map((line) => line.isSplit
            ? 'FOOTER:${line.text}\$${line.rightText ?? ''}'
            : 'FOOTER:${line.text}')
        .toList();

    // Первая строка — шаблон
    final templateLine = 'TEMPLATE:${selectedTemplate ?? ""}';

    // Заголовки
    final csvHeader = [
      for (int i = 0; i < columns.length; i++)
        (columnKeys.length > i
            ? columnKeys[i].tr() +
                ((columnKeys[i] == 'price_per_m3' ||
                        columnKeys[i] == 'total_price')
                    ? ' ($selectedCurrency)'
                    : '')
            : columns[i])
    ].join(',');

    // Данные
    final dataRows = table.map((row) => row.join(',')).toList();

    // Собираем всё вместе
    final csvRows = [
      ...headerRows,
      templateLine,
      csvHeader,
      ...dataRows,
      ...footerRows,
    ];

    await file.writeAsString(csvRows.join('\n'));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('table_saved'.tr())));
  }

  Future<void> _showLoadDialog() async {
    final dir = await getApplicationDocumentsDirectory();
    final List<File> files = [];

    // Собираем все .csv из нужных папок
    final manualDir = Directory('${dir.path}/tables/mm');
    if (await manualDir.exists()) {
      files.addAll(manualDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.csv')));
    }
    final bfDir = Directory('${dir.path}/tables/bf');
    if (await bfDir.exists()) {
      files.addAll(bfDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.csv')));
    }
    final templatesDir = Directory('${dir.path}/wood_tables');
    if (await templatesDir.exists()) {
      files.addAll(templatesDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.csv')));
    }

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_saved_tables'.tr())),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('choose_table'.tr()),
        children: files
            .map((f) => SimpleDialogOption(
                child: Text(f.uri.pathSegments.last),
                onPressed: () async {
                  Navigator.pop(context);
                  final content = await f.readAsString();
                  final lines = content
                      .split('\n')
                      .where((e) => e.trim().isNotEmpty)
                      .toList();
                  if (lines.isEmpty) return;

                  int dataStart = 0;
                  // Если первая строка — шаблон
                  if (lines.first.startsWith('TEMPLATE:')) {
                    final templateName = lines.first.substring(9).trim();
                    if (templateName.isNotEmpty) {
                      await _applyTemplate(templateName);
                    }
                    dataStart = 1;
                  }

                  final delimiter = lines[dataStart].contains(';') ? ';' : ',';
                  final fileHeaders = lines[dataStart]
                      .split(delimiter)
                      .map((h) => h.trim())
                      .toList();

                  // --- Определение единиц измерения ---
                  for (final h in fileHeaders) {
                    final hNorm =
                        h.replaceAll(RegExp(r'[().]'), '').toLowerCase();
                    if (hNorm.contains('длина') && hNorm.contains('ft'))
                      lengthUnit = 'ft';
                    else if (hNorm.contains('длина') && hNorm.contains('см'))
                      lengthUnit = 'см';
                    else if (hNorm.contains('длина') && hNorm.contains('in'))
                      lengthUnit = 'in';
                    else if (hNorm.contains('длина') && hNorm.contains('м'))
                      lengthUnit = 'м';

                    if (hNorm.contains('диаметр') && hNorm.contains('in'))
                      diameterUnit = 'in';
                    else if (hNorm.contains('диаметр') && hNorm.contains('см'))
                      diameterUnit = 'см';
                    else if (hNorm.contains('диаметр') && hNorm.contains('мм'))
                      diameterUnit = 'мм';

                    if (hNorm.contains('объем') &&
                        (hNorm.contains('ft3') || hNorm.contains('cu ft')))
                      volumeUnit = 'ft³';
                    else if (hNorm.contains('объем') && hNorm.contains('м3'))
                      volumeUnit = 'м³';

                    if (hNorm.contains('вес') &&
                        (hNorm.contains('lbs') || hNorm.contains('lb')))
                      weightUnit = 'lbs';
                    else if (hNorm.contains('вес') && hNorm.contains('т'))
                      weightUnit = 'т';
                    else if (hNorm.contains('вес') && hNorm.contains('кг'))
                      weightUnit = 'кг';
                  }
                  setState(() {});

                  // Обновляем список столбцов на основании файла
                  setState(() {
                    columns = List<String>.from(fileHeaders);
                  });

                  final List<List<String>> loaded = [];
                  for (var i = dataStart + 1; i < lines.length; i++) {
                    final cells =
                        lines[i].split(delimiter).map((c) => c.trim()).toList();
                    final row = List.filled(columns.length, '');
                    for (int j = 0; j < fileHeaders.length; j++) {
                      if (j < cells.length) row[j] = cells[j];
                    }
                    final qtyIdx = columns.indexWhere((col) {
                      final name = col.trim().toLowerCase();
                      return name == 'кол-во' ||
                          name == 'количество' ||
                          name == 'quantity';
                    });
                    print('qtyIdx: $qtyIdx, columns: $columns');
                    if (qtyIdx != -1) {
                      // Если пусто или не число — подставить 1
                      final val = row[qtyIdx];
                      if (val.isEmpty ||
                          double.tryParse(val.replaceAll(',', '.')) == null) {
                        row[qtyIdx] = '1';
                      }
                    }
                    while (row.length < columns.length) row.add('');
                    if (row.length > columns.length)
                      row.removeRange(columns.length, row.length);
                    loaded.add(row);
                  }
                  setState(() {
                    table = loaded;
                    _recalculateTable();
                    _controllers.clear();
                    _autoSaveTable();
                  });

                  // Сохраняем новые столбцы
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setStringList('table_columns', columns);
                }))
            .toList(),
      ),
    );
  }

  void _mergeRows() {
    // Привести все строки к одинаковой длине
    for (var row in table) {
      while (row.length < columns.length) row.add('');
      if (row.length > columns.length)
        row.removeRange(columns.length, row.length);
    }

    int qtyIdx = columns.indexWhere((c) => c.trim().toLowerCase() == 'кол-во');
    int volIdx = columns.indexWhere((c) => c.trim().toLowerCase() == 'объем');
    int sumIdx =
        columns.indexWhere((c) => c.trim().toLowerCase() == 'итоговая цена');
    // Исключаем также "№", "номер", "id" из ключа!
    List<int> keyIndexes = List.generate(columns.length, (i) => i)
        .where((i) =>
            i != qtyIdx &&
            i != volIdx &&
            i != sumIdx &&
            columns[i].trim().toLowerCase() != '№' &&
            columns[i].trim().toLowerCase() != 'номер' &&
            columns[i].trim().toLowerCase() != 'id')
        .toList();

    Map<String, List<String>> merged = {};
    for (var row in table) {
      final key = keyIndexes.map((i) {
        String value = i < row.length ? row[i] : '';
        value = value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        if (double.tryParse(value.replaceAll(',', '.')) != null) {
          value = double.parse(value.replaceAll(',', '.')).toStringAsFixed(3);
        }
        return value;
      }).join(';');

      double qty = (qtyIdx != -1 && qtyIdx < row.length)
          ? double.tryParse(row[qtyIdx].replaceAll(',', '.')) ?? 0
          : 0;
      double volume = (volIdx != -1 && volIdx < row.length)
          ? double.tryParse(row[volIdx].replaceAll(',', '.')) ?? 0
          : 0;
      double sum = (sumIdx != -1 && sumIdx < row.length)
          ? double.tryParse(row[sumIdx].replaceAll(',', '.')) ?? 0
          : 0;

      if (merged.containsKey(key)) {
        final m = merged[key]!;
        // Суммируем количество как double!
        if (qtyIdx != -1 && qtyIdx < m.length) {
          double prevQty = double.tryParse(m[qtyIdx].replaceAll(',', '.')) ?? 0;
          m[qtyIdx] = (prevQty + qty).toStringAsFixed(3);
        }
        if (volIdx != -1 && volIdx < m.length) {
          double prevVol = double.tryParse(m[volIdx].replaceAll(',', '.')) ?? 0;
          m[volIdx] = (prevVol + volume).toStringAsFixed(3);
        }
        if (sumIdx != -1 && sumIdx < m.length) {
          double prevSum = double.tryParse(m[sumIdx].replaceAll(',', '.')) ?? 0;
          m[sumIdx] = (prevSum + sum).toStringAsFixed(2);
        }
      } else {
        merged[key] = List<String>.from(row);
      }
    }

    setState(() {
      table = merged.values.toList();
      _recalculateTable();
      _controllers.clear();
      _autoSaveTable();
    });
  }

  void _recalculateTable() {
    int dIdx = columns.indexWhere((c) => c.trim().toLowerCase() == 'диаметр');
    int lIdx = columns.indexWhere((c) => c.trim().toLowerCase() == 'длина');
    int qtyIdx = columns.indexWhere((c) => c.trim().toLowerCase() == 'кол-во');
    int priceIdx =
        columns.indexWhere((c) => c.trim().toLowerCase() == 'цена за м³');
    int volIdx = columns.indexWhere((c) => c.trim().toLowerCase() == 'объем');
    int volBarkIdx =
        columns.indexWhere((c) => c.trim().toLowerCase() == 'объем с корой');
    int netIdx =
        columns.indexWhere((c) => c.trim().toLowerCase() == 'вес нетто');
    int grossIdx =
        columns.indexWhere((c) => c.trim().toLowerCase() == 'вес брутто');
    int sumIdx =
        columns.indexWhere((c) => c.trim().toLowerCase() == 'итоговая цена');
    for (var row in table) {
      if ([dIdx, lIdx, qtyIdx, priceIdx, volIdx, sumIdx]
          .any((idx) => idx == -1 || idx >= row.length)) continue;
      double d = double.tryParse(row[dIdx].replaceAll(',', '.')) ?? 0;
      double l = double.tryParse(row[lIdx].replaceAll(',', '.')) ?? 0;
      double qty = double.tryParse(row[qtyIdx].replaceAll(',', '.')) ?? 1;
      double price = double.tryParse(row[priceIdx].replaceAll(',', '.')) ?? 0;
      double volume = 3.1415926535 * (d / 200) * (d / 200) * l * qty;
      row[volIdx] = volume.toStringAsFixed(3);

      // Объем с корой (например, +7% если не задано иначе)
      double barkPercent = 0.07;
      int speciesIdx =
          columns.indexWhere((c) => c.trim().toLowerCase() == 'порода');
      if (speciesIdx != -1 && speciesIdx < row.length) {
        // если есть карта speciesData, используйте ее
        // barkPercent = speciesData[row[speciesIdx]] ?? 0.07;
      }
      if (volBarkIdx != -1 && volBarkIdx < row.length) {
        row[volBarkIdx] = (volume * (1 + barkPercent)).toStringAsFixed(3);
      }

      // Вес нетто и брутто (пример: плотность 600, влажность 20%, упаковка 0)
      double density = 600;
      double moisture = 0.2;
      double packageWeight = 0;
      if (netIdx != -1 && netIdx < row.length) {
        row[netIdx] = (volume * density * (1 + moisture)).toStringAsFixed(1);
      }
      if (grossIdx != -1 && grossIdx < row.length) {
        row[grossIdx] =
            ((volume * (1 + barkPercent)) * density * (1 + moisture) +
                    packageWeight)
                .toStringAsFixed(1);
      }

      row[sumIdx] = (volume * price).toStringAsFixed(2);
    }
  }

  Future<pw.Font> _loadFont() async {
    final data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    return pw.Font.ttf(data);
  }

  List<List<String>> _tableWithTotals() {
    final totals = List<String>.filled(columns.length, '');
    double totalVolumeWithBark = 0;
    double totalNetWeight = 0;
    double totalGrossWeight = 0;

    for (final row in table) {
      for (int i = 0; i < columns.length; i++) {
        final col = columns[i].trim().toLowerCase();
        if (col == 'объем с корой') {
          totalVolumeWithBark += double.tryParse(row[i]) ?? 0;
        }
        if (col == 'вес нетто') {
          totalNetWeight += double.tryParse(row[i]) ?? 0;
        }
        if (col == 'вес брутто') {
          totalGrossWeight += double.tryParse(row[i]) ?? 0;
        }
      }
    }

    for (int i = 0; i < columns.length; i++) {
      final col = columns[i].trim().toLowerCase();
      if (col == 'кол-во') totals[i] = '$totalCount';
      if (col == 'объем') totals[i] = totalVolume.toStringAsFixed(3);
      if (col == 'объем с корой')
        totals[i] = totalVolumeWithBark.toStringAsFixed(3);
      if (col == 'вес нетто') totals[i] = totalNetWeight.toStringAsFixed(1);
      if (col == 'вес брутто') totals[i] = totalGrossWeight.toStringAsFixed(1);
      if (col == 'итоговая цена') totals[i] = totalSum.toStringAsFixed(2);
      if (i == 0) totals[i] = 'total'.tr();
    }

    final data = table.map((row) {
      final fixedRow = List<String>.from(row);
      while (fixedRow.length < columns.length) fixedRow.add('');
      if (fixedRow.length > columns.length)
        fixedRow.removeRange(columns.length, fixedRow.length);
      return [
        for (int i = 0; i < fixedRow.length; i++)
          columns[i].trim().toLowerCase() == 'порода'
              ? fixedRow[i].tr()
              : fixedRow[i]
      ];
    }).toList();
    return [...data, totals];
  }

  Future<void> _exportPdf() async {
    final font = await _loadFont();
    final pdf = pw.Document();

    Uint8List? logoBytes;
    if (logoPath != null &&
        logoPath!.isNotEmpty &&
        File(logoPath!).existsSync()) {
      logoBytes = await File(logoPath!).readAsBytes();
    }

    // --- Определяем размер шрифта ---
    final int rowCount = _tableWithTotals().length;
    final int colCount = columns.length;
    double fontSize;
    if (rowCount > 40 || colCount > 10) {
      fontSize = 8;
    } else if (rowCount > 25 || colCount > 7) {
      fontSize = 10;
    } else {
      fontSize = 12;
    }

    pw.Widget buildFormattedLinesPdf(List<LineData> lines,
        {double? fontSizeOverride}) {
      return pw.Column(
        children: lines.map((line) {
          if (line.isSplit) {
            return pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    line.text,
                    style: pw.TextStyle(
                      fontWeight:
                          line.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                      fontStyle: line.italic
                          ? pw.FontStyle.italic
                          : pw.FontStyle.normal,
                      decoration: line.strike
                          ? pw.TextDecoration.lineThrough
                          : pw.TextDecoration.none,
                      fontSize: fontSizeOverride ?? fontSize,
                    ),
                    textAlign: pw.TextAlign.left,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    line.rightText ?? '',
                    style: pw.TextStyle(
                      fontWeight:
                          line.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                      fontStyle: line.italic
                          ? pw.FontStyle.italic
                          : pw.FontStyle.normal,
                      decoration: line.strike
                          ? pw.TextDecoration.lineThrough
                          : pw.TextDecoration.none,
                      fontSize: fontSizeOverride ?? fontSize,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            );
          } else {
            return pw.Align(
              alignment: () {
                switch (line.align) {
                  case TextAlign.center:
                    return pw.Alignment.center;
                  case TextAlign.right:
                    return pw.Alignment.centerRight;
                  default:
                    return pw.Alignment.centerLeft;
                }
              }(),
              child: pw.Text(
                line.text,
                style: pw.TextStyle(
                  fontWeight:
                      line.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  fontStyle:
                      line.italic ? pw.FontStyle.italic : pw.FontStyle.normal,
                  decoration: line.strike
                      ? pw.TextDecoration.lineThrough
                      : pw.TextDecoration.none,
                  fontSize: fontSizeOverride ?? fontSize,
                ),
                textAlign: () {
                  switch (line.align) {
                    case TextAlign.center:
                      return pw.TextAlign.center;
                    case TextAlign.right:
                      return pw.TextAlign.right;
                    default:
                      return pw.TextAlign.left;
                  }
                }(),
              ),
            );
          }
        }).toList(),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        build: (context) => [
          if (logoBytes != null && alignLogoAndHeader)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                    child: buildFormattedLinesPdf(headerLines,
                        fontSizeOverride: fontSize)),
                pw.SizedBox(width: 12),
                pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: logoWidth,
                  height: logoHeight,
                ),
              ],
            ),
          if (logoBytes != null && !alignLogoAndHeader)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: logoWidth,
                  height: logoHeight,
                ),
              ],
            ),
          if (logoBytes == null || !alignLogoAndHeader)
            buildFormattedLinesPdf(headerLines, fontSizeOverride: fontSize),
          pw.SizedBox(height: 8),
          pw.Text(
              '${'date'.tr()}: ${DateTime.now().toString().substring(0, 10)}'),
          pw.Divider(),
          pw.Table.fromTextArray(
            headers: [
              for (int i = 0; i < columns.length; i++)
                columns[i] == 'Длина'
                    ? '${columns[i].tr()} ($lengthUnit)'
                    : columns[i] == 'Диаметр'
                        ? '${columns[i].tr()} ($diameterUnit)'
                        : columns[i] == 'Объем' || columns[i] == 'Объем с корой'
                            ? '${columns[i].tr()} ($volumeUnit)'
                            : columns[i] == 'Вес нетто' ||
                                    columns[i] == 'Вес брутто'
                                ? '${columns[i].tr()} ($weightUnit)'
                                : columns[i] == 'Цена за м³'
                                    ? '${columns[i].tr()} ($selectedCurrency)'
                                    : columns[i] == 'Итоговая цена'
                                        ? '${columns[i].tr()} ($selectedCurrency)'
                                        : columns[i].tr()
            ],
            data: _tableWithTotals(),
            cellStyle: pw.TextStyle(font: font, fontSize: fontSize),
            headerStyle: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                fontSize: fontSize + 1),
          ),
          if (footerLines.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Divider(),
            buildFormattedLinesPdf(footerLines, fontSizeOverride: fontSize - 1),
          ],
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'table_export.pdf');
  }

  String getColumnHeader(int i) {
    if (columns[i] == 'Длина') {
      return '${columns[i]} ($lengthUnit)';
    } else if (columns[i] == 'Диаметр') {
      return '${columns[i]} ($diameterUnit)';
    } else if (columns[i] == 'Объем' || columns[i] == 'Объем с корой') {
      return '${columns[i]} ($volumeUnit)';
    } else if (columns[i] == 'Вес нетто' || columns[i] == 'Вес брутто') {
      return '${columns[i]} ($weightUnit)';
    } else if (columns[i] == 'Цена за м³' || columns[i] == 'Итоговая цена') {
      return '${columns[i]} ($selectedCurrency)';
    } else {
      return columns[i];
    }
  }

  Future<void> _exportExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Шапка из шаблона
    for (final line in headerLines) {
      if (line.isSplit) {
        sheet.appendRow(
            [TextCellValue(line.text), TextCellValue(line.rightText ?? '')]);
      } else {
        sheet.appendRow([TextCellValue(line.text)]);
      }
    }

    // Заголовки таблицы с единицами измерения и валютой
    sheet.appendRow([
      for (int i = 0; i < columns.length; i++) TextCellValue(getColumnHeader(i))
    ]);
    // Данные таблицы с итогами
    for (final row in _tableWithTotals()) {
      sheet.appendRow([for (final cell in row) TextCellValue(cell)]);
    }

    // Подвал из шаблона
    for (final line in footerLines) {
      if (line.isSplit) {
        sheet.appendRow(
            [TextCellValue(line.text), TextCellValue(line.rightText ?? '')]);
      } else {
        sheet.appendRow([TextCellValue(line.text)]);
      }
    }

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/table_export_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(file.path)], text: 'export_excel'.tr());
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        title: Text('preview'.tr()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (logoPath != null &&
                  logoPath!.isNotEmpty &&
                  alignLogoAndHeader)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormattedLines(headerLines),
                      SizedBox(width: 12),
                      Image.file(
                        File(logoPath!),
                        width: logoWidth,
                        height: logoHeight,
                      ),
                    ],
                  ),
                ),
              if (logoPath != null &&
                  logoPath!.isNotEmpty &&
                  !alignLogoAndHeader)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormattedLines(headerLines),
                      SizedBox(width: 12),
                      Image.file(
                        File(logoPath!),
                        width: logoWidth,
                        height: logoHeight,
                      ),
                    ],
                  ),
                ),
              if (logoPath == null || logoPath!.isEmpty || !alignLogoAndHeader)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildFormattedLines(headerLines),
                ),
              SizedBox(height: 8),
              Text(
                  '${'date'.tr()}: ${DateTime.now().toString().substring(0, 10)}\n'),
              Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                  headingTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  dataRowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.surface),
                  dataTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  columns: [
                    for (int i = 0; i < columns.length; i++)
                      DataColumn(
                        label: Text(
                          columns[i] == 'Длина'
                              ? '${columns[i].tr()} ($lengthUnit)'
                              : columns[i] == 'Диаметр'
                                  ? '${columns[i].tr()} ($diameterUnit)'
                                  : columns[i] == 'Объем' ||
                                          columns[i] == 'Объем с корой'
                                      ? '${columns[i].tr()} ($volumeUnit)'
                                      : columns[i] == 'Вес нетто' ||
                                              columns[i] == 'Вес брутто'
                                          ? '${columns[i].tr()} ($weightUnit)'
                                          : columns[i].tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                  rows: [
                    for (var row in table)
                      DataRow(
                        cells: [
                          for (int col = 0; col < columns.length; col++)
                            DataCell(
                              col < row.length
                                  ? (() {
                                      final colName =
                                          columns[col].trim().toLowerCase();
                                      if (colName == 'порода' ||
                                          colName == 'species' ||
                                          colName == 'метод' ||
                                          colName == 'method') {
                                        return Text(row[col].tr());
                                      } else {
                                        return Text(row[col]);
                                      }
                                    })()
                                  : const Text(''),
                            ),
                        ],
                      ),
                    // Итоговая строка
                    DataRow(
                      color: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.surface),
                      cells: [
                        for (int i = 0; i < columns.length; i++)
                          if (i == 0)
                            DataCell(Text(
                              'total'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ))
                          else if (columns[i].trim().toLowerCase() ==
                                  'кол-во' ||
                              columns[i].trim().toLowerCase() == 'количество')
                            DataCell(Text(
                              totalCount.toStringAsFixed(3),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ))
                          else if (columns[i].trim().toLowerCase() == 'объем')
                            DataCell(Text('${totalVolume.toStringAsFixed(3)}',
                                style: TextStyle(fontWeight: FontWeight.bold)))
                          else if (columns[i].trim().toLowerCase() ==
                              'объем с корой')
                            DataCell(Text(
                              '${_tableWithTotals().last[i]}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ))
                          else if (columns[i].trim().toLowerCase() ==
                              'вес нетто')
                            DataCell(Text(
                              '${_tableWithTotals().last[i]}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ))
                          else if (columns[i].trim().toLowerCase() ==
                              'вес брутто')
                            DataCell(Text(
                              '${_tableWithTotals().last[i]}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ))
                          else if (columns[i].trim().toLowerCase() ==
                              'итоговая цена')
                            DataCell(Text('${totalSum.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold)))
                          else
                            DataCell(Text('')),
                      ],
                    ),
                  ],
                ),
              ),
              if (footerLines.isNotEmpty) ...[
                SizedBox(height: 8),
                Divider(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildFormattedLines(footerLines, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'export_pdf'.tr(),
            onPressed: () async {
              if (AdsController().canUsePremium()) {
                await _exportPdf();
                AdsController().tryUsePremium();
              } else {
                final result = await showRewardedInfoDialog(context);
                if (result == true) {
                  AdsController().showRewardedForPremium(() async {
                    await _exportPdf();
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
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: 'export_excel'.tr(),
            onPressed: () async {
              if (AdsController().canUsePremium()) {
                await _exportExcel();
                AdsController().tryUsePremium();
              } else {
                final result = await showRewardedInfoDialog(context);
                if (result == true) {
                  AdsController().showRewardedForPremium(() async {
                    await _exportExcel();
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
          IconButton(
            icon: Icon(Icons.print),
            tooltip: 'print'.tr(),
            onPressed: () async {
              if (AdsController().canUsePremium()) {
                await _exportPdf();
                AdsController().tryUsePremium();
              } else {
                final result = await showRewardedInfoDialog(context);
                if (result == true) {
                  AdsController().showRewardedForPremium(() async {
                    await _exportPdf();
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
          TextButton(
            child: Text('close'.tr()),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'table_editor'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                minFontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.preview),
            tooltip: 'preview'.tr(),
            onPressed: _showPreview,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.description),
            tooltip: 'select_template'.tr(),
            onSelected: (val) => _applyTemplate(val),
            itemBuilder: (context) => templates
                .map((t) => PopupMenuItem(value: t, child: Text(t)))
                .toList(),
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      drawer: MainDrawer(
        currentScreen: 'table_editor',
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: currencies.contains(selectedCurrency)
                        ? selectedCurrency
                        : 'usd',
                    items: currencies
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedCurrency = val;
                          _autoSaveTable();
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.merge_type),
                    tooltip: 'merge_rows'.tr(),
                    onPressed: _mergeRows,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_sweep),
                    tooltip: 'clear_table'.tr(),
                    onPressed: _clearTable,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: // ...existing code...
                      DataTable(
                    headingRowColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                    headingTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    dataRowColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.surface),
                    dataTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    columns: [
                      for (int i = 0; i < columns.length; i++)
                        DataColumn(
                          label: Row(
                            children: [
                              Text(
                                columns[i] == 'Длина'
                                    ? '${columns[i].tr()} ($lengthUnit)'
                                    : columns[i] == 'Диаметр'
                                        ? '${columns[i].tr()} ($diameterUnit)'
                                        : columns[i] == 'Объем' ||
                                                columns[i] == 'Объем с корой'
                                            ? '${columns[i].tr()} ($volumeUnit)'
                                            : columns[i] == 'Вес нетто' ||
                                                    columns[i] == 'Вес брутто'
                                                ? '${columns[i].tr()} ($weightUnit)'
                                                : columns[i] == 'Цена за м³'
                                                    ? '${columns[i].tr()} ($selectedCurrency)'
                                                    : columns[i] ==
                                                            'Итоговая цена'
                                                        ? '${columns[i].tr()} ($selectedCurrency)'
                                                        : columns[i].tr(),
                              ),
                              if (columns.length > 1 &&
                                  columns[i].trim().toLowerCase() != 'длина' &&
                                  columns[i].trim().toLowerCase() !=
                                      'диаметр' &&
                                  columns[i].trim().toLowerCase() != 'кол-во' &&
                                  columns[i].trim().toLowerCase() != 'объем')
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red, size: 18),
                                  tooltip: 'delete_column'.tr(),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () => _removeColumn(i),
                                ),
                            ],
                          ),
                        ),
                      DataColumn(label: Text('actions'.tr())),
                    ],
                    rows: [
                      for (int row = 0; row < table.length; row++)
                        DataRow(
                          cells: [
                            for (int col = 0; col < columns.length; col++)
                              DataCell(
                                (() {
                                  final colName =
                                      columns[col].trim().toLowerCase();
                                  final editable = colName == 'цена за м³' ||
                                      colName == 'кол-во' ||
                                      colName == 'сорт';
                                  if (editable) {
                                    final key = '$row-$col';
                                    _controllers.putIfAbsent(
                                        key,
                                        () => TextEditingController(
                                            text: table[row][col]));
                                    final controller = _controllers[key]!;
                                    if (controller.text != table[row][col]) {
                                      controller.text = table[row][col];
                                      controller.selection =
                                          TextSelection.collapsed(
                                              offset: controller.text.length);
                                    }
                                    return TextFormField(
                                      controller: controller,
                                      onChanged: (val) {
                                        // Если пусто или не число — подставить 1
                                        final fixed = double.tryParse(
                                                        val.replaceAll(
                                                            ',', '.')) ==
                                                    null ||
                                                val.isEmpty
                                            ? '1'
                                            : val;
                                        table[row][col] = fixed;
                                        setState(() {});
                                        _autoSaveTable();
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none),
                                    );
                                  } else if (colName == 'порода' ||
                                      colName == 'species' ||
                                      colName == 'метод' ||
                                      colName == 'method') {
                                    return Text(table[row][col].trim().tr());
                                  } else {
                                    return Text(table[row][col]);
                                  }
                                })(),
                              ),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeRow(row),
                                tooltip: 'delete_row'.tr(),
                              ),
                            ),
                          ],
                        ),
// ...existing code...
                      DataRow(
                        color: MaterialStateProperty.all(Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.15)),
                        cells: [
                          for (int i = 0; i < columns.length; i++)
                            if (i == 0)
                              DataCell(Text(
                                'total'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ))
                            else if (columns[i].trim().toLowerCase() ==
                                    'кол-во' ||
                                columns[i].trim().toLowerCase() == 'количество')
                              DataCell(Text(
                                totalCount.toStringAsFixed(3),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ))
                            else if (columns[i].trim().toLowerCase() == 'объем')
                              DataCell(Text('${totalVolume.toStringAsFixed(3)}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))
                            else if (columns[i].trim().toLowerCase() ==
                                'объем с корой')
                              DataCell(Text(
                                '${_tableWithTotals().last[i]}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                            else if (columns[i].trim().toLowerCase() ==
                                'вес нетто')
                              DataCell(Text(
                                '${_tableWithTotals().last[i]}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                            else if (columns[i].trim().toLowerCase() ==
                                'вес брутто')
                              DataCell(Text(
                                '${_tableWithTotals().last[i]}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                            else if (columns[i].trim().toLowerCase() ==
                                'итоговая цена')
                              DataCell(Text('${totalSum.toStringAsFixed(2)}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))
                            else
                              DataCell(Text('')),
                          DataCell(Text('')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.folder_open),
                    tooltip: 'load'.tr(),
                    onPressed: _showLoadDialog,
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    tooltip: 'save'.tr(),
                    onPressed: _saveTable,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
