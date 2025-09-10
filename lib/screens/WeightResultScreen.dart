import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/species_data.dart';
import '../data/species_density.dart';
import '../data/species_meta.dart';
import '../widgets/ISO_4480_83__table.dart';
import '../widgets/GOST_2708_75_table.dart';
import '../data/species_density.dart';
import '../widgets/main_drawer.dart';

class WeightResultScreen extends StatefulWidget {
  @override
  State<WeightResultScreen> createState() => _WeightResultScreenState();
}

class _WeightResultScreenState extends State<WeightResultScreen> {
  // Таблица данных
  List<Map<String, dynamic>> tableData = [];
  List<String> gradeList = ['1', '2', '3'];
  List<String> customSpecies = [];
  List<String> selectedSpeciesList = [];
  String? selectedMethod;
  String? selectedSpecies;
  String? selectedGrade;
  double? length;
  double? diameter;
  int? quantity;
  int roundDiameterForJAS(double diameterCm) {
  // JAS округляет диаметр вниз до ближайшего чётного числа
  return (diameterCm ~/ 2) * 2;
}
  double? price;
  double volume = 0;
  double totalPrice = 0;
  double totalVolume = 0;
  double volumeWithBark = 0.0;
  double woodMoisture = 20.0;
  double packageWeight = 0.0;
  double? diameter2;
  double? diameterMiddle;
  double volumeNeller(double diameter, double length) {
  // Формула Неллера: V = π/4 * d^2 * L * 0.785
  // diameter — в метрах, length — в метрах
  return 3.14159 / 4 * diameter * diameter * length * 0.785;
}
double? getJasCoef(
  double length,
  double diameter,
  {String species = 'radiata_pine', String density = '0.8-1.19'}
) {
  // Пример: возвращает коэффициент по диапазону плотности (можно доработать под вашу таблицу)
  // Обычно коэффициенты берутся из справочника или таблицы JAS
  // Здесь просто пример для диапазона
  if (density == '0.8-1.19') return 1.05;
  if (density == '1.2-1.39') return 1.10;
  if (density == '1.4-1.59') return 1.15;
  // ...добавьте свои условия и таблицы
  return 1.0;
}
  bool showWithBark = false;
  bool showGrossWeightColumn = true;
  bool showNetWeightColumn = true;
  bool showBarkVolumeColumn = true;
  bool showMethodColumn = true;
  bool showSpeciesColumn = true;
  bool showGradeColumn = true;
  bool showDensityColumn = false;
  bool showPriceColumn = true;
  String lengthUnit = 'м';
  String diameterUnit = 'мм';
  String weightUnit = 'кг';
  String selectedCurrency = 'USD';
  String? selectedJasDensityRange = '0.8-1.19';
  final List<String> currencies = ['USD', 'EUR', 'UAH', 'RUB', 'PLN', 'KZT', 'BYN'];

  // PDF реквизиты
  String sender = '';
  String consignee = '';
  String cargoDescription = '';
  String transportConditions = '';
  String driver = '';
  String vehicleNumber = '';
  String country = '';
  String route = '';
  String originCountry = '';
  String destinationCountry = '';

  @override
  void initState() {
    super.initState();
    _loadCustomSpecies();
    _loadGradeList();
    _loadTableFromAppFolderAuto();
    _initSpeciesListByRegion('UA');
    _loadSelectedSpeciesList();
    _loadUserUnits();
    _loadPdfFields();
  }

  // --- SharedPreferences ---
  Future<void> _loadCustomSpecies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSpecies = prefs.getStringList('customSpecies');
    if (savedSpecies != null) {
      setState(() {
        customSpecies = savedSpecies;
      });
    }
  }

  

  Future<void> _saveCustomSpecies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customSpecies', customSpecies);
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

  Future<void> _saveGradeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gradeList', gradeList);
  }

  void _initSpeciesListByRegion(String region) {
    final regionSpecies = speciesMeta.entries
        .where((e) => e.value.countries.contains(region))
        .map((e) => e.key)
        .toList();
    setState(() {
      selectedSpeciesList = regionSpecies;
      selectedSpecies = selectedSpeciesList.isNotEmpty ? selectedSpeciesList.first : null;
    });
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

  Future<void> _loadPdfFields() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sender = prefs.getString('pdf_sender') ?? '';
      consignee = prefs.getString('pdf_consignee') ?? '';
      cargoDescription = prefs.getString('pdf_cargoDescription') ?? '';
      transportConditions = prefs.getString('pdf_transportConditions') ?? '';
      driver = prefs.getString('pdf_driver') ?? '';
      vehicleNumber = prefs.getString('pdf_vehicleNumber') ?? '';
      country = prefs.getString('pdf_country') ?? '';
      route = prefs.getString('pdf_route') ?? '';
      originCountry = prefs.getString('pdf_originCountry') ?? '';
      destinationCountry = prefs.getString('pdf_destinationCountry') ?? '';
    });
  }

  Future<void> _savePdfFields() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('pdf_sender', sender);
    prefs.setString('pdf_consignee', consignee);
    prefs.setString('pdf_cargoDescription', cargoDescription);
    prefs.setString('pdf_transportConditions', transportConditions);
    prefs.setString('pdf_driver', driver);
    prefs.setString('pdf_vehicleNumber', vehicleNumber);
    prefs.setString('pdf_country', country);
    prefs.setString('pdf_route', route);
    prefs.setString('pdf_originCountry', originCountry);
    prefs.setString('pdf_destinationCountry', destinationCountry);
  }

  // --- Таблица и расчёты ---
  double get selectedDensity {
    if (selectedSpecies != null && speciesDensity.containsKey(selectedSpecies)) {
      return speciesDensity[selectedSpecies]!;
    }
    return 600;
  }

  double get moistureCoef => 1 + (woodMoisture / 100);

  double get grossWeight {
    double total = 0;
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
      total += rowVolumeWithBark * rowDensity * rowMoistureCoef + packageWeight;
    }
    return total;
  }

  double get netWeight {
    double total = 0;
    for (final row in tableData) {
      double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
      double rowDensity = 600;
      if (row['Порода'] != null && speciesDensity.containsKey(row['Порода'])) {
        rowDensity = speciesDensity[row['Порода']]!;
      }
      double rowMoistureCoef = 1 + (woodMoisture / 100);
      total += rowVolume * rowDensity * rowMoistureCoef;
    }
    return total;
  }

  double get totalVolumeWithBark {
    double total = 0;
    for (final row in tableData) {
      double rowVolume = double.tryParse(row['Объем'] ?? '0') ?? 0;
      double barkPercent = 0.0;
      if (row['Порода'] != null && speciesData.containsKey(row['Порода'])) {
        barkPercent = speciesData[row['Порода']] ?? 0.0;
      }
      total += rowVolume * (1 + barkPercent);
    }
    return total;
  }

  // --- Экспорт/Импорт ---
  Future<Directory> getTablesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final tablesDir = Directory('${dir.path}/tables');
    if (!await tablesDir.exists()) {
      await tablesDir.create(recursive: true);
    }
    return tablesDir;
  }

  Future<void> _exportToCSV() async {
    final dir = await getTablesDirectory();
    final file = File('${dir.path}/_autosave_manual.csv');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV экспортирован: ${file.path}')),
    );
  }

  Future<void> _loadTableFromAppFolderAuto() async {
    final dir = await getTablesDirectory();
    final file = File('${dir.path}/_autosave_manual.csv');
    if (!await file.exists()) return;
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
              'Плотность': values.length > 6 ? values[6] : '',
              'Количество': values.length > 7 ? values[7] : '1',
              'Цена за м³': values.length > 8 ? values[8] : '',
              'Объем': values.length > 9 ? values[9] : '',
              'Итоговая цена': values.length > 10 ? values[10] : '',
            };
          })
          .toList();
      totalVolume = tableData.fold<double>(
        0,
        (sum, row) => sum + double.tryParse(row['Объем'] ?? '0')!,
      );
    });
  }


Future<void> _exportPdfToFile() async {
  final pdf = pw.Document();
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: ttf,
        bold: ttf,
        italic: ttf,
        boldItalic: ttf,
      ),
      build: (context) => [
        pw.Text('Отправитель: $sender'),
        pw.Text('Получатель: $consignee'),
        pw.Text('Характеристика груза: $cargoDescription'),
        pw.Text('Условия перевозки: $transportConditions'),
        pw.Text('Водитель: $driver'),
        pw.Text('Госномер: $vehicleNumber'),
        pw.Text('Страна: $country'),
        pw.Text('Маршрут: $route'),
        pw.Text('Страна отправления: $originCountry'),
        pw.Text('Страна назначения: $destinationCountry'),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          headers: [
            '№', 'Метод', 'Порода', 'Сорт', 'Длина', 'Диаметр', 'Количество', 'Объем', 'Вес (брутто)', 'Вес (нетто)'
          ],
          data: tableData.asMap().entries.map((entry) {
            int i = entry.key;
            final row = entry.value;
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
            double rowGrossWeight = rowVolumeWithBark * rowDensity * rowMoistureCoef + packageWeight;
            double rowNetWeight = rowVolume * rowDensity * rowMoistureCoef;
            return [
              (i + 1).toString(),
              row['Метод'] ?? '',
              row['Порода'] ?? '',
              row['Сорт'] ?? '',
              row['Длина'] ?? '',
              row['Диаметр'] ?? '',
              row['Количество'] ?? '',
              row['Объем'] ?? '',
              rowGrossWeight.toStringAsFixed(1),
              rowNetWeight.toStringAsFixed(1),
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Общий объем: ${totalVolume.toStringAsFixed(3)} м³'),
        pw.Text('Общий вес нетто: ${netWeight.toStringAsFixed(1)} $weightUnit'),
        pw.Text('Общий вес брутто: ${grossWeight.toStringAsFixed(1)} $weightUnit'),
      ],
    ),
  );

  final dir = await getTablesDirectory();
  final file = File('${dir.path}/table_export.pdf');
  await file.writeAsBytes(await pdf.save());
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('PDF экспортирован: ${file.path}')),
  );
}
  // --- UI dialogs ---
  Future<void> _showSpeciesDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        final speciesDropdownList = [
          ...selectedSpeciesList,
          ...customSpecies.where((s) => !selectedSpeciesList.contains(s)),
        ];
        return AlertDialog(
          title: Text('select_species'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: speciesDropdownList.length,
              itemBuilder: (context, index) {
                final species = speciesDropdownList[index];
                return ListTile(
                  title: Text(speciesMeta.containsKey(species) ? species.tr() : species),
                  selected: selectedSpecies == species,
                  onTap: () {
                    setState(() {
                      selectedSpecies = species;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveTableAsDialog() async {
  final controller = TextEditingController(text: 'my_table.csv');
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Сохранить как'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Имя файла (например, my_table.csv)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () async {
            final fileName = controller.text.trim();
            if (fileName.isNotEmpty) {
              await _saveTableToFileInAppFolder(fileName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Сохранено: $fileName')),
              );
            }
          },
          child: Text('Сохранить'),
        ),
      ],
    ),
  );
}

  Future<void> _showPdfFieldsDialog() async {
    final controllerSender = TextEditingController(text: sender);
    final controllerConsignee = TextEditingController(text: consignee);
    final controllerCargo = TextEditingController(text: cargoDescription);
    final controllerCond = TextEditingController(text: transportConditions);
    final controllerDriver = TextEditingController(text: driver);
    final controllerVehicle = TextEditingController(text: vehicleNumber);
    final controllerCountry = TextEditingController(text: country);
    final controllerRoute = TextEditingController(text: route);
    final controllerOrigin = TextEditingController(text: originCountry);
    final controllerDest = TextEditingController(text: destinationCountry);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Данные для PDF'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: 'Отправитель'), controller: controllerSender),
              TextField(decoration: InputDecoration(labelText: 'Получатель'), controller: controllerConsignee),
              TextField(decoration: InputDecoration(labelText: 'Характеристика груза'), controller: controllerCargo),
              TextField(decoration: InputDecoration(labelText: 'Условия перевозки'), controller: controllerCond),
              TextField(decoration: InputDecoration(labelText: 'Водитель'), controller: controllerDriver),
              TextField(decoration: InputDecoration(labelText: 'Госномер'), controller: controllerVehicle),
              TextField(decoration: InputDecoration(labelText: 'Страна'), controller: controllerCountry),
              TextField(decoration: InputDecoration(labelText: 'Маршрут'), controller: controllerRoute),
              TextField(decoration: InputDecoration(labelText: 'Страна отправления'), controller: controllerOrigin),
              TextField(decoration: InputDecoration(labelText: 'Страна назначения'), controller: controllerDest),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                sender = controllerSender.text;
                consignee = controllerConsignee.text;
                cargoDescription = controllerCargo.text;
                transportConditions = controllerCond.text;
                driver = controllerDriver.text;
                vehicleNumber = controllerVehicle.text;
                country = controllerCountry.text;
                route = controllerRoute.text;
                originCountry = controllerOrigin.text;
                destinationCountry = controllerDest.text;
              });
              _savePdfFields();
              Navigator.pop(context);
            },
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  // --- PDF preview ---
Future<void> _showPdfPreview() async {
  final pdf = pw.Document();
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: ttf,
        bold: ttf,
        italic: ttf,
        boldItalic: ttf,
      ),
      build: (context) => [
        pw.Text('Отправитель: $sender'),
        pw.Text('Получатель: $consignee'),
        pw.Text('Характеристика груза: $cargoDescription'),
        pw.Text('Условия перевозки: $transportConditions'),
        pw.Text('Водитель: $driver'),
        pw.Text('Госномер: $vehicleNumber'),
        pw.Text('Страна: $country'),
        pw.Text('Маршрут: $route'),
        pw.Text('Страна отправления: $originCountry'),
        pw.Text('Страна назначения: $destinationCountry'),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          headers: [
            '№', 'Метод', 'Порода', 'Сорт', 'Длина', 'Диаметр', 'Количество', 'Объем', 'Вес (брутто)', 'Вес (нетто)'
          ],
          data: tableData.asMap().entries.map((entry) {
            int i = entry.key;
            final row = entry.value;
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
            double rowGrossWeight = rowVolumeWithBark * rowDensity * rowMoistureCoef + packageWeight;
            double rowNetWeight = rowVolume * rowDensity * rowMoistureCoef;
            return [
              (i + 1).toString(),
              row['Метод'] ?? '',
              row['Порода'] ?? '',
              row['Сорт'] ?? '',
              row['Длина'] ?? '',
              row['Диаметр'] ?? '',
              row['Количество'] ?? '',
              row['Объем'] ?? '',
              rowGrossWeight.toStringAsFixed(1),
              rowNetWeight.toStringAsFixed(1),
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Общий объем: ${totalVolume.toStringAsFixed(3)} м³'),
        pw.Text('Общий вес нетто: ${netWeight.toStringAsFixed(1)} $weightUnit'),
        pw.Text('Общий вес брутто: ${grossWeight.toStringAsFixed(1)} $weightUnit'),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
      if (filterMinDensity != null &&
          (meta.density ?? 0) < filterMinDensity!) return false;
      if (filterMaxDensity != null &&
          (meta.density ?? 0) > filterMaxDensity!) return false;
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
                          onSelected: (_) => setStateDialog(() => filterType = 'all'),
                        ),
                        SizedBox(width: 4),
                        ChoiceChip(
                          label: Text('hardwood'.tr()),
                          selected: filterType == 'hardwood',
                          onSelected: (_) => setStateDialog(() => filterType = 'hardwood'),
                        ),
                        SizedBox(width: 4),
                        ChoiceChip(
                          label: Text('softwood'.tr()),
                          selected: filterType == 'softwood',
                          onSelected: (_) => setStateDialog(() => filterType = 'softwood'),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: filterRegion,
                      hint: Text('region'.tr()),
                      isExpanded: true,
                      items: allRegions
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setStateDialog(() => filterRegion = v),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'min_density'.tr()),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => setStateDialog(() => filterMinDensity = double.tryParse(v)),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'max_density'.tr()),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => setStateDialog(() => filterMaxDensity = double.tryParse(v)),
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: showDensityLocal,
                      onChanged: (v) => setStateDialog(() => showDensityLocal = v ?? false),
                      title: Text('show_density'.tr()),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    CheckboxListTile(
                      value: showBarkLocal,
                      onChanged: (v) => setStateDialog(() => showBarkLocal = v ?? false),
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
                                  if (showDensityLocal && meta?.density != null)
                                    ...[
                                      SizedBox(width: 6),
                                      Text('(ρ: ${meta!.density!.toStringAsFixed(0)})', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  if (showBarkLocal && meta?.barkCorrection != null)
                                    ...[
                                      SizedBox(width: 6),
                                      Text('(кора: +${(meta!.barkCorrection! * 100).round()}%)', style: TextStyle(fontSize: 12, color: Colors.green)),
                                    ],
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
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
                  final newSpecies = Set<String>.from(selectedSpeciesList)..addAll(tempSelected);
                  setState(() {
                    selectedSpeciesList = newSpecies.toList();
                    if (selectedSpecies == null || !selectedSpeciesList.contains(selectedSpecies)) {
                      selectedSpecies = selectedSpeciesList.isNotEmpty ? selectedSpeciesList.first : null;
                    }
                  });
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setStringList('selectedSpeciesList', selectedSpeciesList);
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

void clearTable() {
  setState(() {
    tableData.clear();
    totalVolume = 0;
  });
}

void addToTable() {
  if (volume <= 0 || selectedSpecies == null) return;
  final density = speciesDensity[selectedSpecies] ?? 600.0;
  final barkPercent = speciesData[selectedSpecies] ?? 0.0;
  final volumeWithBark = volume * (1 + barkPercent);
  final moistureCoef = 1 + (woodMoisture / 100);
  final grossWeight = volumeWithBark * density * moistureCoef + packageWeight;
  final netWeight = volume * density * moistureCoef;

  setState(() {
    tableData.add({
      'Метод': selectedMethod ?? '',
      'Порода': selectedSpecies ?? '',
      'Сорт': selectedGrade ?? '',
      'Длина': length?.toString() ?? '',
      'Диаметр': diameter?.toString() ?? '',
      'Плотность': density.toStringAsFixed(0),
      'Количество': quantity?.toString() ?? '1',
      'Цена за м³': price?.toString() ?? '',
      'Объем': volume.toStringAsFixed(3),
      'Итоговая цена': '', // Можно добавить расчет если нужно
    });
    totalVolume += volume;
    // Сбрасываем только поля ввода
    volume = 0;
    packageWeight = 0;
    woodMoisture = 20.0;
    // Не сбрасывайте selectedSpecies, selectedMethod и т.д.
  });
}
void calculate() {
  if (length != null && diameter != null) {
    int qty = quantity ?? 1;
    double oneVol = 0.0;

    double l = length!; // всегда в метрах
    double d1 = diameter!; // всегда в мм
    double d2 = diameter2 ?? d1;
    double dMiddle = diameterMiddle ?? d1;

    if (selectedMethod != null && selectedMethod!.startsWith('ГОСТ 2708-75')) {
      String lengthKey = l.toStringAsFixed(1);
      int diameterKey = (d1 / 10).round(); // d1 в мм, переводим в см
      if (GOST_2708_75_TABLE.containsKey(lengthKey)) {
        oneVol = GOST_2708_75_TABLE[lengthKey]?[diameterKey] ?? 0.0;
      }
    } else if (selectedMethod != null && selectedMethod!.startsWith('ISO_4480_83')) {
      String lengthKey = l.toStringAsFixed(1);
      int diameterKey = (d1 / 10).round();
      if (ISO_4480_83_TABLE.containsKey(lengthKey)) {
        oneVol = ISO_4480_83_TABLE[lengthKey]?[diameterKey] ?? 0.0;
      }
    } else if (selectedMethod != null && selectedMethod!.startsWith('Неллера (х0.785)')) {
      double diameterMeters = d1 / 1000;
      oneVol = volumeNeller(diameterMeters, l);
    } else if (selectedMethod != null && selectedMethod!.startsWith('Неллера (упрощённая)')) {
      double dCm = d1 / 10; // d1 в мм -> см
      oneVol = (3.14159 * dCm * dCm / 40000) * l;
    } else if (selectedMethod != null && selectedMethod!.startsWith('Среднеарифметический диаметр')) {
      oneVol = (3.14159 / 4) * ((d1 * d1 + d1 * d2 + d2 * d2) / 3) * l / 1e6;
    } else if (selectedMethod != null && selectedMethod!.startsWith('Смалиана')) {
      oneVol = (3.14159 / 4) * l * ((d1 * d1 + d2 * d2) / 2) / 1e6;
    } else if (selectedMethod != null && selectedMethod!.startsWith('Ньютона')) {
      double d1m = d1 / 1000;
      double d2m = d2 / 1000;
      double dmm = dMiddle / 1000;
      oneVol = (3.14159 * l / 24) * (d1m * d1m + 4 * dmm * dmm + d2m * d2m);
    } else if (selectedMethod != null && selectedMethod!.startsWith('Губера')) {
      oneVol = (3.14159 / 4) * d1 * d1 * l / 1e6;
    } else if (selectedMethod != null && selectedMethod!.startsWith('JAS Scale (формула)')) {
      double dCm = d1 / 10; // d1 в мм -> см
      oneVol = (dCm * dCm * l) / 10000;
    } else if (selectedMethod != null && selectedMethod!.startsWith('JAS Scale (таблица)')) {
      double dCm = d1 / 10;
      double jasDiameter = roundDiameterForJAS(dCm).toDouble();
      double jas = (jasDiameter * jasDiameter * l) / 10000;

      double? coef = getJasCoef(
        l,
        jasDiameter,
        species: selectedSpecies ?? 'radiata_pine',
        density: selectedJasDensityRange ?? '0.8-1.19',
      );

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

void calculateVolumeWithBark() {
  if (volume > 0 && selectedSpecies != null) {
    final barkPercent = speciesData[selectedSpecies] ?? 0.0;
    volumeWithBark = volume * (1 + barkPercent);
    setState(() {});
  }
}

Future<void> _saveTableToFileInAppFolder(String fileName) async {
  final dir = await getTablesDirectory();
  final file = File('${dir.path}/$fileName');
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
}

void _addCustomSpecies() async {
  String newSpecies = '';
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Добавить породу'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Название породы'),
          onChanged: (v) => newSpecies = v.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newSpecies.isNotEmpty && !customSpecies.contains(newSpecies)) {
                setState(() {
                  customSpecies.add(newSpecies);
                  selectedSpeciesList.add(newSpecies);
                  selectedSpecies = newSpecies;
                });
                _saveCustomSpecies();
              }
              Navigator.pop(context);
            },
            child: Text('Добавить'),
          ),
        ],
      );
    },
  );
}
  // --- UI ---
  @override
  Widget build(BuildContext context) {
    double totalNettoWeight = netWeight;
    double totalBruttoWeight = grossWeight;
    double totalVolWithBark = totalVolumeWithBark;

    return Scaffold(
       backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Результаты расчёта'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      drawer: MainDrawer(
        currentScreen: 'Результаты расчёта',
        initialSpeciesList: const [],
        initialSpeciesDensity: speciesDensity, // speciesDensity из species_density.dart
        initialLengthUnit: '',
        initialDiameterUnit: '',
        initialWeightUnit: '',
        initialSpeciesListBf: [],
        initialSpeciesDensityBf: {},
        initialLengthUnitBf: '',
        initialDiameterUnitBf: '',
        initialWeightUnitBf: '',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Первый ряд иконок
// ...внутри build, в Row первого ряда:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.upload_file, color: Colors.blue, size: 32),
                    tooltip: 'Загрузить таблицу',
                    onPressed: () async {                  final dir = await getTablesDirectory();
                  final files = dir
                      .listSync()
                      .whereType<File>()
                      .where((f) => f.path.endsWith('.csv'))
                      .toList();
                  if (files.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Нет сохранённых таблиц')),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Выберите файл'),
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
                                            'Плотность': values.length > 6 ? values[6] : '',
                                            'Количество': values.length > 7 ? values[7] : '1',
                                            'Цена за м³': values.length > 8 ? values[8] : '',
                                            'Объем': values.length > 9 ? values[9] : '',
                                            'Итоговая цена': values.length > 10 ? values[10] : '',
                                          };
                                        })
                                        .toList();
                                    totalVolume = tableData.fold<double>(
                                      0,
                                      (sum, row) => sum + double.tryParse(row['Объем'] ?? '0')!,
                                    );
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
// ...в Row первого ряда:
// ...в Row первого ряда:
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.nature, color: selectedSpecies == null ? Colors.grey : Colors.green, size: 32),
                  tooltip: selectedSpecies ?? 'select_species'.tr(),                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final speciesDropdownList = [
                          ...selectedSpeciesList,
                          ...customSpecies.where((s) => !selectedSpeciesList.contains(s)),
                        ];
                        return AlertDialog(
                          title: Text('select_species'.tr()),
                          content: SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.add, color: Colors.green),
                                      ),
                                    ),
                                  );
                                }
                                if (index == speciesDropdownList.length + 1) {
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.filter_list, color: Colors.blue),
                                      ),
                                    ),
                                  );
                                }
                                final species = speciesDropdownList[index];
                                final isCustom = customSpecies.contains(species);

                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedSpecies = species;
                                        });
                                        Navigator.pop(context);
                                        calculate();
                                        if (showWithBark) calculateVolumeWithBark();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: selectedSpecies == species ? Colors.green[100] : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                          border: selectedSpecies == species
                                              ? Border.all(color: Colors.green, width: 2)
                                              : null,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.park, color: selectedSpecies == species ? const Color.fromARGB(255, 7, 61, 9) : const Color.fromARGB(255, 56, 238, 11)),
                                              SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  speciesMeta.containsKey(species)
                                                      ? species.tr()
                                                      : species,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: selectedSpecies == species ? Colors.green : Colors.black,
                                                    fontWeight: selectedSpecies == species ? FontWeight.bold : FontWeight.normal,
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
                                          icon: Icon(Icons.close, color: Colors.red, size: 18),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          tooltip: 'Удалить',
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {
                                              if (selectedSpecies == species) selectedSpecies = null;
                                              customSpecies.remove(species);
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
              IconButton(
                  icon: Icon(Icons.straighten, color: Colors.orange, size: 32),
                  tooltip: 'Единицы измерения',
                  onPressed: () async {
                    String tempLengthUnit = lengthUnit;
                    String tempDiameterUnit = diameterUnit;
                    String tempWeightUnit = weightUnit;
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Единицы измерения'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButton<String>(
                                value: tempLengthUnit,
                                items: ['м', 'см', 'мм']
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => lengthUnit = v);
                                },
                              ),
                              DropdownButton<String>(
                                value: tempDiameterUnit,
                                items: ['мм', 'см']
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => diameterUnit = v);
                                },
                              ),
                              DropdownButton<String>(
                                value: tempWeightUnit,
                                items: ['кг', 'т']
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => weightUnit = v);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  lengthUnit = tempLengthUnit;
                                  diameterUnit = tempDiameterUnit;
                                  weightUnit = tempWeightUnit;
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
                ),
                // Редактирование PDF реквизитов (добавлены поля авто/прицеп)
                IconButton(
                    icon: Icon(Icons.edit, color: Colors.purple, size: 32),
                    tooltip: 'Редактировать PDF реквизиты',                  onPressed: () async {
                    final controllerSender = TextEditingController(text: sender);
                    final controllerConsignee = TextEditingController(text: consignee);
                    final controllerCargo = TextEditingController(text: cargoDescription);
                    final controllerCond = TextEditingController(text: transportConditions);
                    final controllerDriver = TextEditingController(text: driver);
                    final controllerVehicle = TextEditingController(text: vehicleNumber);
                    final controllerCountry = TextEditingController(text: country);
                    final controllerRoute = TextEditingController(text: route);
                    final controllerOrigin = TextEditingController(text: originCountry);
                    final controllerDest = TextEditingController(text: destinationCountry);
                    final controllerTruckNetto = TextEditingController();
                    final controllerTruckBrutto = TextEditingController();
                    final controllerTrailerNetto = TextEditingController();
                    final controllerTrailerBrutto = TextEditingController();

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Данные для PDF'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextField(decoration: InputDecoration(labelText: 'Отправитель'), controller: controllerSender),
                              TextField(decoration: InputDecoration(labelText: 'Получатель'), controller: controllerConsignee),
                              TextField(decoration: InputDecoration(labelText: 'Характеристика груза'), controller: controllerCargo),
                              TextField(decoration: InputDecoration(labelText: 'Условия перевозки'), controller: controllerCond),
                              TextField(decoration: InputDecoration(labelText: 'Водитель'), controller: controllerDriver),
                              TextField(decoration: InputDecoration(labelText: 'Госномер'), controller: controllerVehicle),
                              TextField(decoration: InputDecoration(labelText: 'Страна'), controller: controllerCountry),
                              TextField(decoration: InputDecoration(labelText: 'Маршрут'), controller: controllerRoute),
                              TextField(decoration: InputDecoration(labelText: 'Страна отправления'), controller: controllerOrigin),
                              TextField(decoration: InputDecoration(labelText: 'Страна назначения'), controller: controllerDest),
                              Divider(),
                              TextField(decoration: InputDecoration(labelText: 'Авто нетто'), controller: controllerTruckNetto),
                              TextField(decoration: InputDecoration(labelText: 'Авто брутто'), controller: controllerTruckBrutto),
                              TextField(decoration: InputDecoration(labelText: 'Прицеп нетто'), controller: controllerTrailerNetto),
                              TextField(decoration: InputDecoration(labelText: 'Прицеп брутто'), controller: controllerTrailerBrutto),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                sender = controllerSender.text;
                                consignee = controllerConsignee.text;
                                cargoDescription = controllerCargo.text;
                                transportConditions = controllerCond.text;
                                driver = controllerDriver.text;
                                vehicleNumber = controllerVehicle.text;
                                country = controllerCountry.text;
                                route = controllerRoute.text;
                                originCountry = controllerOrigin.text;
                                destinationCountry = controllerDest.text;
                                // Добавьте сохранение авто/прицепа, если нужно
                              });
                              _savePdfFields();
                              Navigator.pop(context);
                            },
                            child: Text('ok'.tr()),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Очистка таблицы
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 32),
                  tooltip: 'Очистить таблицу',
                  onPressed: clearTable,
                ),
              ],
            ),
// ...второй ряд:
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Объем (м³)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setState(() {
                      volume = double.tryParse(v) ?? 0;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Вес упаковки (кг)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setState(() {
                      packageWeight = double.tryParse(v) ?? 0;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Влажность (%)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setState(() {
                      woodMoisture = double.tryParse(v) ?? 0;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.green, size: 32),
                tooltip: 'Добавить в таблицу',
                onPressed: addToTable,
              ),
            ],
          ),            SizedBox(height: 8),
            // Таблица
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('№')),
                    DataColumn(label: Text('Метод')),
                    DataColumn(label: Text('Порода')),
                    DataColumn(label: Text('Сорт')),
                    DataColumn(label: Text('Длина')),
                    DataColumn(label: Text('Диаметр')),
                    DataColumn(label: Text('Количество')),
                    DataColumn(label: Text('Объем')),
                    DataColumn(label: Text('Вес (брутто)')),
                    DataColumn(label: Text('Вес (нетто)')),
                  ],
                  rows: tableData.asMap().entries.map((entry) {
                    int i = entry.key;
                    final row = entry.value;
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
                    double rowGrossWeight = rowVolumeWithBark * rowDensity * rowMoistureCoef + packageWeight;
                    double rowNetWeight = rowVolume * rowDensity * rowMoistureCoef;
                    return DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(row['Метод'] ?? '')),
                        DataCell(Text(row['Порода'] ?? '')),
                        DataCell(Text(row['Сорт'] ?? '')),
                        DataCell(Text(row['Длина'] ?? '')),
                        DataCell(Text(row['Диаметр'] ?? '')),
                        DataCell(Text(row['Количество'] ?? '')),
                        DataCell(Text(row['Объем'] ?? '')),
                        DataCell(Text(rowGrossWeight.toStringAsFixed(1))),
                        DataCell(Text(rowNetWeight.toStringAsFixed(1))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            // Итоги
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text('Общий объем: ${totalVolume.toStringAsFixed(3)} м³', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Общий объем с корой: ${totalVolWithBark.toStringAsFixed(3)} м³', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Общий вес нетто: ${totalNettoWeight.toStringAsFixed(1)} $weightUnit', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Общий вес брутто: ${totalBruttoWeight.toStringAsFixed(1)} $weightUnit', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Нижний ряд иконок
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                  tooltip: 'Экспорт PDF',
                  onPressed: _showPdfPreview,
                ),
                IconButton(
                  icon: Icon(Icons.save, color: Colors.green),
                  tooltip: 'Сохранить таблицу',
                  onPressed: _exportToCSV,
                ),
                IconButton(
                  icon: Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'Предварительный просмотр',
                  onPressed: _showPdfPreview,
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.orange),
                  tooltip: 'Поделиться',
                  onPressed: () async {
                    final dir = await getTablesDirectory();
                    final file = File('${dir.path}/_autosave_manual.csv');
                    if (await file.exists()) {
                      await Share.shareXFiles([XFile(file.path)], text: 'Таблица');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}