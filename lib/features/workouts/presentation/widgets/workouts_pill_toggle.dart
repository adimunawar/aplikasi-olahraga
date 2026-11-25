import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/widgets/core_widgets.dart';

/// Toggle tab navigasi Workouts menggunakan standar Material 3 [AppSegmentedTabs].
class WorkoutsPillToggle extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final String myProgramTitle;
  final String allWorkoutsTitle;

  const WorkoutsPillToggle({
    super.key,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.myProgramTitle,
    required this.allWorkoutsTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppSegmentedTabs<int>(
      selectedValue: selectedTabIndex,
      onChanged: onTabChanged,
      tabs: [
        AppSegmentedTabItem<int>(value: 0, label: myProgramTitle),
        AppSegmentedTabItem<int>(value: 1, label: allWorkoutsTitle),
      ],
    );
  }
}
