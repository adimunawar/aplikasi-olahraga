import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/app_settings_widgets.dart';
import '../widgets/profile_form_widgets.dart';

/// Screen 5 Mockup: Workout Preferences (Light & Dark Mode)
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

  final List<int> _durations = const [30, 45, 60];

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
          'Workout Preferences',
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
                      'Customize your training schedule and style.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Training Days per Week',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProfileChoiceChipRow<int>(
                      options: const [2, 3, 4, 5, 6],
                      selectedValue: _selectedDays,
                      labelBuilder: (d) => '$d',
                      onSelected: (d) => setState(() => _selectedDays = d),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Workout Duration',
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
                      valueText: '$_selectedDuration minutes',
                      onTap: () => showAppSettingsPickerSheet(
                        context: context,
                        title: 'Select Workout Duration',
                        options: _durations.map((d) => '$d minutes').toList(),
                        selectedValue: '$_selectedDuration minutes',
                        onSelected: (label) {
                          final parsed = int.tryParse(label.split(' ').first);
                          if (parsed != null) {
                            setState(() => _selectedDuration = parsed);
                          }
                        },
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
                          'Training Intensity',
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
                      options: const ['Low', 'Moderate', 'High'],
                      selectedValue: _selectedIntensity,
                      labelBuilder: (i) => i,
                      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
                      onSelected: (i) => setState(() => _selectedIntensity = i),
                    ),
                    const SizedBox(height: 18),
                    ProfileInfoBanner(message: _intensityDescription),
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
