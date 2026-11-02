import '../models/food_item.dart';

class FoodCombinationItem {
  final FoodItem food;
  final int portion;

  const FoodCombinationItem({required this.food, required this.portion});

  double get totalProtein => food.proteinG * portion;
  int get totalCost => food.costTier * portion;
}

class FoodCombination {
  final List<FoodCombinationItem> items;

  const FoodCombination({required this.items});

  double get totalProtein =>
      items.fold(0.0, (sum, item) => sum + item.totalProtein);

  int get totalCost => items.fold(0, (sum, item) => sum + item.totalCost);

  int get itemCount => items.length;
}

class ProteinRecommendationEngine {
  /// Generates up to 3 smart food recommendations for remaining protein.
  static List<FoodCombination> recommend({
    required double remainingProteinG,
    required List<FoodItem> availableFoods,
    required Set<String> userExcludedAllergens,
    required Set<String> loggedFoodIdsToday,
  }) {
    if (remainingProteinG <= 0) {
      return [];
    }

    // Filter available foods
    final eligibleFoods = availableFoods.where((food) {
      final hasAllergen = food.allergens.any(userExcludedAllergens.contains);
      return !hasAllergen;
    }).toList();

    if (eligibleFoods.isEmpty) return [];

    // If remaining protein is very small (< 5g), return 1 light item (e.g. 1 egg)
    if (remainingProteinG < 5.0) {
      final lightFood = eligibleFoods.firstWhere(
        (f) => f.proteinG <= 8.0,
        orElse: () => eligibleFoods.first,
      );
      return [
        FoodCombination(
          items: [FoodCombinationItem(food: lightFood, portion: 1)],
        )
      ];
    }

    final List<FoodCombination> candidates = [];

    // 1-item combinations
    for (final f1 in eligibleFoods) {
      for (int p1 = f1.minPortion; p1 <= f1.maxPortion; p1++) {
        final protein = f1.proteinG * p1;
        if ((protein - remainingProteinG).abs() <= 3.0) {
          candidates.add(FoodCombination(
            items: [FoodCombinationItem(food: f1, portion: p1)],
          ));
        }
      }
    }

    // 2-item combinations
    for (int i = 0; i < eligibleFoods.length; i++) {
      final f1 = eligibleFoods[i];
      for (int j = i + 1; j < eligibleFoods.length; j++) {
        final f2 = eligibleFoods[j];
        for (int p1 = 1; p1 <= 2; p1++) {
          for (int p2 = 1; p2 <= 2; p2++) {
            final protein = (f1.proteinG * p1) + (f2.proteinG * p2);
            if ((protein - remainingProteinG).abs() <= 3.0) {
              candidates.add(FoodCombination(
                items: [
                  FoodCombinationItem(food: f1, portion: p1),
                  FoodCombinationItem(food: f2, portion: p2),
                ],
              ));
            }
          }
        }
      }
    }

    // Sort by:
    // 1. Cost tier (lowest first)
    // 2. Diversity bonus (penalize foods already eaten today)
    // 3. Closeness to target
    // 4. Fewest items
    candidates.sort((a, b) {
      // Penalty for repeat foods
      final aRepeats = a.items.where((i) => loggedFoodIdsToday.contains(i.food.id)).length;
      final bRepeats = b.items.where((i) => loggedFoodIdsToday.contains(i.food.id)).length;

      if (aRepeats != bRepeats) {
        return aRepeats.compareTo(bRepeats);
      }

      // Cost tier
      if (a.totalCost != b.totalCost) {
        return a.totalCost.compareTo(b.totalCost);
      }

      // Protein delta
      final aDelta = (a.totalProtein - remainingProteinG).abs();
      final bDelta = (b.totalProtein - remainingProteinG).abs();
      if ((aDelta - bDelta).abs() > 0.1) {
        return aDelta.compareTo(bDelta);
      }

      // Item count
      return a.itemCount.compareTo(b.itemCount);
    });

    // Return top 3 distinct combinations
    return candidates.take(3).toList();
  }
}

