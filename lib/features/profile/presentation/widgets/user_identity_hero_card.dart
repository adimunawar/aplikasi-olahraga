import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Card Identitas Pengguna pada Halaman Profile:
/// - Avatar bulat berlatar hijau lime cerah dengan foto Coach Adi
/// - Nama: "Adi Munawar"
/// - Status: "Bulking journey • Beginner"
/// - Tombol pill "Edit Profile" dengan icon pensil
class UserIdentityHeroCard extends StatelessWidget {
  final String name;
  final String status;
  final VoidCallback? onEdit;

  const UserIdentityHeroCard({
    super.key,
    this.name = 'Adi Munawar',
    this.status = 'Bulking journey • Beginner',
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Lingkaran Hijau Lime Cerah
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFC7F135),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/coach_hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/images/coach_character.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info Nama & Tombol Edit Profile
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: const Color(0xFF141718),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol Pill "Edit Profile"
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3FADC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: Color(0xFF141718),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Edit Profile',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: const Color(0xFF141718),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

