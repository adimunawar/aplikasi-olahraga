import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';

/// Screen 5 Mockup: Workout Preferences
/// - Training Days per Week (Pill 2, 3, 4, 5, 6)
/// - Workout Duration dropdown (30, 45, 60 minutes)
/// - Training Intensity segmented toggle (Low, Moderate, High)
/// - Info Card with dynamic explanation
/// - Save Changes button
class WorkoutPreferencesScreen extends ConsumerStatefulWidget {
  const WorkoutPreferencesScreen({super.key});

  @override
  ConsumerState<WorkoutPreferencesScreen> createState() =>
      _WorkoutPreferencesScreenState();
}

class _WorkoutPreferencesScreenState
    extends ConsumerState<WorkoutPreferencesScreen> {
  late int _selectedDays;
  late int _selectedDuration;
  late String _selectedIntensity;

  final List<int> _durations = [30, 45, 60];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider);
    _selectedDays = profile.preferredDaysPerWeek;
    _selectedDuration = profile.preferredDurationMin;
    _selectedIntensity = profile.trainingIntensity.isNotEmpty
        ? profile.trainingIntensity
        : 'Moderate';
  }

  String get _intensityDescription {
    switch (_selectedIntensity.toLowerCase()) {
      case 'low':
        return 'Low: Light tempo with longer rest periods, suitable for active recovery or easing into routine.';
      case 'high':
        return 'High: Intense tempo with shorter rest periods, pushing higher fatigue for maximum conditioning.';
      case 'moderate':
      default:
        return 'Moderate: Balanced intensity, suitable for bulking and building muscle consistently.';
    }
  }

  void _showDurationPicker() {
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
                  'Select Workout Duration',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 1),
              ..._durations.map((d) {
                final isSelected = d == _selectedDuration;
                return ListTile(
                  title: Text(
                    '$d minutes',
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
                    setState(() => _selectedDuration = d);
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
    await ref
        .read(profileControllerProvider.notifier)
        .updateWorkoutPreferences(
          trainingDaysPerWeek: _selectedDays,
          workoutDurationMin: _selectedDuration,
          trainingIntensity: _selectedIntensity,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout preferences updated successfully!'),
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
          'Workout Preferences',
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
                      'Customize your training schedule and style.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Training Days Per Week (2, 3, 4, 5, 6)
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined,
                            size: 18, color: Color(0xFF141718)),
                        const SizedBox(width: 8),
                        Text(
                          'Training Days per Week',
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
                      children: [2, 3, 4, 5, 6].map((days) {
                        final isSelected = _selectedDays == days;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDays = days),
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
                                  '$days',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                    fontSize: 14,
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
                    const SizedBox(height: 20),

                    // 2. Workout Duration Dropdown
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 18, color: Color(0xFF141718)),
                        const SizedBox(width: 8),
                        Text(
                          'Workout Duration',
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
                      onTap: _showDurationPicker,
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
                              '$_selectedDuration minutes',
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

                    // 3. Training Intensity (Low, Moderate, High)
                    Row(
                      children: [
                        const Icon(Icons.bar_chart_rounded,
                            size: 18, color: Color(0xFF141718)),
                        const SizedBox(width: 8),
                        Text(
                          'Training Intensity',
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
                      children: ['Low', 'Moderate', 'High'].map((intensity) {
                        final isSelected = _selectedIntensity.toLowerCase() ==
                            intensity.toLowerCase();
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedIntensity = intensity),
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
                                  intensity,
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
                              _intensityDescription,
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

