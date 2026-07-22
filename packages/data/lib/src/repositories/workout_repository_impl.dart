import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final FirebaseFirestore? _firestoreOverride;
  final List<Workout> _localWorkouts = [];
  final List<Exercise> _localExercises = [];
  late final StreamController<List<Workout>> _workoutStreamController;
  late final StreamController<List<Exercise>> _exerciseStreamController;

  WorkoutRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _workoutStreamController = StreamController<List<Workout>>.broadcast();
    _exerciseStreamController = StreamController<List<Exercise>>.broadcast();
    _localExercises.addAll(_defaultExercises());
    _localWorkouts.addAll(_defaultWorkouts());
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
  Stream<List<Workout>> getWorkoutsStream() {
    final fs = _firestore;
    if (fs == null) {
      return _localWorkoutStream();
    }
    try {
      return fs.collection('workouts').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return List<Workout>.from(_localWorkouts);
        }
        final list = snapshot.docs.map((doc) => Workout.fromJson(doc.data(), doc.id)).toList();
        _localWorkouts.clear();
        _localWorkouts.addAll(list);
        return list;
      }).handleError((_) => List<Workout>.from(_localWorkouts));
    } catch (_) {
      return _localWorkoutStream();
    }
  }

  Stream<List<Workout>> _localWorkoutStream() async* {
    yield List<Workout>.from(_localWorkouts);
    yield* _workoutStreamController.stream;
  }

  @override
  Stream<List<Workout>> getWorkoutsByCategoryStream(String category) {
    final cat = category.toLowerCase();
    return getWorkoutsStream().map((list) {
      return list.where((w) => w.category.toLowerCase() == cat).toList();
    });
  }

  @override
  Stream<List<Workout>> watchWorkoutsByCategory(String category) {
    return getWorkoutsByCategoryStream(category);
  }

  @override
  Stream<List<Exercise>> getExercisesStream() {
    final fs = _firestore;
    if (fs == null) {
      return _localExerciseStream();
    }
    try {
      return fs.collection('exercises').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return List<Exercise>.from(_localExercises);
        }
        final list = snapshot.docs.map((doc) => Exercise.fromJson(doc.data(), doc.id)).toList();
        _localExercises.clear();
        _localExercises.addAll(list);
        return list;
      }).handleError((_) => List<Exercise>.from(_localExercises));
    } catch (_) {
      return _localExerciseStream();
    }
  }

  Stream<List<Exercise>> _localExerciseStream() async* {
    yield List<Exercise>.from(_localExercises);
    yield* _exerciseStreamController.stream;
  }

  void _notifyWorkouts() {
    if (!_workoutStreamController.isClosed) {
      _workoutStreamController.add(List<Workout>.from(_localWorkouts));
    }
  }

  void _notifyExercises() {
    if (!_exerciseStreamController.isClosed) {
      _exerciseStreamController.add(List<Exercise>.from(_localExercises));
    }
  }

  @override
  Future<void> addWorkout(Workout workout) async {
    final newWorkout = Workout(
      id: workout.id.isEmpty ? 'w-${DateTime.now().millisecondsSinceEpoch}' : workout.id,
      title: workout.title,
      description: workout.description,
      category: workout.category,
      duration: workout.duration,
      difficulty: workout.difficulty,
      imageUrl: workout.imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600' : workout.imageUrl,
      exercises: workout.exercises,
      exerciseDetails: workout.exerciseDetails,
    );

    _localWorkouts.insert(0, newWorkout);
    _notifyWorkouts();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('workouts').add(newWorkout.toJson());
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    _localWorkouts.removeWhere((w) => w.id == id);
    _notifyWorkouts();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('workouts').doc(id).delete();
      } catch (_) {}
    }
  }

  @override
  Future<void> addExercise(Exercise exercise) async {
    final newExercise = Exercise(
      id: exercise.id.isEmpty ? 'ex-${DateTime.now().millisecondsSinceEpoch}' : exercise.id,
      name: exercise.name,
      category: exercise.category,
      targetMuscle: exercise.targetMuscle,
      equipment: exercise.equipment,
      videoUrl: exercise.videoUrl,
      thumbnailUrl: exercise.thumbnailUrl.isEmpty ? 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=400' : exercise.thumbnailUrl,
      instructions: exercise.instructions,
      defaultSets: exercise.defaultSets,
      defaultReps: exercise.defaultReps,
    );

    _localExercises.insert(0, newExercise);
    _notifyExercises();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('exercises').add(newExercise.toJson());
      } catch (_) {}
    }
  }

  List<Workout> _defaultWorkouts() {
    return [
      Workout(
        id: 'w1',
        title: 'Men Upper Body Strength',
        description: 'Targeted chest, shoulders, and triceps hyper-growth routine.',
        category: 'men',
        duration: '45 min',
        difficulty: 'intermediate',
        imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600',
        exercises: const ['Push-ups', 'Dumbbell Bench Press', 'Tricep Dips', 'Overhead Press'],
        exerciseDetails: _localExercises.where((e) => e.category == 'men').toList(),
      ),
      Workout(
        id: 'w2',
        title: 'Women Toned Core & Glutes',
        description: 'High-intensity glute activation and core toning workout.',
        category: 'women',
        duration: '35 min',
        difficulty: 'beginner',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600',
        exercises: const ['Glute Bridges', 'Plank Hold', 'Mountain Climbers', 'Squat Pulses'],
        exerciseDetails: _localExercises.where((e) => e.category == 'women').toList(),
      ),
      Workout(
        id: 'w3',
        title: 'Kids Fun Agility & Coordination',
        description: 'Playful movement, jump rope, and balance exercises for young athletes.',
        category: 'children',
        duration: '25 min',
        difficulty: 'beginner',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600',
        exercises: const ['Jumping Jacks', 'Frog Jumps', 'Bear Crawls', 'Single-leg Balance'],
        exerciseDetails: _localExercises.where((e) => e.category == 'children').toList(),
      ),
    ];
  }

  List<Exercise> _defaultExercises() {
    return const [
      Exercise(
        id: 'ex1',
        name: 'Dumbbell Bench Press',
        category: 'men',
        targetMuscle: 'Chest',
        equipment: 'Dumbbell',
        videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-man-doing-exercises-with-dumbbells-41485-large.mp4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=400',
        instructions: [
          'Lie flat on the bench holding dumbbells at chest width.',
          'Press upwards extending arms fully without locking elbows.',
          'Lower under control to chest level and repeat.'
        ],
        defaultSets: 4,
        defaultReps: 10,
      ),
      Exercise(
        id: 'ex2',
        name: 'Glute Bridges',
        category: 'women',
        targetMuscle: 'Glutes & Core',
        equipment: 'Bodyweight',
        videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-woman-doing-glute-bridge-exercise-41486-large.mp4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=400',
        instructions: [
          'Lie on back with knees bent and feet flat on floor.',
          'Squeeze glutes and push hips upwards until body forms a straight line.',
          'Hold at the top for 2 seconds and lower under control.'
        ],
        defaultSets: 3,
        defaultReps: 15,
      ),
      Exercise(
        id: 'ex3',
        name: 'Frog Jumps',
        category: 'children',
        targetMuscle: 'Legs & Cardio',
        equipment: 'Bodyweight',
        videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-kids-playing-and-jumping-41487-large.mp4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=400',
        instructions: [
          'Squat down deep touching fingers to ground like a frog.',
          'Explode upwards into the air reaching hands high!',
          'Land softly on balls of feet and repeat.'
        ],
        defaultSets: 3,
        defaultReps: 12,
      ),
    ];
  }
}
