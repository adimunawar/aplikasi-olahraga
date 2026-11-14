import 'dart:async';

import 'package:flutter/material.dart';

class _RecoveryMovement {
  final String title;
  final String description;
  final IconData icon;
  final int durationSeconds;
  final String instruction;

  const _RecoveryMovement({
    required this.title,
    required this.description,
    required this.icon,
    required this.durationSeconds,
    required this.instruction,
  });
}

const _recoveryMovements = <_RecoveryMovement>[
  _RecoveryMovement(
    title: 'Cat–Cow Stretch',
    description: 'Gentle spine mobility',
    icon: Icons.accessibility_new_rounded,
    durationSeconds: 60,
    instruction: 'Move slowly between a gentle arch and a rounded back. Keep the movement comfortable and pain-free.',
  ),
  _RecoveryMovement(
    title: 'Shoulder Mobility',
    description: 'Gentle shoulder movement',
    icon: Icons.accessibility_rounded,
    durationSeconds: 60,
    instruction: 'Make slow, controlled shoulder circles. Keep your range of motion comfortable.',
  ),
  _RecoveryMovement(
    title: 'Hip Flexor Stretch',
    description: 'Gentle hip mobility',
    icon: Icons.directions_walk_rounded,
    durationSeconds: 60,
    instruction: 'Use a supported split stance, gently shift your hips forward, and avoid forcing the stretch.',
  ),
];

class RecoveryRoutineScreen extends StatelessWidget {
  const RecoveryRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIndonesian = Localizations.localeOf(context).languageCode == 'id';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9F6),
        elevation: 0,
        foregroundColor: const Color(0xFF171B15),
        title: Text(
          isIndonesian ? 'Rutinitas Pemulihan' : 'Recovery Routine',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9D9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.self_improvement_rounded,
                    size: 54,
                    color: Color(0xFF75A900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isIndonesian ? 'Peregangan ringan & mobilitas' : 'Light Stretching & Mobility',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF171B15),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isIndonesian
                        ? 'Gerakan ringan untuk membantu tubuh rileks pada hari pemulihan.'
                        : 'A gentle sequence to help you move comfortably on a recovery day.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF687064),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _RoutineMeta(
                  icon: Icons.timer_outlined,
                  value: '3 min',
                  label: isIndonesian ? 'Durasi' : 'Duration',
                ),
                const SizedBox(width: 10),
                _RoutineMeta(
                  icon: Icons.bolt_outlined,
                  value: isIndonesian ? 'Ringan' : 'Light',
                  label: isIndonesian ? 'Intensitas' : 'Intensity',
                ),
                const SizedBox(width: 10),
                _RoutineMeta(
                  icon: Icons.list_alt_rounded,
                  value: '3',
                  label: isIndonesian ? 'Gerakan' : 'Movements',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              isIndonesian ? 'Urutan gerakan' : 'Routine preview',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171B15),
              ),
            ),
            const SizedBox(height: 10),
            ..._recoveryMovements.asMap().entries.map(
              (entry) => _MovementPreview(
                index: entry.key + 1,
                movement: entry.value,
                isIndonesian: isIndonesian,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RecoveryGuidedSessionScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  isIndonesian ? 'Mulai Rutinitas' : 'Start Routine',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFB1E623),
                  foregroundColor: const Color(0xFF171B15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineMeta extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _RoutineMeta({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E9E1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF75A900), size: 19),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF687064))),
          ],
        ),
      ),
    );
  }
}

class _MovementPreview extends StatelessWidget {
  final int index;
  final _RecoveryMovement movement;
  final bool isIndonesian;

  const _MovementPreview({
    required this.index,
    required this.movement,
    required this.isIndonesian,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E9E1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(movement.icon, color: const Color(0xFF75A900), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$index. ${movement.title}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171B15),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  movement.description,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF687064)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isIndonesian ? '1 mnt' : '60 sec',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class RecoveryGuidedSessionScreen extends StatefulWidget {
  const RecoveryGuidedSessionScreen({super.key});

  @override
  State<RecoveryGuidedSessionScreen> createState() => _RecoveryGuidedSessionScreenState();
}

class _RecoveryGuidedSessionScreenState extends State<RecoveryGuidedSessionScreen> {
  Timer? _timer;
  int _currentIndex = 0;
  int _remainingSeconds = 60;
  bool _isPaused = false;
  bool _isCompleted = false;

  _RecoveryMovement get _currentMovement => _recoveryMovements[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused || _isCompleted) return;
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        _advanceMovement();
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _advanceMovement() {
    if (_currentIndex < _recoveryMovements.length - 1) {
      setState(() {
        _currentIndex++;
        _remainingSeconds = _currentMovement.durationSeconds;
      });
    } else {
      _timer?.cancel();
      setState(() {
        _remainingSeconds = 0;
        _isCompleted = true;
      });
    }
  }

  void _skipMovement() {
    if (_isCompleted) return;
    _advanceMovement();
  }

  void _exitSession() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isIndonesian = Localizations.localeOf(context).languageCode == 'id';
    final progress = _isCompleted
        ? 1.0
        : (_currentIndex + (1 - _remainingSeconds / _currentMovement.durationSeconds)) /
            _recoveryMovements.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF171B15),
        leading: IconButton(
          tooltip: isIndonesian ? 'Keluar' : 'Exit',
          onPressed: _exitSession,
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          isIndonesian ? 'Sesi Pemulihan' : 'Recovery Session',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Text(
                '${_isCompleted ? _recoveryMovements.length : _currentIndex + 1} / ${_recoveryMovements.length}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: _isCompleted
              ? _buildCompletion(context, isIndonesian)
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          isIndonesian
                              ? 'Gerakan ${_currentIndex + 1} dari ${_recoveryMovements.length}'
                              : 'Movement ${_currentIndex + 1} of ${_recoveryMovements.length}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF687064)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: const Color(0xFFE8ECE4),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFB1E623)),
                    ),
                    const Spacer(),
                    Container(
                      width: 220,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5FBDD),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        _currentMovement.icon,
                        size: 86,
                        color: const Color(0xFF75A900),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _currentMovement.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171B15),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentMovement.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF687064),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _togglePause,
                        icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                        label: Text(
                          _isPaused
                              ? (isIndonesian ? 'Lanjutkan' : 'Resume')
                              : (isIndonesian ? 'Jeda' : 'Pause'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFB1E623),
                          foregroundColor: const Color(0xFF171B15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _skipMovement,
                      child: Text(isIndonesian ? 'Lewati gerakan' : 'Skip movement'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCompletion(BuildContext context, bool isIndonesian) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, size: 76, color: Color(0xFF84B900)),
        const SizedBox(height: 18),
        Text(
          isIndonesian ? 'Rutinitas selesai!' : 'Recovery complete!',
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isIndonesian
              ? 'Kamu sudah menyelesaikan semua gerakan pemulihan.'
              : 'You have completed all movements in this recovery routine.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF687064)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Guided session
              Navigator.of(context).pop(); // Routine detail
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFB1E623),
              foregroundColor: const Color(0xFF171B15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              isIndonesian ? 'Kembali ke Home' : 'Back to Home',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
