import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Tab Profile (PRD Bagian 8 & 10.7):
/// Pengaturan profil pengguna, preferensi alat latihan, jadwal, dan privasi data lokal.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = AppDatabase.instance;
  UserProfileEntity? _profile;

  String _displayName = 'Adi';
  String _experienceLevel = 'Beginner';
  int _trainingDaysPerWeek = 4;
  String _unit = 'Metric (kg, cm)';
  bool _dailyReminder = true;
  List<String> _selectedEquipment = ['Bodyweight', 'Dumbbells', 'Matras'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _db.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = p;
        _displayName = p.displayName;
        _experienceLevel = p.experienceLevel.toUpperCase() == 'BEGINNER' ? 'Beginner' : p.experienceLevel;
        _trainingDaysPerWeek = p.preferredDaysPerWeek;
        _selectedEquipment = p.equipments.map((e) {
          switch (e.toLowerCase()) {
            case 'bodyweight':
              return 'Bodyweight';
            case 'dumbbells':
              return 'Dumbbells';
            case 'bands':
              return 'Resistance Bands';
            case 'pullup_bar':
              return 'Pull-up Bar';
            case 'mat':
            default:
              return 'Matras';
          }
        }).toSet().toList();
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_profile != null) {
      final updated = _profile!.copyWith(
        displayName: _displayName,
        experienceLevel: _experienceLevel.toLowerCase(),
        preferredDaysPerWeek: _trainingDaysPerWeek,
        equipments: _selectedEquipment.map((e) => e.toLowerCase().replaceAll(' ', '_')).toList(),
      );
      await _db.saveUserProfile(updated);
      _profile = updated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profil & Pengaturan',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Header Profil Singkat
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_displayName, style: AppTypography.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Target: Bangun Otot (Bulking) • $_experienceLevel',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pengaturan Latihan (SET-01 & SET-02)
          Text('PREFERENSI LATIHAN', style: AppTypography.labelCaps),
          const SizedBox(height: 10),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.fitness_center_rounded,
              title: 'Peralatan yang Dimiliki',
              subtitle: _selectedEquipment.join(', '),
              onTap: () => _showEquipmentPicker(context),
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.calendar_month_rounded,
              title: 'Jadwal Mingguan',
              subtitle: '$_trainingDaysPerWeek Hari / Minggu (30-45 mnt)',
              onTap: () => _showSchedulePicker(context),
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.speed_rounded,
              title: 'Tingkat Pengalaman',
              subtitle: _experienceLevel,
              onTap: () => _showLevelPicker(context),
            ),
          ]),
          const SizedBox(height: 24),

          // Aplikasi & Notifikasi (SET-03 & SET-04)
          Text('PREFERENSI APLIKASI', style: AppTypography.labelCaps),
          const SizedBox(height: 10),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.straighten_rounded,
              title: 'Satuan Ukuran',
              subtitle: _unit,
              onTap: () {
                setState(() {
                  _unit = _unit.startsWith('Metric') ? 'Imperial (lbs, inch)' : 'Metric (kg, cm)';
                });
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('Pengingat Jadwal Latihan', style: AppTypography.labelLarge),
              subtitle: Text('Notifikasi lokal sebelum jam latihan', style: AppTypography.bodySmall),
              value: _dailyReminder,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _dailyReminder = val);
              },
            ),
          ]),
          const SizedBox(height: 24),

          // Privasi & Data Lokal (SET-05, SET-06, SET-07)
          Text('PRIVASI & DATA LOKAL', style: AppTypography.labelCaps),
          const SizedBox(height: 10),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.verified_user_outlined,
              title: 'Penyimpanan Data Lokal',
              subtitle: '100% tersimpan di HP Anda, tanpa cloud & offline-first',
              onTap: null,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Hapus Semua Data Lokal',
              subtitle: 'Reset riwayat latihan, profil, dan mulai dari awal',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () => _showDeleteDataConfirmation(context),
            ),
          ]),
          const SizedBox(height: 24),

          // Versi Aplikasi
          Center(
            child: Text(
              'Home Bulking Coach • Versi 2.0.0 (MVP)',
              style: AppTypography.labelSmall,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.textPrimary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
      ),
      title: Text(
        title,
        style: AppTypography.labelLarge.copyWith(color: textColor ?? AppColors.textPrimary),
      ),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textDim) : null,
      onTap: onTap,
    );
  }

  void _showEquipmentPicker(BuildContext context) {
    final options = ['Bodyweight', 'Dumbbells', 'Resistance Bands', 'Pull-up Bar', 'Matras'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Peralatan Tersedia', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final isSelected = _selectedEquipment.contains(opt);
                return CheckboxListTile(
                  title: Text(opt, style: AppTypography.bodyLarge),
                  value: isSelected,
                  activeColor: AppColors.primary,
                  checkColor: AppColors.textPrimary,
                  onChanged: (val) {
                    setSheetState(() {
                      if (val == true) {
                        _selectedEquipment.add(opt);
                      } else {
                        if (_selectedEquipment.length > 1) {
                          _selectedEquipment.remove(opt);
                        }
                      }
                    });
                    setState(() {});
                    _updateProfile();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showSchedulePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frekuensi Latihan Mingguan', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            for (final days in [3, 4, 5])
              ListTile(
                title: Text('$days Hari per Minggu', style: AppTypography.bodyLarge),
                trailing: _trainingDaysPerWeek == days ? const Icon(Icons.check, color: AppColors.textPrimary) : null,
                onTap: () {
                  setState(() => _trainingDaysPerWeek = days);
                  _updateProfile();
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLevelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tingkat Pengalaman', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            for (final lvl in ['Beginner', 'Intermediate', 'Advanced'])
              ListTile(
                title: Text(lvl, style: AppTypography.bodyLarge),
                trailing: _experienceLevel == lvl ? const Icon(Icons.check, color: AppColors.textPrimary) : null,
                onTap: () {
                  setState(() => _experienceLevel = lvl);
                  _updateProfile();
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Hapus Data Lokal?', style: AppTypography.headlineSmall.copyWith(color: AppColors.error)),
        content: Text(
          'Semua riwayat latihan, progres, dan setelan profil akan dihapus permanen dari perangkat ini. Tindakan ini tidak dapat dibatalkan.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _db.clearAllLocalData();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('has_completed_onboarding');
              await _loadProfile();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data lokal berhasil direset ke setelan awal.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(110, 42),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

