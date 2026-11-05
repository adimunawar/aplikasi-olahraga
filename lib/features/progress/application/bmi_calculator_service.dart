/// Layanan komputasi murni Dart untuk kalkulasi BMI (Body Mass Index) & klasifikasi status
class BmiCalculatorService {
  const BmiCalculatorService();

  /// Menghitung nilai BMI dengan rumus: BB(kg) / (TB(m))^2
  double calculateBmi({required double weightKg, required double heightCm}) {
    if (heightCm <= 0 || weightKg <= 0) return 19.2;
    final heightM = heightCm / 100.0;
    final rawBmi = weightKg / (heightM * heightM);
    return double.parse(rawBmi.toStringAsFixed(1));
  }

  /// Menentukan kategori status kesehatan berdasarkan standar WHO
  String getBmiStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Healthy';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }
}

