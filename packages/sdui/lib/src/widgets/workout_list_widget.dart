import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';

// We define this provider here. It will be overridden in the main app to fetch from Firestore.
final sduiWorkoutsProvider = StreamProvider.family<List<Workout>, String>((ref, category) {
  throw UnimplementedError('sduiWorkoutsProvider not overridden');
});

// Optional callback provider or parameter for launching active workout mode
typedef OnWorkoutSelectedCallback = void Function(BuildContext context, Workout workout);
OnWorkoutSelectedCallback? globalOnWorkoutSelected;

class WorkoutListWidget extends ConsumerWidget {
  final String category;
  final int limit;
  final String cardStyle;

  const WorkoutListWidget({
    Key? key,
    required this.category,
    required this.limit,
    required this.cardStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Safely watch the workouts provider. Fallback to mock data if provider throws or fails.
    AsyncValue<List<Workout>> workoutsAsync;
    try {
      workoutsAsync = ref.watch(sduiWorkoutsProvider(category));
    } catch (_) {
      workoutsAsync = AsyncValue.data(_getMockWorkouts(category));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended Workouts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          workoutsAsync.when(
            data: (workouts) {
              final displayedWorkouts = workouts.take(limit).toList();
              if (displayedWorkouts.isEmpty) {
                return _buildList(context, _getMockWorkouts(category).take(limit).toList(), theme);
              }
              return _buildList(context, displayedWorkouts, theme);
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) {
              return _buildList(context, _getMockWorkouts(category).take(limit).toList(), theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Workout> workouts, ThemeData theme) {
    if (cardStyle == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: workouts.length,
        itemBuilder: (ctx, index) {
          return _buildWorkoutGridCard(context, workouts[index], theme);
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        return _buildWorkoutRowCard(context, workouts[index], theme);
      },
    );
  }

  Widget _buildWorkoutRowCard(BuildContext context, Workout workout, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: InkWell(
        onTap: () => _showWorkoutDetailSheet(context, workout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  width: 80,
                  height: 80,
                  child: workout.imageUrl.isNotEmpty
                      ? Image.network(
                          workout.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.fitness_center,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        workout.difficulty.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      workout.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.duration} • ${workout.exercises.length} Exercises',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutGridCard(BuildContext context, Workout workout, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: InkWell(
        onTap: () => _showWorkoutDetailSheet(context, workout),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: workout.imageUrl.isNotEmpty
                      ? Image.network(
                          workout.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.fitness_center,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: theme.colorScheme.primary,
                          size: 36,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.duration} • ${workout.difficulty}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetailSheet(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1F2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(
                      workout.imageUrl.isNotEmpty
                          ? workout.imageUrl
                          : 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      workout.difficulty.toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${workout.duration} • Category: ${workout.category.toUpperCase()}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                workout.description.isNotEmpty
                    ? workout.description
                    : 'Targeted strength routine designed for peak physical output.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),

              const Text('Included Exercises', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: workout.exercises.isEmpty ? 3 : workout.exercises.length,
                  itemBuilder: (c, i) {
                    final exName = workout.exercises.isEmpty
                        ? ['Dumbbell Press', 'Push-ups', 'Core Planks'][i]
                        : workout.exercises[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242533),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
                          const SizedBox(width: 10),
                          Text(exName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (globalOnWorkoutSelected != null) {
                      globalOnWorkoutSelected!(context, workout);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Starting ${workout.title}...')),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text('START ACTIVE WORKOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Workout> _getMockWorkouts(String category) {
    final cat = category.toLowerCase();
    if (cat == 'women') {
      return const [
        Workout(
          id: 'mock_w1',
          title: 'Full Body Pilates',
          description: 'High performance pilates targeting flexibility and core strength.',
          category: 'women',
          duration: '35 min',
          difficulty: 'beginner',
          imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=300',
          exercises: ['Plank holds', 'Glute bridges', 'Side sweeps'],
        ),
        Workout(
          id: 'mock_w2',
          title: 'HIIT Fat Burner',
          description: 'Fast-paced high intensity intervals for cardio stamina.',
          category: 'women',
          duration: '20 min',
          difficulty: 'advanced',
          imageUrl: 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?q=80&w=300',
          exercises: ['Jump squats', 'Burpees', 'Mountain climbers'],
        ),
      ];
    } else if (cat == 'children') {
      return const [
        Workout(
          id: 'mock_c1',
          title: 'Kids Fun Gymnastics',
          description: 'Exciting dynamic movements for youth agility and stability.',
          category: 'children',
          duration: '15 min',
          difficulty: 'beginner',
          imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=300',
          exercises: ['Frog jumps', 'Bear crawls', 'Crab walks'],
        ),
      ];
    } else {
      return const [
        Workout(
          id: 'mock_m1',
          title: 'Hypertrophy Chest & Arms',
          description: 'Classic bodybuilding push exercises for muscle mass building.',
          category: 'men',
          duration: '45 min',
          difficulty: 'intermediate',
          imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=300',
          exercises: ['Incline bench press', 'Dumbbell flyes', 'Tricep pushdowns'],
        ),
        Workout(
          id: 'mock_m2',
          title: 'Heavy Barbell Squats',
          description: 'Powerlifting leg day focused on pure squat power.',
          category: 'men',
          duration: '50 min',
          difficulty: 'advanced',
          imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=300',
          exercises: ['Back squats', 'Leg extensions', 'Romanian deadlifts'],
        ),
      ];
    }
  }
}
