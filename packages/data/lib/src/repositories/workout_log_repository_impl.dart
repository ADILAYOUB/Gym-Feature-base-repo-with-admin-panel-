import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class WorkoutLogRepositoryImpl implements WorkoutLogRepository {
  final FirebaseFirestore _firestore;

  WorkoutLogRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<WorkoutLog>> getWorkoutLogsStream() {
    return _firestore
        .collection('workout_logs')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultLogs();
      }
      return snapshot.docs.map((doc) => WorkoutLog.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    await _firestore.collection('workout_logs').add(log.toJson());
  }

  List<WorkoutLog> _defaultLogs() {
    return [
      WorkoutLog(
        id: 'log1',
        userId: 'user_1',
        workoutTitle: 'Men Upper Body Strength',
        completedAt: DateTime.now().subtract(const Duration(hours: 3)),
        durationSeconds: 2700,
        totalVolumeKg: 3450.0,
        caloriesBurned: 420.0,
        exercisesLogged: const [
          ExerciseLog(exerciseName: 'Dumbbell Bench Press', setsCompleted: 4, repsCompleted: 10, weightKg: 30.0),
          ExerciseLog(exerciseName: 'Overhead Press', setsCompleted: 3, repsCompleted: 12, weightKg: 20.0),
        ],
      ),
      WorkoutLog(
        id: 'log2',
        userId: 'user_2',
        workoutTitle: 'Women Toned Core & Glutes',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        durationSeconds: 2100,
        totalVolumeKg: 1800.0,
        caloriesBurned: 310.0,
        exercisesLogged: const [
          ExerciseLog(exerciseName: 'Glute Bridges', setsCompleted: 4, repsCompleted: 15, weightKg: 15.0),
          ExerciseLog(exerciseName: 'Plank Hold', setsCompleted: 3, repsCompleted: 60, weightKg: 0.0),
        ],
      ),
    ];
  }
}
