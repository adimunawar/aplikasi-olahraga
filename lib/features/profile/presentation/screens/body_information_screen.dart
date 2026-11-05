import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';

/// Screen 3 Mockup: Body Information
/// - Weight row (icon, label, value input, suffix kg)
/// - Height row (icon, label, value input, suffix cm)
/// - Interactive Live BMI Card (rainbow gauge bar with category label)
/// - Last Updated date
/// - Save Changes button
class BodyInformationScreen extends ConsumerStatefulWidget {
  const BodyInformationScreen({super.key});

  @override
  ConsumerState<BodyInformationScreen> createState() =>
      _BodyInformationScreenState();
}

class _BodyInformationScreenState extends ConsumerState<BodyInformationScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  double _calculatedBmi = 19.2;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider);
    _weightController =
        TextEditingController(text: profile.currentWeight.toStringAsFixed(1));
    _heightController =
        TextEditingController(text: profile.currentHeight.toStringAsFixed(0));
    _calculatedBmi = profile.currentBmi;

    _weightController.addListener(_recalculateBmi);
    _heightController.addListener(_recalculateBmi);
  }

  void _recalculateBmi() {
    final w = double.tryParse(_weightController.text);
    final h = double.tryParse(_heightController.text);
    if (w != null && h != null && h > 0 && w > 0) {
      final hM = h / 100.0;
      final bmi = double.parse((w / (hM * hM)).toStringAsFixed(1));
      setState(() => _calculatedBmi = bmi);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String get _bmiCategory {
    if (_calculatedBmi < 18.5) return 'Underweight';
    if (_calculatedBmi < 25.0) return 'Healthy';
    if (_calculatedBmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    if (_calculatedBmi < 18.5) return const Color(0xFF38BDF8); // Blue
    if (_calculatedBmi < 25.0) return const Color(0xFF4ADE80); // Green
    if (_calculatedBmi < 30.0) return const Color(0xFFFB923C); // Orange
    return const Color(0xFFF87171); // Red
  }

  double get _bmiPointerFraction {
    // Range 15 to 35
    final clamped = _calculatedBmi.clamp(15.0, 35.0);
    return (clamped - 15.0) / (35.0 - 15.0);
  }

  Future<void> _saveChanges() async {
    final w = double.tryParse(_weightController.text);
    final h = double.tryParse(_heightController.text);

    if (w == null || h == null || w <= 0 || h <= 0) return;

    await ref.read(profileControllerProvider.notifier).updateBodyData(
          weightKg: w,
          heightCm: h,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Body information updated successfully!'),
          backgroundColor: AppColors.darkCharcoal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);

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
          'Body Information',
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
                      'Update your height, weight, and see your BMI.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Weight Row
                    _buildInputRow(
                      icon: Icons.scale_outlined,
                      label: 'Weight',
                      controller: _weightController,
                      suffix: 'kg',
                      isDecimal: true,
                    ),
                    const SizedBox(height: 14),

                    // 2. Height Row
                    _buildInputRow(
                      icon: Icons.straighten_rounded,
                      label: 'Height',
                      controller: _heightController,
                      suffix: 'cm',
                      isDecimal: false,
                    ),
                    const SizedBox(height: 22),

                    // 3. BMI Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE9ECEF), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.limeCardSurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.favorite_border_rounded,
                                  color: AppColors.greenDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your BMI',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.neutral500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _calculatedBmi.toStringAsFixed(1),
                                        style: AppTypography.tabularMetricLarge
                                            .copyWith(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22,
                                          color: const Color(0xFF141718),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _bmiColor.withValues(alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _bmiCategory,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                            color: _bmiColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.neutral400,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Rainbow BMI Progress Gauge
                          LayoutBuilder(builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth;
                            final pointerPos = (totalWidth * _bmiPointerFraction)
                                .clamp(4.0, totalWidth - 12.0);

                            return Column(
                              children: [
                                // Pointer Triangle
                                SizedBox(
                                  width: totalWidth,
                                  height: 8,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: pointerPos,
                                        child: const Icon(
                                          Icons.arrow_drop_down_rounded,
                                          size: 16,
                                          color: Color(0xFF141718),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Segmented Gradient Bar
                                Container(
                                  height: 8,
                                  width: totalWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF38BDF8), // Blue
                                        Color(0xFF4ADE80), // Green
                                        Color(0xFFFB923C), // Orange
                                        Color(0xFFF87171), // Red
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Labels Under Bar
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildBmiScaleLabel(
                                        '< 18.5', 'Underweight'),
                                    _buildBmiScaleLabel(
                                        '18.5 – 24.9', 'Healthy'),
                                    _buildBmiScaleLabel(
                                        '25 – 29.9', 'Overweight'),
                                    _buildBmiScaleLabel('≥ 30', 'Obese'),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Last Updated Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFE9ECEF), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: Color(0xFF141718),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Last Updated',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: const Color(0xFF141718),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            profile.lastUpdatedDate,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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

  Widget _buildInputRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String suffix,
    required bool isDecimal,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF141718)),
          const SizedBox(width: 14),
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFF141718),
            ),
          ),
          const Spacer(),
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF141718),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            suffix,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiScaleLabel(String range, String label) {
    return Column(
      children: [
        Text(
          range,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF141718),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

