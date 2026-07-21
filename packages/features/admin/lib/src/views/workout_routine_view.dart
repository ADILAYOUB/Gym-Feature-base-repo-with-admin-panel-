import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';

class WorkoutRoutineView extends ConsumerStatefulWidget {
  const WorkoutRoutineView({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkoutRoutineView> createState() => _WorkoutRoutineViewState();
}

class _WorkoutRoutineViewState extends ConsumerState<WorkoutRoutineView> {
  final _workoutTitleController = TextEditingController();
  final _workoutDurationController = TextEditingController();
  final _workoutImageController = TextEditingController();
  final _workoutExercisesController = TextEditingController();
  String _workoutCategory = 'men';
  String _workoutDifficulty = 'beginner';

  @override
  void dispose() {
    _workoutTitleController.dispose();
    _workoutDurationController.dispose();
    _workoutImageController.dispose();
    _workoutExercisesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);
    final workoutsAsync = ref.watch(workoutsStreamProvider);
    final exercisesAsync = ref.watch(exercisesStreamProvider);
    final layoutAsync = ref.watch(layoutSectionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Workout Routines & Exercise Library', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Manage exercise routines and video tutorials for Men, Women, and Children', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddExerciseDialog,
                icon: const Icon(Icons.fitness_center, size: 18),
                label: const Text('Add Exercise Video', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row 1: Workout Plan Creator + SDUI Layout Manager
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout Creator Form
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create New Workout Routine', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _workoutTitleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Workout Title (e.g. Chest & Tricep Blast)'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _workoutCategory,
                              isExpanded: true,
                              dropdownColor: cardBg,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Target Category'),
                              items: const [
                                DropdownMenuItem(value: 'men', child: Text('Men', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'women', child: Text('Women', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'children', child: Text('Children', overflow: TextOverflow.ellipsis)),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _workoutCategory = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _workoutDifficulty,
                              isExpanded: true,
                              dropdownColor: cardBg,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Difficulty Level'),
                              items: const [
                                DropdownMenuItem(value: 'beginner', child: Text('Beginner', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'intermediate', child: Text('Intermediate', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'advanced', child: Text('Advanced', overflow: TextOverflow.ellipsis)),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _workoutDifficulty = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _workoutDurationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Duration (e.g. 45 min)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _workoutImageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Banner / Image URL'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _workoutExercisesController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Exercises (comma separated: Pushups, Squats, Planks)'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createNewWorkout,
                          icon: const Icon(Icons.add_task),
                          label: const Text('Publish Workout to Firestore'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Homepage SDUI Layout Manager
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SDUI Homepage Layout Order', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Re-order sections dynamically for users in real-time.', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 16),
                      layoutAsync.when(
                        data: (sections) {
                          if (sections.isEmpty) {
                            return ElevatedButton(
                              onPressed: _seedDefaultLayout,
                              child: const Text('Seed Default Layout'),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sections.length,
                            itemBuilder: (context, index) {
                              final sec = sections[index];
                              return ListTile(
                                leading: const Icon(Icons.drag_handle, color: Colors.grey),
                                title: Text(sec.id.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text('Type: ${sec.type}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                trailing: Checkbox(
                                  value: sec.visible,
                                  onChanged: (val) {
                                    if (val != null) _toggleSectionVisibility(sec, val, sections);
                                  },
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Published Workout Routines List (Phase 3 CRUD)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Published Workout Routines Catalog', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.fitness_center, color: activeOrange),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Live routines published to Cloud Firestore and synced with the Mobile User App', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                workoutsAsync.when(
                  data: (workoutsList) {
                    if (workoutsList.isEmpty) {
                      return const Text('No workout routines published yet.', style: TextStyle(color: Colors.grey));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workoutsList.length,
                      itemBuilder: (context, index) {
                        final w = workoutsList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1F2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: activeOrange.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      w.imageUrl.isNotEmpty ? w.imageUrl : 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=300',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(w.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: activeOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                          child: Text(w.category.toUpperCase(), style: const TextStyle(color: activeOrange, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${w.duration} • ${w.difficulty.toUpperCase()} • ${w.exercises.length} Exercises (${w.exercises.join(", ")})', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () async {
                                  await ref.read(workoutRepositoryProvider).deleteWorkout(w.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading workouts: $err', style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Exercise Video Library Catalog Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Published Exercise Video Library', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Catalog of exercises available for personalized user routines', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                exercisesAsync.when(
                  data: (exercisesList) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: exercisesList.length,
                      itemBuilder: (context, index) {
                        final ex = exercisesList[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1F2A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: activeOrange.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: activeOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                    child: Text(ex.category.toUpperCase(), style: const TextStyle(color: activeOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Target: ${ex.targetMuscle} • Equipment: ${ex.equipment}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 6),
                              Text('${ex.defaultSets} Sets × ${ex.defaultReps} Reps', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Row(
                                children: const [
                                  Icon(Icons.play_circle_fill, color: activeOrange, size: 16),
                                  SizedBox(width: 6),
                                  Text('HD Video Tutorial Linked', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading exercises: $err', style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog() {
    final nameCtrl = TextEditingController();
    final muscleCtrl = TextEditingController(text: 'Chest');
    final equipCtrl = TextEditingController(text: 'Dumbbell');
    final videoCtrl = TextEditingController(text: 'https://assets.mixkit.co/videos/preview/mixkit-man-doing-exercises-with-dumbbells-41485-large.mp4');
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '12');
    String cat = 'men';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: const Text('Add New Exercise Video', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Exercise Name (e.g. Incline Dumbbell Press)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: cat,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF242533),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Target Category'),
                  items: const [
                    DropdownMenuItem(value: 'men', child: Text('Men', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'women', child: Text('Women', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'children', child: Text('Children', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) cat = val;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: muscleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Target Muscle Group'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: equipCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Equipment Required'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'HD Video Stream URL'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Default Sets'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: repsCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Default Reps'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final newEx = Exercise(
                    id: '',
                    name: nameCtrl.text.trim(),
                    category: cat,
                    targetMuscle: muscleCtrl.text.trim(),
                    equipment: equipCtrl.text.trim(),
                    videoUrl: videoCtrl.text.trim(),
                    thumbnailUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=400',
                    instructions: ['Form up carefully.', 'Perform movement with steady control.'],
                    defaultSets: int.tryParse(setsCtrl.text) ?? 3,
                    defaultReps: int.tryParse(repsCtrl.text) ?? 12,
                  );

                  await ref.read(workoutRepositoryProvider).addExercise(newEx);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Exercise'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNewWorkout() async {
    if (_workoutTitleController.text.trim().isEmpty) return;

    final exercises = _workoutExercisesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final workout = Workout(
      id: '',
      title: _workoutTitleController.text.trim(),
      description: 'Training routine for ${_workoutCategory.toUpperCase()}',
      category: _workoutCategory,
      duration: _workoutDurationController.text.trim().isEmpty ? '30 min' : _workoutDurationController.text.trim(),
      difficulty: _workoutDifficulty,
      imageUrl: _workoutImageController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600'
          : _workoutImageController.text.trim(),
      exercises: exercises.isEmpty ? ['Dynamic warm-up', 'Core training'] : exercises,
    );

    try {
      await ref.read(workoutRepositoryProvider).addWorkout(workout);
      _workoutTitleController.clear();
      _workoutImageController.clear();
      _workoutExercisesController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Workout published to Firestore successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add workout: $e')),
      );
    }
  }

  Future<void> _seedDefaultLayout() async {
    final defaults = [
      const LayoutSection(id: 'hero_banners', type: 'carousel', visible: true, weight: 10, properties: {'height': 200.0, 'autoScroll': true}),
      const LayoutSection(id: 'gender_selector', type: 'gender_selector', visible: true, weight: 20, properties: {}),
      const LayoutSection(id: 'workout_list', type: 'workout_list', visible: true, weight: 30, properties: {'limit': 5, 'cardStyle': 'compact'}),
    ];
    await ref.read(configRepositoryProvider).updateLayoutSections(defaults);
  }

  Future<void> _toggleSectionVisibility(LayoutSection target, bool visible, List<LayoutSection> all) async {
    final updated = all.map((sec) {
      if (sec.id == target.id) {
        return LayoutSection(
          id: sec.id,
          type: sec.type,
          visible: visible,
          weight: sec.weight,
          properties: sec.properties,
        );
      }
      return sec;
    }).toList();
    await ref.read(configRepositoryProvider).updateLayoutSections(updated);
  }
}
