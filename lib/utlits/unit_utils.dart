double toMeters(double value, String unit) {
  if (unit == 'м') return value;
  if (unit == 'см') return value / 100;
  if (unit == 'мм') return value / 1000;
  return value;
}

double toCentimeters(double value, String unit) {
  if (unit == 'см') return value;
  if (unit == 'мм') return value / 10;
  if (unit == 'м') return value * 100;
  return value;
}

double fromKg(double value, String unit) {
  if (unit == 'т') return value / 1000;
  return value;
}

double toKg(double value, String unit) {
  if (unit == 'т') return value * 1000;
  return value;
}