import 'package:flutter/material.dart';

enum RecoveryGuideType { hydration, sleep }

Future<void> showRecoveryGuideBottomSheet(
  BuildContext context,
  RecoveryGuideType type,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RecoveryGuideBottomSheet(type: type),
  );
}

class RecoveryGuideBottomSheet extends StatelessWidget {
  final RecoveryGuideType type;

  const RecoveryGuideBottomSheet({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isIndonesian = Localizations.localeOf(context).languageCode == 'id';
    final isHydration = type == RecoveryGuideType.hydration;
    final title = isHydration
        ? (isIndonesian ? 'Penuhi kebutuhan cairan' : 'Stay Hydrated')
        : (isIndonesian ? 'Tidur untuk pemulihan' : 'Better Sleep, Better Recovery');
    final subtitle = isHydration
        ? (isIndonesian
            ? 'Jaga tubuh tetap terhidrasi sepanjang hari.'
            : 'Keep your body hydrated throughout the day.')
        : (isIndonesian
            ? 'Tidur yang cukup mendukung pemulihan tubuh.'
            : 'Enough sleep supports your body’s recovery.');
    final tips = isHydration
        ? (isIndonesian
            ? <String>[
                'Minum air secara teratur sepanjang hari.',
                'Penuhi kembali cairan setelah berkeringat atau berlatih.',
                'Sediakan botol minum agar air mudah dijangkau.',
              ]
            : <String>[
                'Drink water regularly throughout the day.',
                'Replace fluids after sweating or exercising.',
                'Keep a water bottle within easy reach.',
              ])
        : (isIndonesian
            ? <String>[
                'Usahakan jadwal tidur dan bangun yang konsisten.',
                'Buat kamar tidur nyaman, tenang, dan redup.',
                'Kurangi penggunaan layar menjelang waktu tidur.',
              ]
            : <String>[
                'Keep a consistent sleep and wake schedule.',
                'Make your bedroom comfortable, quiet, and dark.',
                'Reduce screen use close to bedtime.',
              ]);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DED5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isIndonesian ? 'Panduan Pemulihan' : 'Recovery Guide',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171B15),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isIndonesian ? 'Tutup' : 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FBDD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    isHydration ? Icons.water_drop_rounded : Icons.bedtime_rounded,
                    color: const Color(0xFF78A900),
                    size: 46,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171B15),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF687064),
                    ),
                  ),
                  if (!isHydration) ...[
                    const SizedBox(height: 14),
                    const Text(
                      '7–9 hours',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF65930B),
                      ),
                    ),
                    Text(
                      isIndonesian
                          ? 'Panduan umum untuk orang dewasa'
                          : 'General guidance for adults',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF687064),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isIndonesian ? 'Tips sederhana' : 'Simple tips',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171B15),
              ),
            ),
            const SizedBox(height: 10),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 19,
                      color: Color(0xFF84B900),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF343B32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFB1E623),
                  foregroundColor: const Color(0xFF171B15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isIndonesian ? 'Mengerti' : 'Got it',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
