class Exercise {
  final String id;
  final String name;
  final String category; // 'men', 'women', 'children'
  final String targetMuscle; // 'Chest', 'Back', 'Legs', 'Abs', 'Cardio', 'Full Body'
  final String equipment; // 'Dumbbell', 'Barbell', 'Machine', 'Bodyweight'
  final String videoUrl;
  final String thumbnailUrl;
  final List<String> instructions;
  final int defaultSets;
  final int defaultReps;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetMuscle,
    required this.equipment,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.instructions,
    required this.defaultSets,
    required this.defaultReps,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'targetMuscle': targetMuscle,
      'equipment': equipment,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'instructions': instructions,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json, String docId) {
    return Exercise(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      name: json['name'] ?? '',
      category: json['category'] ?? 'men',
      targetMuscle: json['targetMuscle'] ?? 'Full Body',
      equipment: json['equipment'] ?? 'Bodyweight',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
      defaultSets: json['defaultSets'] ?? 3,
      defaultReps: json['defaultReps'] ?? 12,
    );
  }
}

class Workout {
  final String id;
  final String title;
  final String description;
  final String category; // 'men', 'women', 'children'
  final String duration;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String imageUrl;
  final List<String> exercises;
  final List<Exercise> exerciseDetails;

  const Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.imageUrl,
    required this.exercises,
    this.exerciseDetails = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'exercises': exercises,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json, String docId) {
    return Workout(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'men',
      duration: json['duration'] ?? '30 min',
      difficulty: json['difficulty'] ?? 'beginner',
      imageUrl: json['imageUrl'] ?? '',
      exercises: List<String>.from(json['exercises'] ?? []),
      exerciseDetails: (json['exerciseDetails'] as List?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>, ''))
              .toList() ??
          const [],
    );
  }
}
