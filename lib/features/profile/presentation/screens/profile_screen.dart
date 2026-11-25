import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/profile_controller.dart';
import '../widgets/body_information_card.dart';
import '../widgets/profile_menu_item_card.dart';
import '../widgets/user_identity_hero_card.dart';

/// Halaman Profile & Pengaturan:
/// Presentation Layer murni (ConsumerWidget) dengan Riverpod 2.x
/// serta AppBar standar Material 3 & dukungan penuh Light/Dark Mode.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Profile',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: () =>
              ref.read(profileControllerProvider.notifier).loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserIdentityHeroCard(
                  name: state.displayName,
                  status: state.journeyStatus,
                  onEdit: () => context.push(AppRoutes.personalInfo),
                ),
                const SizedBox(height: 16),
                BodyInformationCard(
                  weight: state.currentWeight,
                  height: state.currentHeight,
                  bmi: state.currentBmi,
                  onEdit: () => context.push(AppRoutes.bodyInfo),
                ),
                const SizedBox(height: 16),
                ProfileMenuItemCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  subtitle: 'Name, age, and gender',
                  onTap: () => context.push(AppRoutes.personalInfo),
                ),
                const SizedBox(height: 10),
                ProfileMenuItemCard(
                  icon: Icons.track_changes_rounded,
                  title: 'Fitness Goals',
                  subtitle: 'Goal, target weight, and experience level',
                  onTap: () => context.push(AppRoutes.fitnessGoals),
                ),
                const SizedBox(height: 10),
                ProfileMenuItemCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Workout Preferences',
                  subtitle: 'Training days, duration, and intensity',
                  onTap: () => context.push(AppRoutes.workoutPreferences),
                ),
                const SizedBox(height: 10),
                ProfileMenuItemCard(
                  icon: Icons.notifications_none_rounded,
                  title: 'Reminders',
                  subtitle: 'Workout and progress notifications',
                  onTap: () => context.push(AppRoutes.reminders),
                ),
                const SizedBox(height: 10),
                ProfileMenuItemCard(
                  icon: Icons.settings_outlined,
                  title: 'App Settings',
                  subtitle: 'Language, theme, units, and more',
                  onTap: () => context.push(AppRoutes.appSettings),
                ),
                const SizedBox(height: 10),
                ProfileMenuItemCard(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & About',
                  subtitle: 'Support, feedback, and app information',
                  onTap: () => context.push(AppRoutes.helpAbout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
