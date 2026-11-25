import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/app_settings_widgets.dart';
import '../widgets/profile_form_widgets.dart';

/// Screen 4 Mockup: Fitness Goals (Light & Dark Mode)
class FitnessGoalsScreen extends ConsumerStatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  ConsumerState<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends ConsumerState<FitnessGoalsScreen> {
  late String _selectedGoal;
  late final TextEditingController _targetWeightController;
  late String _selectedLevel;

  final List<String> _goals = const [
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
    _targetWeightController = TextEditingController(
      text: profile.targetWeight.toStringAsFixed(1),
    );
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

  Future<void> _saveChanges() async {
    final tw = double.tryParse(_targetWeightController.text) ?? 65.0;

    await ref
        .read(profileControllerProvider.notifier)
        .updateFitnessGoals(
          goal: _selectedGoal,
          targetWeight: tw,
          experienceLevel: _selectedLevel,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitness goals updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Fitness Goals',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set your goal and training experience.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.track_changes_rounded,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Main Goal',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ProfileDropdownField(
                      valueText: _selectedGoal,
                      onTap: () => showAppSettingsPickerSheet(
                        context: context,
                        title: 'Select Main Goal',
                        options: _goals,
                        selectedValue: _selectedGoal,
                        onSelected: (goal) =>
                            setState(() => _selectedGoal = goal),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.scale_outlined,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Target Weight (optional)',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      variant: AppCardVariant.flat,
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _targetWeightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'kg',
                            style: AppTypography.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Experience Level',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProfileChoiceChipRow<String>(
                      options: const ['Beginner', 'Intermediate', 'Advanced'],
                      selectedValue: _selectedLevel,
                      labelBuilder: (l) => l,
                      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
                      onSelected: (l) => setState(() => _selectedLevel = l),
                    ),
                    const SizedBox(height: 18),
                    ProfileInfoBanner(message: _levelDescription),
                  ],
                ),
              ),
            ),
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
