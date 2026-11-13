import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../domain/services/dynamic_program_generator.dart';

/// Provider untuk menyimpan hasil program yang di-generate sebagai Draft/Preview
/// selama alur onboarding sebelum disetujui dan diaktifkan oleh pengguna.
final draftProgramProvider = StateProvider<GeneratedProgramResult?>((ref) => null);

/// Provider untuk menyimpan profil pengguna sementara selama onboarding
final onboardingProfileProvider = StateProvider<UserProfileEntity?>((ref) => null);

