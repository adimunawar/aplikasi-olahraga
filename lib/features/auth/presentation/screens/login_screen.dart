import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Layar "Back up & sync your progress" — login & sinkronisasi progres.
///
/// Cocok untuk dipanggil dari [profile] ketika user klik Sync.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Badge opsional di atas judul.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_queue_outlined,
                      size: 16,
                      color: AppColors.greenDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Optional Cloud Sync',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.greenDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Judul & subtitle.
              Text(
                'Back up & sync',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'your progress',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Keep your workouts, body stats, and Bulking Program '
                'safe across devices.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Tombol sosial: Google.
              _socialButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                onPressed: () {},
              ),

              const SizedBox(height: 12),

              // Tombol sosial: Apple.
              _socialButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                variant: _SocialButtonVariant.dark,
                onPressed: () {},
              ),

              const SizedBox(height: 16),

              // Divider.
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'or continue with email',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Form email & sandi.
              _TextFieldLabel(text: 'Email'),
              const SizedBox(height: 8),
              _EmailTextField(),
              const SizedBox(height: 20),

              _TextFieldLabel(text: 'Password'),
              const SizedBox(height: 8),
              _PasswordTextField(),
              const SizedBox(height: 8),

              // Lupa sandi diletakkan di bawah email, sesuai desain.
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol CTA utama.
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_sync, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sign In & Sync',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variant tombol sosial.
enum _SocialButtonVariant { light, dark }

/// Tombol sosial (Google / Apple) sesuai desain.
Widget _socialButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  _SocialButtonVariant variant = _SocialButtonVariant.light,
}) {
  final isDark = variant == _SocialButtonVariant.dark;
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: isDark ? Colors.white : null),
      label: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isDark ? AppColors.darkCharcoal : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        side: BorderSide(
          color: isDark ? AppColors.darkCharcoal : AppColors.border,
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),
  );
}

/// Label input teks.
class _TextFieldLabel extends StatelessWidget {
  final String text;
  const _TextFieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Field email.
class _EmailTextField extends StatelessWidget {
  const _EmailTextField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'adi@pulsefit.app',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Field sandi dengan tombol lihat/sembunyi.
class _PasswordTextField extends StatefulWidget {
  const _PasswordTextField();

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscure,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textDim,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
