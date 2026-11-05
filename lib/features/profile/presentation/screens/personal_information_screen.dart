import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';

/// Screen 2 Mockup: Personal Information
/// - Profile Photo preview
/// - Full Name input
/// - Age picker
/// - Gender segmented toggle (Male, Female, Other)
/// - Bottom Save Changes button
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
                  'Select Age',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.darkCharcoal
                              : AppColors.neutral500,
                          fontSize: 16,
                        ),
                      ),
                      tileColor: isSelected
                          ? AppColors.limeCardSurface
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
          'Personal Information',
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
                        color: AppColors.neutral500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Profile Photo Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 20,
                              color: Color(0xFF141718),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Profile Photo',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: const Color(0xFF141718),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.limeCardSurface,
                            ),
                            child: ClipOval(
                              child: AppSmartImage(
                                imagePathOrUrl:
                                    'assets/images/coach_crossed_arms.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.neutral400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Full Name
                    Text(
                      'Full Name',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 1.2,
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF141718),
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

                    // 3. Age
                    Text(
                      'Age',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showAgePicker,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_selectedAge years',
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

                    // 4. Gender (Segmented Pills: Male, Female, Other)
                    Text(
                      'Gender',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: ['Male', 'Female', 'Other'].map((gender) {
                        final isSelected =
                            _selectedGender.toLowerCase() ==
                            gender.toLowerCase();
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedGender = gender),
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
                                  gender,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 13.5,
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
