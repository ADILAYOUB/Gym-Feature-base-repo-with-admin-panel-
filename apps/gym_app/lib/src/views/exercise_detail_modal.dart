import 'package:flutter/material.dart';
import 'package:domain/domain.dart';

class ExerciseDetailModal extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailModal({Key? key, required this.exercise}) : super(key: key);

  static void show(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1F2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ExerciseDetailModal(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video / Banner Container
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(
                  exercise.thumbnailUrl.isNotEmpty
                      ? exercise.thumbnailUrl
                      : 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Exercise Title & Category Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exercise.name,
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
                  exercise.category.toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Muscle & Equipment Chips
          Row(
            children: [
              _buildChip(Icons.fitness_center, 'Target: ${exercise.targetMuscle}', theme),
              const SizedBox(width: 8),
              _buildChip(Icons.build_circle_outlined, exercise.equipment, theme),
              const Spacer(),
              Text(
                '${exercise.defaultSets} Sets × ${exercise.defaultReps} Reps',
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Instructions Header
          Text('Step-by-Step Instructions', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: exercise.instructions.isEmpty ? 1 : exercise.instructions.length,
              itemBuilder: (context, index) {
                final text = exercise.instructions.isEmpty
                    ? 'Maintain clean posture and execute movement smoothly.'
                    : exercise.instructions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF242533),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
