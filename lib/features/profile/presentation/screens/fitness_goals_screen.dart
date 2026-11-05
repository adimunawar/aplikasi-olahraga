import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';

/// Screen 4 Mockup: Fitness Goals
/// - Main Goal dropdown
/// - Target Weight (optional)
/// - Experience Level segmented toggle (Beginner, Intermediate, Advanced)
/// - Info Card with dynamic explanation
/// - Save Changes button
class FitnessGoalsScreen extends ConsumerStatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  ConsumerState<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends ConsumerState<FitnessGoalsScreen> {
  late String _selectedGoal;
  late final TextEditingController _targetWeightController;
  late String _selectedLevel;

  final List<String> _goals = [
    'Build Muscle (Bulking)',
    'Fat Loss & Lean Definition',
    'Strength & Athletic Conditioning',
    'General Health & Mobility',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider);
    _selectedGoal = profile.goal.isNotEmpty
        ? profile.goal
        : 'Build Muscle (Bulking)';
    _targetWeightController =
        TextEditingController(text: profile.targetWeight.toStringAsFixed(1));
    _selectedLevel = profile.experienceLevel.isNotEmpty
        ? profile.experienceLevel
        : 'Beginner';
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  String get _levelDescription {
    switch (_selectedLevel.toLowerCase()) {
      case 'intermediate':
        return 'Intermediate: Trained consistently for 6+ months, focusing on progressive overload and hypertrophy.';
      case 'advanced':
        return 'Advanced: Experienced lifter, maximizing strength, specialized periodization, and advanced calisthenics.';
      case 'beginner':
      default:
        return 'Beginner: New to consistent training, focusing on building good habits and proper movement form.';
    }
  }

  void _showGoalPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Main Goal',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 1),
              ..._goals.map((g) {
                final isSelected = g == _selectedGoal;
                return ListTile(
                  title: Text(
                    g,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.darkCharcoal
                          : AppColors.neutral500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.greenBrand)
                      : null,
                  tileColor: isSelected
                      ? AppColors.limeCardSurface
                      : Colors.transparent,
                  onTap: () {
                    setState(() => _selectedGoal = g);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    final tw = double.tryParse(_targetWeightController.text) ?? 65.0;

    await ref.read(profileControllerProvider.notifier).updateFitnessGoals(
          goal: _selectedGoal,
          targetWeight: tw,
          experienceLevel: _selectedLevel,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitness goals updated successfully!'),
          backgroundColor: AppColors.darkCharcoal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF141718),
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Fitness Goals',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set your goal and training experience.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Main Goal Dropdown
                    Row(
                      children: [
                        const Icon(Icons.track_changes_rounded,
                            size: 18, color: Color(0xFF141718)),
                        const SizedBox(width: 8),
                        Text(
                          'Main Goal',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: const Color(0xFF141718),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showGoalPicker,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFE9ECEF), width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedGoal,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF141718),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.neutral500,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Target Weight (Optional)
                    Row(
                      children: [
                        const Icon(Icons.scale_outlined,
                            size: 18, color: Color(0xFF141718)),
                        const SizedBox(width: 8),
                        Text(
                          'Target Weight (optional)',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: const Color(0xFF141718),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFE9ECEF), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _targetWeightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF141718),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          Text(
                            'kg',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Experience Level Segmented Buttons
                    Row(
                      children: [
                        const Icon(Icons.bar_chart_rounded,
                            size: 18, color: Color(0xFF141718)),
                        const SizedBox(width: 8),
                        Text(
                          'Experience Level',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: const Color(0xFF141718),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: ['Beginner', 'Intermediate', 'Advanced']
                          .map((level) {
                        final isSelected = _selectedLevel.toLowerCase() ==
                            level.toLowerCase();
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedLevel = level),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? const Color(0xFF141718)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // 4. Dynamic Info Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.limeCardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.limeCardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.greenDark,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _levelDescription,
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFF2E4E16),
                                height: 1.4,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Save Changes Button (Sticky)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: AppButton.primary(
                text: 'Save Changes',
                onPressed: _saveChanges,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

