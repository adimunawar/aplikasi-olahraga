import '../../../../core/database/models/dynamic_program_entity.dart';

/// Pasangan [ProgramSessionEntity] dan detail jadwal [ProgramSessionDetail].
class SessionWithDetail {
  final ProgramSessionEntity session;
  final ProgramSessionDetail detail;

  const SessionWithDetail({required this.session, required this.detail});
}
