import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_form_widgets.dart';

/// Screen 2 Mockup: Personal Information (Light & Dark Mode)
class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  late final TextEditingController _nameController;
  late int _selectedAge;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider);
    _nameController = TextEditingController(text: profile.displayName);
    _selectedAge = profile.age;
    _selectedGender = profile.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAgePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Age',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  itemCount: 65 - 16 + 1,
                  itemBuilder: (_, index) {
                    final age = 16 + index;
                    final isSelected = age == _selectedAge;
                    return ListTile(
                      title: Text(
                        '$age years',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      tileColor: isSelected
                          ? (isDark
                                ? colorScheme.primaryContainer
                                : AppColors.limeCardSurface)
                          : Colors.transparent,
                      onTap: () {
                        setState(() => _selectedAge = age);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await ref
        .read(profileControllerProvider.notifier)
        .updatePersonalInfo(
          fullName: name,
          age: _selectedAge,
          gender: _selectedGender,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
          'Personal Information',
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
                      'Your basic account information.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppCard(
                      variant: AppCardVariant.flat,
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 20,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Profile Photo',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? colorScheme.primaryContainer
                                  : AppColors.limeCardSurface,
                            ),
                            child: const ClipOval(
                              child: AppSmartImage(
                                imagePathOrUrl:
                                    'assets/images/coach_crossed_arms.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Full Name',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      variant: AppCardVariant.flat,
                      borderRadius: 14,
                      padding: EdgeInsets.zero,
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Age',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProfileDropdownField(
                      valueText: '$_selectedAge years',
                      onTap: _showAgePicker,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Gender',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ProfileChoiceChipRow<String>(
                      options: const ['Male', 'Female', 'Other'],
                      selectedValue: _selectedGender,
                      labelBuilder: (g) => g,
                      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
                      onSelected: (g) => setState(() => _selectedGender = g),
                    ),
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
