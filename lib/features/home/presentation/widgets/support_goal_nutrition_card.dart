import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/home_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Kartu Panduan Nutrisi & Tips Pendukung Target (Mockup 1:1)
class SupportGoalNutritionCard extends StatelessWidget {
  final String userGoal;
  final VoidCallback onTap;

  const SupportGoalNutritionCard({
    super.key,
    required this.userGoal,
    required this.onTap,
  });

  String _getSubtitle(Translations t) {
    final g = userGoal.toLowerCase();
    if (g.contains('fat') || g.contains('loss') || g.contains('turun')) {
      return t.home.supportGoal.subtitleLoss;
    } else if (g.contains('maintain') || g.contains('jaga')) {
      return t.home.supportGoal.subtitleMaintain;
    } else {
      return t.home.supportGoal.subtitleGain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HomeTheme.accentSurface(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD4EBA8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF84CC16).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Text & Icon Kolom Kiri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_rounded,
                          size: 18,
                          color: Color(0xFF65A30D),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.home.supportGoal.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: HomeTheme.text(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getSubtitle(t),
                      style: AppTypography.bodySmall.copyWith(
                        color: HomeTheme.muted(context),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: HomeTheme.surface(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: HomeTheme.text(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 2. Graphic Mangkuk Makanan Sehat di Kanan
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomeTheme.surface(context),
                  border: Border.all(color: const Color(0xFFD4EBA8), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: HomeTheme.accentSurface(context),
                    child: Center(
                      child: Icon(
                        Icons.lunch_dining_rounded,
                        size: 44,
                        color: Color(0xFF65A30D),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
