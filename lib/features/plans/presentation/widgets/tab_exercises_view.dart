import 'package:flutter/material.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../exercises/domain/models/exercise.dart';
import 'exercise_category_chips.dart';
import 'exercise_plan_item_card.dart';
import 'exercise_search_and_filter.dart';

/// Tab 3: Exercises View
/// Pustaka gerakan lengkap dengan filter kategori otot (All, Chest, Back, Shoulder, dll),
/// pencarian langsung, indikator visual anatomi, dan navigasi ke ExerciseDetailScreen.
class TabExercisesView extends StatefulWidget {
  const TabExercisesView({super.key});

  @override
  State<TabExercisesView> createState() => _TabExercisesViewState();
}

class _TabExercisesViewState extends State<TabExercisesView> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  List<_ExerciseDisplayItem> _allExercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final repo = ExerciseRepositoryImpl(ExerciseLocalDatasource());
      final loaded = await repo.getExercises();

      if (mounted) {
        setState(() {
          _allExercises = loaded.map((e) {
            String cat = 'Chest';
            if (e.primaryMuscles.isNotEmpty) {
              final m = e.primaryMuscles.first.en.toLowerCase();
              if (m.contains('chest') || m.contains('dada')) {
                cat = 'Chest';
              } else if (m.contains('back') || m.contains('lat') || m.contains('punggung')) {
                cat = 'Back';
              } else if (m.contains('shoulder') || m.contains('bahu') || m.contains('deltoid')) {
                cat = 'Shoulder';
              } else if (m.contains('arm') || m.contains('bicep') || m.contains('tricep') || m.contains('lengan')) {
                cat = 'Arms';
              } else if (m.contains('leg') || m.contains('kaki') || m.contains('glute') || m.contains('calf')) {
                cat = 'Legs';
              } else if (m.contains('core') || m.contains('ab') || m.contains('perut')) {
                cat = 'Core';
              } else {
                cat = e.primaryMuscles.first.en;
              }
            }
            return _ExerciseDisplayItem(
              title: e.name.en.isNotEmpty ? e.name.en : e.name.id,
              category: cat,
              thumbnailAsset: 'assets/images/Detail Gerakan.png',
              exercise: e,
            );
          }).toList();

          if (_allExercises.isEmpty) {
            _allExercises = _buildFallbackExercises();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allExercises = _buildFallbackExercises();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC7F135)),
      );
    }

    final filteredList = _allExercises.where((item) {
      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Column(
      children: [
        // Search & Filter Box
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 12),
          child: ExerciseSearchAndFilter(
            onSearchChanged: (q) => setState(() => _searchQuery = q),
            onFilterTap: _showFilterBottomSheet,
          ),
        ),

        // Horizontal Category Chips
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 14),
          child: ExerciseCategoryChips(
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
          ),
        ),

        // List Gerakan Latihan
        Expanded(
          child: filteredList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada gerakan ditemukan.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return ExercisePlanItemCard(
                      title: item.title,
                      category: item.category,
                      thumbnailAsset: item.thumbnailAsset,
                      exercise: item.exercise,
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Gerakan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Chest', 'Back', 'Shoulder', 'Arms', 'Legs', 'Core'].map((c) {
                  final isSelected = c.toLowerCase() == _selectedCategory.toLowerCase();
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: const Color(0xFFC7F135),
                    onSelected: (_) {
                      setState(() => _selectedCategory = c);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_ExerciseDisplayItem> _buildFallbackExercises() {
    return [
      _createFallbackItem('Barbell Bench Press', 'Chest', 'assets/images/Detail Gerakan.png'),
      _createFallbackItem('Incline Dumbbell Press', 'Chest', 'assets/images/Hari Ini.png'),
      _createFallbackItem('Lat Pulldown', 'Back', 'assets/images/Kalender 30 Hari.png'),
      _createFallbackItem('Seated Cable Row', 'Back', 'assets/images/Home Workout Push-Up Guide.png'),
      _createFallbackItem('Shoulder Press', 'Shoulder', 'assets/images/Detail Gerakan.png'),
      _createFallbackItem('Lateral Raise', 'Shoulder', 'assets/images/Hari Ini.png'),
      _createFallbackItem('Push Up', 'Chest', 'assets/images/Home Workout Push-Up Guide.png'),
      _createFallbackItem('Diamond Push Up', 'Arms', 'assets/images/Kalender 30 Hari.png'),
      _createFallbackItem('Pull Up', 'Back', 'assets/images/Detail Gerakan.png'),
      _createFallbackItem('Bodyweight Squat', 'Legs', 'assets/images/Hari Ini.png'),
      _createFallbackItem('Plank', 'Core', 'assets/images/Home Workout Push-Up Guide.png'),
    ];
  }

  _ExerciseDisplayItem _createFallbackItem(String title, String category, String asset) {
    return _ExerciseDisplayItem(
      title: title,
      category: category,
      thumbnailAsset: asset,
      exercise: Exercise(
        id: title.toLowerCase().replaceAll(' ', '_'),
        name: LocalizedString(id: title, en: title),
        category: category.toLowerCase().contains('chest') || category.toLowerCase().contains('push')
            ? ExerciseCategory.push
            : category.toLowerCase().contains('leg')
                ? ExerciseCategory.legs
                : category.toLowerCase().contains('core')
                    ? ExerciseCategory.core
                    : ExerciseCategory.fullBody,
        difficulty: ExerciseDifficulty.intermediate,
        trackingType: TrackingType.reps,
        primaryMuscles: [LocalizedString(id: category, en: category)],
        stabilizerMuscles: const [LocalizedString(id: 'Core', en: 'Core')],
        steps: const LocalizedList(
          id: [
            'Posisikan tubuh dengan stabil dan rentang gerak penuh.',
            'Lakukan gerakan secara terkontrol dengan teknik pernapasan teratur.',
            'Kontraksikan otot target di puncak repetisi.',
          ],
          en: [
            'Maintain a stable body position with full range of motion.',
            'Perform movement under control with steady breathing.',
            'Squeeze target muscles at peak contraction.',
          ],
        ),
        commonMistakes: const LocalizedList(
          id: ['Mengayunkan badan alih-alih fokus pada kontraksi otot.'],
          en: ['Using momentum instead of muscular control.'],
        ),
        breathing: const LocalizedString(
          id: 'Tarik napas saat menurunkan beban, hembuskan saat mendorong.',
          en: 'Inhale during lowering phase, exhale during exertion.',
        ),
        variations: const ExerciseVariationGroup(),
        media: const ExerciseMedia(startPose: '', endPose: ''),
      ),
    );
  }
}

class _ExerciseDisplayItem {
  final String title;
  final String category;
  final String thumbnailAsset;
  final Exercise exercise;

  _ExerciseDisplayItem({
    required this.title,
    required this.category,
    required this.thumbnailAsset,
    required this.exercise,
  });
}
