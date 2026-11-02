import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/exercise.dart';

class ExerciseLocalDatasource {
  static const String _assetPath = 'assets/data/exercises.json';
  List<Exercise>? _cachedExercises;

  Future<List<Exercise>> loadExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    _cachedExercises = jsonList
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cachedExercises!;
  }
}

