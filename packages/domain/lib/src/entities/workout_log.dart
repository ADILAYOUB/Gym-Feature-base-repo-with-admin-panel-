class ExerciseLog {
  final String exerciseName;
  final int setsCompleted;
  final int repsCompleted;
  final double weightKg;

  const ExerciseLog({
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.weightKg,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'setsCompleted': setsCompleted,
      'repsCompleted': repsCompleted,
      'weightKg': weightKg,
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exerciseName: json['exerciseName'] ?? '',
      setsCompleted: json['setsCompleted'] ?? 0,
      repsCompleted: json['repsCompleted'] ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WorkoutLog {
  final String id;
  final String userId;
  final String workoutTitle;
  final DateTime completedAt;
  final int durationSeconds;
  final double totalVolumeKg;
  final double caloriesBurned;
  final List<ExerciseLog> exercisesLogged;

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.workoutTitle,
    required this.completedAt,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.caloriesBurned,
    required this.exercisesLogged,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workoutTitle': workoutTitle,
      'completedAt': completedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'totalVolumeKg': totalVolumeKg,
      'caloriesBurned': caloriesBurned,
      'exercisesLogged': exercisesLogged.map((e) => e.toJson()).toList(),
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json, String docId) {
    return WorkoutLog(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      userId: json['userId'] ?? 'user_1',
      workoutTitle: json['workoutTitle'] ?? 'General Strength Routine',
      completedAt: DateTime.tryParse(json['completedAt'] ?? '') ?? DateTime.now(),
      durationSeconds: json['durationSeconds'] ?? 1800,
      totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 320.0,
      exercisesLogged: (json['exercisesLogged'] as List?)
              ?.map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

abstract class WorkoutLogRepository {
  Stream<List<WorkoutLog>> getWorkoutLogsStream();
  Future<void> saveWorkoutLog(WorkoutLog log);
}
