import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/application/bmi_calculator_service.dart';

void main() {
  const service = BmiCalculatorService();

  group('BmiCalculatorService', () {
    test('calculates BMI correctly', () {
      final bmi = service.calculateBmi(weightKg: 70, heightCm: 175);
      expect(bmi, 22.9);
    });

    test('calculates BMI with different inputs', () {
      final bmi = service.calculateBmi(weightKg: 80, heightCm: 180);
      expect(bmi, 24.7);
    });

    test('classifies BMI as underweight', () {
      final bmi = service.calculateBmi(weightKg: 50, heightCm: 170);
      expect(bmi, 17.3);
      expect(service.getBmiStatus(bmi), 'Underweight');
    });

    test('classifies BMI as healthy', () {
      final bmi = service.calculateBmi(weightKg: 70, heightCm: 175);
      expect(bmi, 22.9);
      expect(service.getBmiStatus(bmi), 'Healthy');
    });

    test('classifies BMI as overweight', () {
      final bmi = service.calculateBmi(weightKg: 85, heightCm: 175);
      expect(bmi, 27.8);
      expect(service.getBmiStatus(bmi), 'Overweight');
    });

    test('classifies BMI as obese', () {
      final bmi = service.calculateBmi(weightKg: 95, heightCm: 175);
      expect(bmi, 31.0);
      expect(service.getBmiStatus(bmi), 'Obese');
    });

    test('handles invalid inputs safely with zero', () {
      expect(service.calculateBmi(weightKg: 0, heightCm: 175), 0);
      expect(service.calculateBmi(weightKg: -70, heightCm: 175), 0);
      expect(service.calculateBmi(weightKg: 70, heightCm: 0), 0);
      expect(service.calculateBmi(weightKg: 70, heightCm: -175), 0);
    });
  });
}
