import 'package:material_ui/material_ui.dart';

/// Indikator loading untuk halaman Progress saat data pertama kali dimuat.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 60),
    child: Center(child: CircularProgressIndicator()),
  );
}
