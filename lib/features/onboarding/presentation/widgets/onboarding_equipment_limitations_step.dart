import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'onboarding_cta_button.dart';
import 'onboarding_dots_indicator.dart';

/// Step Onboarding: Equipment & Limitations (Sesuai PRD Baru P0)
/// - Pilihan Alat Rumah: Bodyweight, Matras, Meja/Kursi kokoh, Kusen Pintu, Dumbbell
/// - Pilihan Batasan Fisik: Bebas cedera, Nyeri lutut, Nyeri pergelangan tangan, Nyeri pinggang
class OnboardingEquipmentLimitationsStep extends StatelessWidget {
  final List<String> selectedEquipments;
  final List<String> selectedLimitations;
  final ValueChanged<List<String>> onEquipmentsChanged;
  final ValueChanged<List<String>> onLimitationsChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingEquipmentLimitationsStep({
    super.key,
    required this.selectedEquipments,
    required this.selectedLimitations,
    required this.onEquipmentsChanged,
    required this.onLimitationsChanged,
    required this.onNext,
    required this.onBack,
  });

  void _toggleEquipment(String id) {
    if (id == 'bodyweight') return; // Bodyweight selalu aktif
    final list = List<String>.from(selectedEquipments);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    onEquipmentsChanged(list);
  }

  void _toggleLimitation(String id) {
    final list = List<String>.from(selectedLimitations);
    if (id == 'none') {
      list.clear();
      list.add('none');
    } else {
      list.remove('none');
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
      if (list.isEmpty) {
        list.add('none');
      }
    }
    onLimitationsChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D1E)),
          onPressed: onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Equipment &\nLimitations',
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1D1E),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agar Coach Adi menyusun latihan yang tepat dan aman untuk kondisimu.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFF71767B),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 1: Equipment
                      Text(
                        'Peralatan di Rumah yang Tersedia',
                        style: AppTypography.labelLarge.copyWith(
                          color: const Color(0xFF1A1D1E),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCheckCard(
                        id: 'bodyweight',
                        title: 'Tanpa Alat (Lantai Rumah)',
                        subtitle: 'Gerakan murni beban tubuh',
                        icon: Icons.accessibility_new_rounded,
                        isSelected: selectedEquipments.contains('bodyweight'),
                        onTap: () => _toggleEquipment('bodyweight'),
                        isLocked: true,
                      ),
                      const SizedBox(height: 8),
                      _buildCheckCard(
                        id: 'mat',
                        title: 'Matras / Karpet',
                        subtitle: 'Alas nyaman untuk push up & core',
                        icon: Icons.crop_landscape_rounded,
                        isSelected: selectedEquipments.contains('mat'),
                        onTap: () => _toggleEquipment('mat'),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckCard(
                        id: 'stable_surface',
                        title: 'Kursi / Meja Kokoh',
                        subtitle: 'Tumpuan Incline Push Up pemula',
                        icon: Icons.chair_rounded,
                        isSelected: selectedEquipments.contains('stable_surface'),
                        onTap: () => _toggleEquipment('stable_surface'),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckCard(
                        id: 'doorframe',
                        title: 'Kusen Pintu Rumah',
                        subtitle: 'Pegangan latihan punggung (Doorframe Row)',
                        icon: Icons.door_front_door_outlined,
                        isSelected: selectedEquipments.contains('doorframe'),
                        onTap: () => _toggleEquipment('doorframe'),
                      ),

                      const SizedBox(height: 28),

                      // Section 2: Limitations
                      Text(
                        'Apakah Ada Nyeri atau Batasan Fisik?',
                        style: AppTypography.labelLarge.copyWith(
                          color: const Color(0xFF1A1D1E),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCheckCard(
                        id: 'none',
                        title: 'Bebas Cedera & Sehat',
                        subtitle: 'Tidak ada keluhan fisik',
                        icon: Icons.check_circle_outline_rounded,
                        isSelected: selectedLimitations.contains('none') || selectedLimitations.isEmpty,
                        onTap: () => _toggleLimitation('none'),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckCard(
                        id: 'knee_pain',
                        title: 'Nyeri Sendi Lutut',
                        subtitle: 'Kurangi lompatan & squat terlalu dalam',
                        icon: Icons.healing_rounded,
                        isSelected: selectedLimitations.contains('knee_pain'),
                        onTap: () => _toggleLimitation('knee_pain'),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckCard(
                        id: 'wrist_pain',
                        title: 'Nyeri Pergelangan Tangan',
                        subtitle: 'Prioritaskan variasi sudut ramah sendi',
                        icon: Icons.front_hand_outlined,
                        isSelected: selectedLimitations.contains('wrist_pain'),
                        onTap: () => _toggleLimitation('wrist_pain'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              const OnboardingDotsIndicator(activeIndex: 3, totalDots: 5),
              const SizedBox(height: 16),
              OnboardingCtaButton(
                text: 'Next',
                onPressed: onNext,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F9EA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8E66B) : const Color(0xFFE9ECEF),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF558B0A) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF1A1D1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF71767B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: isLocked ? null : (_) => onTap(),
              activeColor: const Color(0xFF7CB818),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}

