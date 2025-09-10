import '../data/species_meta.dart' as meta; // meta.SpeciesMeta
import '../widgets/GOST_2708_75_table.dart';    // GOST_2708_75_TABLE
import '../widgets/ISO_4480_83__table.dart';    // ISO_4480_83_TABLE
import '../widgets/jasTable.dart';              // getJasCoef, roundDiameterForJAS, volumeNeller
import '../utlits/unit_utils.dart'; 
import '../widgets/method_map.dart'; // methodMap    

void recalcRow(
  Map<String, dynamic> row,
  Map<String, double> speciesDensity,
  Map<String, meta.SpeciesMeta> speciesMeta,
  double packageWeight,
  String weightUnit,
  String lengthUnit,
  String diameterUnit,
  double woodMoisture, // <-- добавьте этот параметр!
) {
  print('Порода: ${row['Порода']}, Плотность: ${row['Плотность']}');
  // Универсальное преобразование типов
  final dRaw = (row['Диаметр'] is num)
      ? row['Диаметр']
      : double.tryParse(row['Диаметр']?.toString() ?? '') ?? 0;
  final lRaw = (row['Длина'] is num)
      ? row['Длина']
      : double.tryParse(row['Длина']?.toString() ?? '') ?? 0.0;
  final qty = (row['Количество'] is num)
      ? row['Количество']
      : int.tryParse(row['Количество']?.toString() ?? '') ?? 1;
  final price = (row['Цена за м³'] is num)
      ? row['Цена за м³']
      : double.tryParse(row['Цена за м³']?.toString() ?? '') ?? 0.0;

  double lengthMeters = toMeters(lRaw, lengthUnit);
  int diameterCM = (toCentimeters(dRaw.toDouble(), diameterUnit)).round();

  String method = row['Метод']?.toString() ?? '';
  method = methodMap[method] ?? method;

  double oneVol = 0.0;
  if (method == 'GOST_2708_75') {
    String lengthKey = lengthMeters.toStringAsFixed(1);
    oneVol = GOST_2708_75_TABLE[lengthKey]?[diameterCM] ?? 0.0;
  } else if (method == 'ISO_4480_83') {
    String lengthKey = lengthMeters.toStringAsFixed(1);
    oneVol = ISO_4480_83_TABLE[lengthKey]?[diameterCM] ?? 0.0;
  } else if (method == 'jas_formula') {
    double dCm = diameterCM.toDouble();
    oneVol = (dCm * dCm * lengthMeters) / 10000;
  } else if (method == 'jas_table') {
    double dCm = diameterCM.toDouble();
    double jasDiameter = roundDiameterForJAS(dCm);
    double jas = (jasDiameter * jasDiameter * lengthMeters) / 10000;
    double? coef = getJasCoef(
      lengthMeters,
      jasDiameter,
      species: row['Порода'] ?? 'radiata_pine',
      density: '0.8-1.19',
    );
    if (coef == null || coef <= 0) {
      coef = getJasCoef(
        lengthMeters,
        jasDiameter,
        species: 'radiata_pine',
        density: '0.8-1.19',
      );
    }
    if (coef != null && coef > 0) {
      oneVol = jas / coef;
    } else {
      oneVol = 0.0;
    }
  } else if (method == 'neller') {
    double dCm = diameterCM.toDouble(); // диаметр в сантиметрах!
    oneVol = (3.14159 * dCm * dCm * 0.785 / 40000) * lengthMeters;
  } else if (method == 'neller_simple') {
    double dCm = diameterCM.toDouble();
    oneVol = (3.14159 * dCm * dCm / 40000) * lengthMeters;
  } else if (method == 'mean_diameter_formula') {
    double d2 = diameterCM / 100.0;
    oneVol = (3.14159 / 4) * ((diameterCM / 100.0) * (diameterCM / 100.0) + (diameterCM / 100.0) * d2 + d2 * d2) * lengthMeters;
  } else if (method == 'smalian_formula') {
    double d2 = diameterCM / 100.0;
    oneVol = (3.14159 / 4) * lengthMeters * ((diameterCM / 100.0) * (diameterCM / 100.0) + d2 * d2) / 2;
  } else if (method == 'huber_formula') {
    double dMiddle = diameterCM / 100.0;
    oneVol = (3.14159 / 4) * dMiddle * dMiddle * lengthMeters;
  } else if (method == 'newton_formula') {
    double dMiddle = diameterCM / 100.0;
    oneVol = (3.14159 * lengthMeters / 24) *
        ((diameterCM / 100.0) * (diameterCM / 100.0) + 4 * dMiddle * dMiddle + (diameterCM / 100.0) * (diameterCM / 100.0));
  }

  final v = oneVol * qty;
  row['Объем'] = v;
  row['Итоговая цена'] = v * price;

double density = 600;
if (row['Плотность'] != null) {
  density = double.tryParse(row['Плотность'].toString()) ?? 600;
} else if (row['Порода'] != null && speciesMeta.containsKey(row['Порода'])) {
  density = speciesMeta[row['Порода']]!.density ?? 600;
} else if (row['Порода'] != null && speciesDensity.containsKey(row['Порода'])) {
  density = speciesDensity[row['Порода']]!;
}
  double percentage = 0.0;
  if (row['Порода'] != null && speciesMeta.containsKey(row['Порода'])) {
    percentage = speciesMeta[row['Порода']]?.barkCorrection ?? 0.0;
  }
  double volumeWithBark = v * (1 + percentage);

  // --- УЧЁТ ВЛАЖНОСТИ ---
  double moistureCoef = 1 + woodMoisture / 100;
  double netWeightKg = v * density * moistureCoef;
  double grossWeightKg = percentage > 0
      ? volumeWithBark * density * moistureCoef
      : netWeightKg + toKg(packageWeight, weightUnit);

  row['Брутто'] = fromKg(grossWeightKg, weightUnit);
  row['Нетто'] = fromKg(netWeightKg, weightUnit);
  row['Объем с корой'] = volumeWithBark;
}