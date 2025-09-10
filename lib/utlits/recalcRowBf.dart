import '../widgets/doyle_log_rule_table.dart';
import '../widgets/International_Inch_Log_Rule_Table.dart';
import '../widgets/Scribner-Log-Volume-Table.dart';
import '../data/species_meta BF.dart' as meta;

void recalcRowBf(
  Map<String, dynamic> row,
  Map<String, double> speciesDensity,
  Map<String, meta.SpeciesMeta> speciesMeta,
  double packageWeight,
  String weightUnit,
  String lengthUnit,
  String diameterUnit,
  double woodMoisture,
) {
  final method = row['Метод'];
  // Исправлено: корректный парсинг для int/double/строка
  final diameter = (double.tryParse(row['Диаметр'].toString()) ?? 0).round();
  final length = (double.tryParse(row['Длина'].toString()) ?? 0).round();
  final qty = int.tryParse(row['Количество'].toString()) ?? 1;
  final price = double.tryParse(row['Цена за BF']?.toString() ?? '0') ?? 0.0;

  double oneVol = 0.0;

  // Табличные методы
  if (method == 'Doyle Log Rule (table)') {
    oneVol = getDoyleLogRuleValue(diameter, length)?.toDouble() ?? 0;
  } else if (method == 'International 1/4-Inch Log Rule (table)') {
    oneVol =
        getInternationalInchLogRuleValue(diameter, length)?.toDouble() ?? 0;
  } else if (method == 'Scribner Log Volume Table') {
    oneVol = scribnerLogVolumeTable[length]?[diameter]?.toDouble() ?? 0;
  }
  // Формульные методы
  else if (method == 'Doyle Log Rule') {
    if (diameter > 4) {
      oneVol = ((diameter - 4) * (diameter - 4) * length) / 16.0;
    }
  } else if (method == 'International 1/4-Inch Log Rule') {
    double coeff = length / 4.0;
    oneVol = 0.199 * diameter * diameter * coeff -
        0.642 * diameter * coeff -
        1.0 * coeff;
    // Убеждаемся, что результат не отрицательный
    if (oneVol < 0) oneVol = 0.0;
  } else if (method == 'Scribner Log Rule') {
    oneVol = ((diameter * diameter * length) / 16.0) -
        (0.033 * diameter * (diameter - 1));
    // Убеждаемся, что результат не отрицательный
    if (oneVol < 0) oneVol = 0.0;
  } else {
    // Если метод не американский — оставляем старое значение или 0
    oneVol = double.tryParse(row['Объем']?.toString() ?? '0') ?? 0.0;
  }

  // Рассчитываем общий объем и цену
  final volume = oneVol * qty;
  final totalPrice = volume * price;

  // Обновляем основные поля
  row['Объем'] = volume;
  row['Итоговая цена'] = totalPrice;

  // Расчет плотности
  double density = 50.0;
  if (row['Порода'] != null && speciesMeta.containsKey(row['Порода'])) {
    density = speciesMeta[row['Порода']]!.density ?? 50.0;
  } else if (row['Порода'] != null &&
      speciesDensity.containsKey(row['Порода'])) {
    density = speciesDensity[row['Порода']]!;
  }

  // Расчет коррекции коры
  double barkPercent = 0.0;
  if (row['Порода'] != null && speciesMeta.containsKey(row['Порода'])) {
    barkPercent = speciesMeta[row['Порода']]!.barkCorrection ?? 0.0;
  }

  // Расчет объема с корой
  final volumeWithBark = volume * (1 + barkPercent / 100.0);

  // Коэффициент влажности
  final moistureCoef = 1 + (woodMoisture / 100.0);

  // Конвертируем объем из BF в кубические футы (1 BF = 1/12 cubic feet)
  final volumeInCubicFeet = volume / 12.0;
  final volumeWithBarkInCubicFeet = volumeWithBark / 12.0;

  // Рассчитываем веса (плотность в фунтах на кубический фут)
  final netWeight = volumeInCubicFeet * density * moistureCoef;
  final grossWeight =
      volumeWithBarkInCubicFeet * density * moistureCoef + packageWeight;

  // Конвертируем веса в зависимости от единиц измерения
  double finalNetWeight = netWeight;
  double finalGrossWeight = grossWeight;

  if (weightUnit == 'кг' || weightUnit == 'kg') {
    // Конвертируем из фунтов в килограммы (1 фунт = 0.453592 кг)
    finalNetWeight = netWeight * 0.453592;
    finalGrossWeight = grossWeight * 0.453592;
  } else if (weightUnit == 'т' || weightUnit == 't') {
    // Конвертируем из фунтов в тонны
    finalNetWeight = netWeight * 0.453592 / 1000.0;
    finalGrossWeight = grossWeight * 0.453592 / 1000.0;
  }
  // Если weightUnit == 'lb' или пустое, оставляем в фунтах

  // Обновляем все расчетные поля
  row['Объем с корой'] = volumeWithBark;
  row['Нетто'] = finalNetWeight;
  row['Брутто'] = finalGrossWeight;
}
