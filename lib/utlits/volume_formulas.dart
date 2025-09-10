/// ГОСТ, ISO, Неллера и цилиндр — реализуйте по необходимости

// Среднеарифметический диаметр
double volumeAverageDiameter(double d1Cm, double d2Cm, double lM) {
  double dAvgM = ((d1Cm + d2Cm) / 2) / 100;
  return 3.14159265359 * (dAvgM * dAvgM) / 4 * lM;
}

// Смалиана
double volumeSmalian(double d1Cm, double d2Cm, double lM) {
  double s1 = 3.14159265359 * (d1Cm / 100) * (d1Cm / 100) / 4;
  double s2 = 3.14159265359 * (d2Cm / 100) * (d2Cm / 100) / 4;
  return (s1 + s2) / 2 * lM;
}

// Губера
double volumeHuber(double dMiddleCm, double lM) {
  double s = 3.14159265359 * (dMiddleCm / 100) * (dMiddleCm / 100) / 4;
  return s * lM;
}

// Ньютона
double volumeNewton(double d1Cm, double dMiddleCm, double d2Cm, double lM) {
  double s1 = 3.14159265359 * (d1Cm / 100) * (d1Cm / 100) / 4;
  double sm = 3.14159265359 * (dMiddleCm / 100) * (dMiddleCm / 100) / 4;
  double s2 = 3.14159265359 * (d2Cm / 100) * (d2Cm / 100) / 4;
  return (s1 + 4 * sm + s2) / 6 * lM;
}

// JAS Scale (d — мм, L — см)
double volumeJAS(double dMm, double lCm) {
  return 0.0000796 * dMm * dMm * lCm;
}