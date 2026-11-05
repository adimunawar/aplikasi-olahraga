import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/user_identity_hero_card.dart';
import '../widgets/body_information_card.dart';
import '../widgets/profile_menu_item_card.dart';

/// Halaman Profile & Pengaturan:
/// Presentation Layer murni (ConsumerWidget) dengan Riverpod 2.x
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.darkCharcoal,
          backgroundColor: AppColors.limeAccent,
          onRefresh: () =>
              ref.read(profileControllerProvider.notifier).loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Profile
                const ProfileHeader(),
                const SizedBox(height: 16),

                // 2. User Identity Hero Card
                UserIdentityHeroCard(
                  name: state.displayName,
                  status: state.journeyStatus,
                  onEdit: () => context.push(AppRoutes.personalInfo),
                ),
                const SizedBox(height: 16),

                // 3. Body Information Card (Weight, Height, BMI)
                BodyInformationCard(
                  weight: state.currentWeight,
                  height: state.currentHeight,
                  bmi: state.currentBmi,
                  onEdit: () => context.push(AppRoutes.bodyInfo),
                ),
                const SizedBox(height: 16),

                // 4. Menu Pengaturan & Preferensi
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
                  subtitle:
                      'Goal, target weight, and experience level',
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menu $title siap digunakan!'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.darkCharcoal,
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama Lengkap'),
        ),
        actions: [
          AppButton.secondary(
            text: 'Batal',
            size: AppButtonSize.small,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton.primary(
            text: 'Simpan',
            size: AppButtonSize.small,
            isFullWidth: false,
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(ctx);
                await ref
                    .read(profileControllerProvider.notifier)
                    .updateDisplayName(newName);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Nama berhasil disimpan & disinkronkan ke Supabase! ✓',
                      ),
                      backgroundColor: AppColors.darkCharcoal,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditBodyDataDialog(
    BuildContext context,
    WidgetRef ref,
    double currentWeight,
    double currentHeight,
  ) {
    final weightController = TextEditingController(
      text: currentWeight.toString(),
    );
    final heightController = TextEditingController(
      text: currentHeight.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Body Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Berat Badan (kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeAccent,
              foregroundColor: AppColors.darkCharcoal,
            ),
            onPressed: () async {
              final w = double.tryParse(weightController.text);
              final h = double.tryParse(heightController.text);
              if (w != null && h != null && w > 0 && h > 0) {
                Navigator.pop(ctx);
                await ref
                    .read(profileControllerProvider.notifier)
                    .updateBodyData(weightKg: w, heightCm: h);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data tubuh berhasil disimpan & disinkronkan ke Supabase! ✓',
                      ),
                      backgroundColor: AppColors.darkCharcoal,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
