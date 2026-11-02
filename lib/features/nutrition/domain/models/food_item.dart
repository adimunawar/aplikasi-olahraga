import 'package:flutter/foundation.dart';
import '../../../exercises/domain/models/exercise.dart';

@immutable
class FoodItem {
  final String id;
  final LocalizedString name;
  final LocalizedString portionLabel;
  final int portionG;
  final double proteinG;
  final int costTier; // 1 = low, 2 = medium, 3 = high
  final List<String> tags;
  final List<String> allergens;
  final int minPortion;
  final int maxPortion;
  final bool isCustom;

  const FoodItem({
    required this.id,
    required this.name,
    required this.portionLabel,
    required this.portionG,
    required this.proteinG,
    required this.costTier,
    this.tags = const [],
    this.allergens = const [],
    this.minPortion = 1,
    this.maxPortion = 4,
    this.isCustom = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: LocalizedString.fromJson(json['name']),
      portionLabel: LocalizedString.fromJson(json['portion_label']),
      portionG: json['portion_g'] as int? ?? 100,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      costTier: json['cost_tier'] as int? ?? 2,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      allergens: (json['allergens'] as List?)?.map((e) => e.toString()).toList() ?? [],
      minPortion: json['min_portion'] as int? ?? 1,
      maxPortion: json['max_portion'] as int? ?? 4,
      isCustom: json['is_custom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': {'id': name.id, 'en': name.en},
        'portion_label': {'id': portionLabel.id, 'en': portionLabel.en},
        'portion_g': portionG,
        'protein_g': proteinG,
        'cost_tier': costTier,
        'tags': tags,
        'allergens': allergens,
        'min_portion': minPortion,
        'max_portion': maxPortion,
        'is_custom': isCustom,
      };
}

