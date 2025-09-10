import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_localization/easy_localization.dart';
import '../widgets/main_drawer.dart';
import '../data/species_density.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../ads_controller.dart';
import '../screens/vip.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<FileSystemEntity> manualFiles = [];
  List<FileSystemEntity> bfFiles = [];
  List<FileSystemEntity> templateFiles = [];
  List<FileSystemEntity> allFiles = [];
  String _sortType = 'date'; // 'name' или 'date'
  String _bfSortType = 'date';
  String _templateSortType = 'date';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
    _tabController.addListener(() {
      setState(() {});
    });
  }

  Future<Directory> _getManualDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/tables/mm');
    if (!await tablesDir.exists()) await tablesDir.create(recursive: true);
    return tablesDir;
  }

  Future<Directory> _getBfDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/tables/bf');
    if (!await tablesDir.exists()) await tablesDir.create(recursive: true);
    return tablesDir;
  }

  Future<Directory> _getTemplatesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final templatesDir = Directory('${dir.path}/wood_tables');
    if (!await templatesDir.exists())
      await templatesDir.create(recursive: true);
    return templatesDir;
  }

  Future<void> _loadAll() async {
    final manualDir = await _getManualDir();
    final bfDir = await _getBfDir();
    final templateDir = await _getTemplatesDir();

    final manual = manualDir.listSync().whereType<File>().toList();
    final bf = bfDir.listSync().whereType<File>().toList();
    final templates = templateDir.listSync().whereType<File>().toList();

    setState(() {
      manualFiles = manual;
      bfFiles = bf;
      templateFiles = templates;
      allFiles = [...manual, ...bf];
      _sortFiles();
      _sortBfFiles();
      _sortTemplates();
    });
  }

  void _sortFiles() {
    if (_sortType == 'name') {
      manualFiles.sort((a, b) => a.path.compareTo(b.path));
    } else {
      manualFiles.sort((a, b) => File(b.path)
          .statSync()
          .modified
          .compareTo(File(a.path).statSync().modified));
    }
    allFiles = [...manualFiles, ...bfFiles];
  }

  void _sortBfFiles() {
    if (_bfSortType == 'name') {
      bfFiles.sort((a, b) => a.path.compareTo(b.path));
    } else {
      bfFiles.sort((a, b) => File(b.path)
          .statSync()
          .modified
          .compareTo(File(a.path).statSync().modified));
    }
    allFiles = [...manualFiles, ...bfFiles];
  }

  void _sortTemplates() {
    if (_templateSortType == 'name') {
      templateFiles.sort((a, b) => a.path.compareTo(b.path));
    } else {
      templateFiles.sort((a, b) => File(b.path)
          .statSync()
          .modified
          .compareTo(File(a.path).statSync().modified));
    }
  }

  Future<void> _deleteFile(FileSystemEntity file, String type) async {
    await file.delete();
    await _loadAll();
  }

  Future<void> _renameFile(FileSystemEntity file, String type) async {
    String oldName = file.uri.pathSegments.last;
    String ext = oldName.contains('.') ? '.${oldName.split('.').last}' : '';
    String baseName = oldName.replaceAll(ext, '');
    String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempName = baseName;
        final controller = TextEditingController(text: baseName);
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          title: Text('menu_rename_file'.tr()),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'menu_new_name'.tr()),
            controller: controller,
            onChanged: (v) => tempName = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, tempName),
              child: Text('accept'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('decline'.tr()),
            ),
          ],
        );
      },
    );
    if (newName != null && newName.trim().isNotEmpty && newName != baseName) {
      Directory dir;
      if (type == 'manual')
        dir = await _getManualDir();
      else if (type == 'bf')
        dir = await _getBfDir();
      else
        dir = await _getTemplatesDir();
      final newPath = '${dir.path}/$newName$ext';
      await File(file.path).rename(newPath);
      await _loadAll();
    }
  }

  Future<void> _exportFile(FileSystemEntity file) async {
    await Share.shareXFiles([XFile(file.path)],
        text: file.uri.pathSegments.last);
  }

  Future<void> _viewFileAsTable(
      BuildContext context, FileSystemEntity file) async {
    final content = await File(file.path).readAsString();
    final lines =
        content.split('\n').where((e) => e.trim().isNotEmpty).toList();

    // Собираем шапку и футер
    final headerLines = lines
        .where((e) => e.startsWith('HEADER:'))
        .map((e) => e.substring(7))
        .toList();
    final footerLines = lines
        .where((e) => e.startsWith('FOOTER:'))
        .map((e) => e.substring(7))
        .toList();

    // Оставляем только строки таблицы (без HEADER, FOOTER, TEMPLATE)
    final tableLines = lines
        .where((e) =>
            !e.startsWith('HEADER:') &&
            !e.startsWith('FOOTER:') &&
            !e.trimLeft().startsWith('TEMPLATE:'))
        .toList();

    if (tableLines.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(file.uri.pathSegments.last),
          content: Text('empty_table'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ],
        ),
      );
      return;
    }

    // Определяем разделитель по первой строке таблицы
    final delimiter = tableLines.first.contains(';') ? ';' : ',';

    // Парсим все строки таблицы
    final rows = tableLines.map((e) => e.split(delimiter)).toList();

    // Определяем максимальное количество столбцов по всем строкам
    final int colCount = rows
        .map((r) => r.length)
        .fold<int>(0, (prev, el) => el > prev ? el : prev);

    // Выравниваем все строки по количеству столбцов
    for (var row in rows) {
      while (row.length < colCount) {
        row.add('');
      }
    }

    // Ключи для итоговых колонок (русские и английские)
    final sumKeys = [
      'quantity',
      'volume',
      'total_price',
      'gross',
      'net',
      'volume_with_bark',
      'количество',
      'объем',
      'итоговая цена',
      'брутто',
      'нетто',
      'объем с корой'
    ];

    // Индексы итоговых колонок ищем по приведённым к нижнему регистру и без пробелов заголовкам
    final headerRow = rows.isNotEmpty
        ? rows.first
            .map((h) => h.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''))
            .toList()
        : <String>[];
    final sumColumns = <int>[];
    for (int i = 0; i < headerRow.length; i++) {
      if (sumKeys.contains(headerRow[i])) {
        sumColumns.add(i);
      }
    }

    // Считаем итоги
    List<String> totalRow = List.filled(colCount, '');
    for (final idx in sumColumns) {
      double sum = 0;
      for (int r = 1; r < rows.length; r++) {
        if (idx < rows[r].length) {
          final val = rows[r][idx].replaceAll(' ', '').replaceAll(',', '.');
          sum += double.tryParse(val) ?? 0;
        }
      }
      totalRow[idx] = sum.toStringAsFixed(2);
    }
    while (totalRow.length < colCount) {
      totalRow.add('');
    }

    // Найти индекс столбца "Порода" или "species"
    final speciesColumnIndex = rows.isNotEmpty
        ? rows.first.indexWhere((h) =>
            h.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '') == 'порода' ||
            h.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '') == 'species')
        : -1;

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
        title: Text(file.uri.pathSegments.last),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Шапка
                  for (final h in headerLines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        h,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  // Таблица
                  DataTable(
                    columns: [
                      for (int i = 0; i < colCount; i++)
                        DataColumn(
                          label: Text(
                            (rows.isNotEmpty && i < rows.first.length
                                ? rows.first[i].tr()
                                : ''),
                          ),
                        ),
                    ],
                    rows: [
                      for (int r = 1; r < rows.length; r++)
                        DataRow(
                          cells: [
                            for (int c = 0; c < colCount; c++)
                              DataCell(
                                c == speciesColumnIndex
                                    ? Text(rows[r][c].tr())
                                    : Text(rows[r][c]),
                              ),
                          ],
                        ),
                      // Итоговая строка
                      if (sumColumns.isNotEmpty)
                        DataRow(
                          color: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.surfaceVariant),
                          cells: [
                            for (int c = 0; c < colCount; c++)
                              DataCell(
                                sumColumns.contains(c)
                                    ? Text(
                                        totalRow[c],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : const Text(''),
                              ),
                          ],
                        ),
                    ],
                  ),
                  // Футер
                  for (final f in footerLines)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        f,
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 15),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
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

  void _showExportMenu(FileSystemEntity file) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text('Экспорт в PDF'),
              onTap: () async {
                Navigator.pop(ctx);
                if (AdsController().canUsePremium()) {
                  await _exportFileToPdf(file);
                  AdsController().tryUsePremium();
                } else {
                  final result = await showRewardedInfoDialog(context);
                  if (result == true) {
                    AdsController().showRewardedForPremium(() async {
                      await _exportFileToPdf(file);
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
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: Text('Экспорт в Excel'),
              onTap: () async {
                Navigator.pop(ctx);
                if (AdsController().canUsePremium()) {
                  await _exportFileToExcel(file);
                  AdsController().tryUsePremium();
                } else {
                  final result = await showRewardedInfoDialog(context);
                  if (result == true) {
                    AdsController().showRewardedForPremium(() async {
                      await _exportFileToExcel(file);
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
            ListTile(
              leading: const Icon(Icons.share),
              title: Text('Поделиться оригиналом'),
              onTap: () async {
                Navigator.pop(ctx);
                await Share.shareXFiles([XFile(file.path)],
                    text: file.path.split('/').last);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(List<FileSystemEntity> files, String type) {
    if (files.isEmpty) return Center(child: Text('no_files'.tr()));
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return ListTile(
          title: Text(file.uri.pathSegments.last),
          onTap: () => _viewFileAsTable(context, file),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit,
                    color: Theme.of(context).colorScheme.secondary),
                onPressed: () => _renameFile(file, type),
              ),
              IconButton(
                icon: Icon(Icons.share,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () => _showExportMenu(file),
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () => _deleteFile(file, type),
              ),
            ],
          ),
        );
      },
    );
  }

// Добавьте внутрь _HistoryScreenState (например, после _exportFile)
  Future<void> _exportFileToExcel(FileSystemEntity file) async {
    final content = await File(file.path).readAsString();
    final lines =
        content.split('\n').where((e) => e.trim().isNotEmpty).toList();

    // HEADER, FOOTER, TABLE
    final headerLines = lines
        .where((e) => e.startsWith('HEADER:'))
        .map((e) => e.substring(7))
        .toList();
    final footerLines = lines
        .where((e) => e.startsWith('FOOTER:'))
        .map((e) => e.substring(7))
        .toList();
    final tableLines = lines
        .where((e) =>
            !e.startsWith('HEADER:') &&
            !e.startsWith('FOOTER:') &&
            !e.trimLeft().startsWith('TEMPLATE:'))
        .toList();

    if (tableLines.isEmpty) return;

    final delimiter = tableLines.first.contains(';') ? ';' : ',';
    final rows = tableLines.map((e) => e.split(delimiter)).toList();
    final int colCount = rows
        .map((r) => r.length)
        .fold<int>(0, (prev, el) => el > prev ? el : prev);

    // Индексы итоговых колонок
    final headerRow = rows.isNotEmpty
        ? rows.first.map((h) => h.trim().toLowerCase()).toList()
        : <String>[];
    final sumColumns = <int>[];
    final sumNames = [
      'количество',
      'объем',
      'итоговая цена',
      'брутто',
      'нетто',
      'объем с корой',
      'quantity',
      'volume',
      'total',
      'gross',
      'net',
      'volume with bark'
    ];
    for (int i = 0; i < headerRow.length; i++) {
      for (final name in sumNames) {
        if (headerRow[i].contains(name)) {
          sumColumns.add(i);
          break;
        }
      }
    }
    List<String> totalRow = List.filled(colCount, '');
    for (final idx in sumColumns) {
      double sum = 0;
      for (int r = 1; r < rows.length; r++) {
        if (idx < rows[r].length) {
          final val = rows[r][idx].replaceAll(' ', '').replaceAll(',', '.');
          sum += double.tryParse(val) ?? 0;
        }
      }
      totalRow[idx] = sum.toStringAsFixed(2);
    }

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // HEADER
    for (final h in headerLines) {
      sheet.appendRow([TextCellValue(h)]);
    }
    // TABLE
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rowCells = List<TextCellValue>.generate(colCount,
          (c) => c < row.length ? TextCellValue(row[c]) : TextCellValue(''));
      sheet.appendRow(rowCells);
    }
    // Итоговая строка
    if (sumColumns.isNotEmpty) {
      final totalCells = List<TextCellValue>.generate(
          colCount,
          (c) => sumColumns.contains(c)
              ? TextCellValue(totalRow[c])
              : TextCellValue(''));
      sheet.appendRow(totalCells);
    }
    // FOOTER
    for (final f in footerLines) {
      sheet.appendRow([TextCellValue(f)]);
    }

    final dir = await getTemporaryDirectory();
    final excelFile = File(
        '${dir.path}/${file.uri.pathSegments.last.replaceAll('.csv', '.xlsx')}');
    await excelFile.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(excelFile.path)],
        text: excelFile.path.split('/').last);
  }

  Future<void> _exportFileToPdf(FileSystemEntity file) async {
    final content = await File(file.path).readAsString();
    final lines =
        content.split('\n').where((e) => e.trim().isNotEmpty).toList();

    final headerLines = lines
        .where((e) => e.startsWith('HEADER:'))
        .map((e) => e.substring(7))
        .toList();
    final footerLines = lines
        .where((e) => e.startsWith('FOOTER:'))
        .map((e) => e.substring(7))
        .toList();
    final tableLines = lines
        .where((e) =>
            !e.startsWith('HEADER:') &&
            !e.startsWith('FOOTER:') &&
            !e.trimLeft().startsWith('TEMPLATE:'))
        .toList();

    if (tableLines.isEmpty) return;

    final delimiter = tableLines.first.contains(';') ? ';' : ',';
    final rows = tableLines.map((e) => e.split(delimiter)).toList();
    final int colCount = rows
        .map((r) => r.length)
        .fold<int>(0, (prev, el) => el > prev ? el : prev);

    final headerRow = rows.isNotEmpty
        ? rows.first.map((h) => h.trim().toLowerCase()).toList()
        : <String>[];
    final sumColumns = <int>[];
    final sumNames = [
      'количество',
      'объем',
      'итоговая цена',
      'брутто',
      'нетто',
      'объем с корой',
      'quantity',
      'volume',
      'total',
      'gross',
      'net',
      'volume with bark'
    ];
    for (int i = 0; i < headerRow.length; i++) {
      for (final name in sumNames) {
        if (headerRow[i].contains(name)) {
          sumColumns.add(i);
          break;
        }
      }
    }
    List<String> totalRow = List.filled(colCount, '');
    for (final idx in sumColumns) {
      double sum = 0;
      for (int r = 1; r < rows.length; r++) {
        if (idx < rows[r].length) {
          final val = rows[r][idx].replaceAll(' ', '').replaceAll(',', '.');
          sum += double.tryParse(val) ?? 0;
        }
      }
      totalRow[idx] = sum.toStringAsFixed(2);
    }

    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) => [
          for (final h in headerLines)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(h,
                  style: pw.TextStyle(
                      font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ),
          pw.Table.fromTextArray(
            headers: List<String>.generate(
                colCount,
                (c) => rows.isNotEmpty && c < rows.first.length
                    ? rows.first[c].tr()
                    : ''),
            data: [
              for (int r = 1; r < rows.length; r++)
                List<String>.generate(
                    colCount, (c) => c < rows[r].length ? rows[r][c] : ''),
              if (sumColumns.isNotEmpty)
                List<String>.generate(
                    colCount, (c) => sumColumns.contains(c) ? totalRow[c] : ''),
            ],
            cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
            headerStyle: pw.TextStyle(
                font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          for (final f in footerLines)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(f,
                  style: pw.TextStyle(
                      font: ttf, fontStyle: pw.FontStyle.italic, fontSize: 15)),
            ),
        ],
      ),
    );

// ...внутри класса _HistoryScreenState...

    final dir = await getTemporaryDirectory();
    final pdfFile = File(
        '${dir.path}/${file.uri.pathSegments.last.replaceAll('.csv', '.pdf')}');
    await pdfFile.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(pdfFile.path)],
        text: pdfFile.path.split('/').last);
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
                'file_history'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                minFontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      drawer: MainDrawer(
        currentScreen: 'file_history',
        initialSpeciesList: const [],
        initialSpeciesDensity: speciesDensity,
        initialLengthUnit: '',
        initialDiameterUnit: '',
        initialWeightUnit: '',
        initialSpeciesListBf: [],
        initialSpeciesDensityBf: {},
        initialLengthUnitBf: '',
        initialDiameterUnitBf: '',
        initialWeightUnitBf: '',
      ),
      body: Column(
        children: [
          // Фильтр и обновить
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (_tabController.index == 0)
                  Row(
                    children: [
                      Text('sort_by'.tr()),
                      SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _sortType,
                        items: [
                          DropdownMenuItem(
                              value: 'name', child: Text('sort_name'.tr())),
                          DropdownMenuItem(
                              value: 'date', child: Text('sort_date'.tr())),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _sortType = val!;
                            _sortFiles();
                          });
                        },
                      ),
                    ],
                  ),
                if (_tabController.index == 1)
                  Row(
                    children: [
                      Text('sort_by'.tr()),
                      SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _bfSortType,
                        items: [
                          DropdownMenuItem(
                              value: 'name', child: Text('sort_name'.tr())),
                          DropdownMenuItem(
                              value: 'date', child: Text('sort_date'.tr())),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _bfSortType = val!;
                            _sortBfFiles();
                          });
                        },
                      ),
                    ],
                  ),
                if (_tabController.index == 2)
                  Row(
                    children: [
                      Text('sort_by'.tr()),
                      SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _templateSortType,
                        items: [
                          DropdownMenuItem(
                              value: 'name', child: Text('sort_name'.tr())),
                          DropdownMenuItem(
                              value: 'date', child: Text('sort_date'.tr())),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _templateSortType = val!;
                            _sortTemplates();
                          });
                        },
                      ),
                    ],
                  ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadAll,
                ),
              ],
            ),
          ),
          // Список файлов
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFileList(manualFiles, 'manual'),
                _buildFileList(bfFiles, 'bf'),
                _buildFileList(templateFiles, 'template'),
                _buildFileList(allFiles, 'all'),
              ],
            ),
          ),
          // Вкладки внизу
          Material(
            color: Theme.of(context).bottomAppBarTheme.color ??
                Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'tables_manual_tab'.tr()),
                Tab(text: 'tables_bf_tab'.tr()),
                Tab(text: 'templates_tab'.tr()),
                Tab(text: 'tables_all_tab'.tr()),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
//
