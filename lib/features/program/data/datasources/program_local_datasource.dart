import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/program_day.dart';

class ProgramLocalDatasource {
  static const String _assetPath = 'assets/data/program_30_days.json';
  List<ProgramDay>? _cachedDays;

  Future<List<ProgramDay>> load30Days() async {
    if (_cachedDays != null) return _cachedDays!;

    final jsonString = await rootBundle.loadString(_assetPath);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    final daysList = (map['days'] as List<dynamic>)
        .map((e) => ProgramDay.fromJson(e as Map<String, dynamic>))
        .toList();

    _cachedDays = daysList;
    return _cachedDays!;
  }
}

