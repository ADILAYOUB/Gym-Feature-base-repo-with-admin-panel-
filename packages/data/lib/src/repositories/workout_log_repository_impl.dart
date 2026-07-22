import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class WorkoutLogRepositoryImpl implements WorkoutLogRepository {
  final FirebaseFirestore? _firestoreOverride;
  final List<WorkoutLog> _localLogs = [];
  late final StreamController<List<WorkoutLog>> _streamController;

  WorkoutLogRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<List<WorkoutLog>>.broadcast();
    _localLogs.addAll(_defaultLogs());
  }

  FirebaseFirestore? get _firestore {
    if (_firestoreOverride != null) return _firestoreOverride;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  @override
  Stream<List<WorkoutLog>> getWorkoutLogsStream() {
    final fs = _firestore;
    if (fs == null) return _localStream();
    try {
      return fs
          .collection('workout_logs')
          .orderBy('completedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return List<WorkoutLog>.from(_localLogs);
        final list = snapshot.docs.map((doc) => WorkoutLog.fromJson(doc.data(), doc.id)).toList();
        _localLogs.clear();
        _localLogs.addAll(list);
        return list;
      }).handleError((_) => List<WorkoutLog>.from(_localLogs));
    } catch (_) {
      return _localStream();
    }
  }

  Stream<List<WorkoutLog>> _localStream() async* {
    yield List<WorkoutLog>.from(_localLogs);
    yield* _streamController.stream;
  }

  @override
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    final newLog = WorkoutLog(
      id: log.id.isEmpty ? 'log-${DateTime.now().millisecondsSinceEpoch}' : log.id,
      userId: log.userId,
      workoutTitle: log.workoutTitle,
      completedAt: log.completedAt,
      durationSeconds: log.durationSeconds,
      totalVolumeKg: log.totalVolumeKg,
      caloriesBurned: log.caloriesBurned,
      exercisesLogged: log.exercisesLogged,
    );

    _localLogs.insert(0, newLog);
    _streamController.add(List<WorkoutLog>.from(_localLogs));

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('workout_logs').add(newLog.toJson());
      } catch (_) {}
    }
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
