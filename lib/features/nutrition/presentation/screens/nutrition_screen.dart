import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/food_item.dart';
import '../../domain/services/protein_recommendation_engine.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<FoodItem> _foods = [];
  bool _isLoading = true;

  double _dailyTargetG = 100.0;
  double _loggedTodayG = 0.0;
  List<String> _loggedFoodIds = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/foods.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      final parsed =
          list.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();

      // Hitung target protein harian dari profil pengguna di SQLite
      final profile = await AppDatabase.instance.getUserProfile();
      final weight =
          profile.currentWeightKg > 0 ? profile.currentWeightKg : 65.0;
      final multiplier = profile.goal == 'muscle_gain' ? 1.8 : 1.6;
      final targetProtein = (weight * multiplier).roundToDouble();

      // Muat log hari ini dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final todayKey = DateTime.now().toIso8601String().substring(0, 10);
      final savedLogged = prefs.getDouble('nutrition_protein_$todayKey') ?? 0.0;
      final savedFoodIds =
          prefs.getStringList('nutrition_foods_$todayKey') ?? [];

      if (mounted) {
        setState(() {
          _foods = parsed;
          _dailyTargetG = targetProtein;
          _loggedTodayG = savedLogged;
          _loggedFoodIds = savedFoodIds;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logFood(FoodItem food) async {
    final newLogged = _loggedTodayG + food.proteinG;
    final updatedList = List<String>.from(_loggedFoodIds)..add(food.id);

    setState(() {
      _loggedTodayG = newLogged;
      _loggedFoodIds = updatedList;
    });

    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setDouble('nutrition_protein_$todayKey', newLogged);
    await prefs.setStringList('nutrition_foods_$todayKey', updatedList);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        behavior: SnackBarBehavior.floating,
        content: Text(
          '+${food.proteinG.toStringAsFixed(0)}g protein dicatat (${food.name.id})',
          style: AppTypography.bodySmall.copyWith(color: AppColors.electricLime),
        ),
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Catat Protein Manual',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Gram Protein (g)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.electricLime),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Batal', style: TextStyle(color: AppColors.textDim)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricLime,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final val = double.tryParse(controller.text);
                if (val != null && val > 0) {
                  final newLogged = _loggedTodayG + val;
                  setState(() => _loggedTodayG = newLogged);
                  final prefs = await SharedPreferences.getInstance();
                  final todayKey =
                      DateTime.now().toIso8601String().substring(0, 10);
                  await prefs.setDouble('nutrition_protein_$todayKey', newLogged);
                }
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              child: const Text('Catat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.electricLime),
        ),
      );
    }

    final remaining = (_dailyTargetG - _loggedTodayG).clamp(0.0, 999.0);
    final ratio = (_loggedTodayG / _dailyTargetG).clamp(0.0, 1.0);

    final recommendations = ProteinRecommendationEngine.recommend(
      remainingProteinG: remaining,
      availableFoods: _foods,
      userExcludedAllergens: {},
      loggedFoodIdsToday: _loggedFoodIds.toSet(),
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: Text(
          'PANDUAN PROTEIN HARIAN',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.electricLime),
            tooltip: 'Tambah Manual',
            onPressed: _showManualInputDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Box
            _buildStatusCard(remaining, ratio),

            const SizedBox(height: 24),

            // Smart Recommendation Engine Box
            if (remaining > 0 && recommendations.isNotEmpty) ...[
              _buildRecommendationsBox(recommendations),
              const SizedBox(height: 24),
            ],

            // Local Food Database List
            Text(
              'KATALOG MAKANAN PROTEIN LOKAL',
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _foods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final food = _foods[index];
                return _buildFoodItemRow(food);
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(double remaining, double ratio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TARGET SINTESIS OTOT',
                style: AppTypography.labelCaps.copyWith(color: AppColors.textDim),
              ),
              Text(
                '${_loggedTodayG.toStringAsFixed(0)} / ${_dailyTargetG.toStringAsFixed(0)} g',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.electricLime,
                  fontSize: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.surfaceRaised,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricLime),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining <= 0
                ? 'Target hari ini tercapai! Pertahankan kecukupan istirahat & air.'
                : 'Terpenuhi ${_loggedTodayG.toStringAsFixed(0)} g dari ${_dailyTargetG.toStringAsFixed(0)} g (Sisa ${remaining.toStringAsFixed(0)} g lagi).',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsBox(List<FoodCombination> recommendations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.iceCyan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.iceCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'SARAN KOMBINASI HEMAT (± SISA PROTEIN)',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.iceCyan,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((combo) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      combo.items.map((i) => '${i.portion}x ${i.food.name.id}').join(' + '),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '± ${combo.totalProtein.toStringAsFixed(0)} g',
                    style: AppTypography.tabularMetricSmall.copyWith(
                      color: AppColors.iceCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFoodItemRow(FoodItem food) {
    final costLabel = food.costTier == 1 ? 'Rp (Murah)' : food.costTier == 2 ? 'Rp Rp (Sedang)' : 'Rp Rp Rp (Tinggi)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      food.name.id,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        costLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textDim,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${food.portionLabel.id} • ± ${food.proteinG.toStringAsFixed(0)}g protein',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceRaised,
              foregroundColor: AppColors.electricLime,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _logFood(food),
            child: Text(
              '+ Catat',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.electricLime,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

