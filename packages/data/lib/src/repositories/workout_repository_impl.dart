import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final FirebaseFirestore _firestore;

  WorkoutRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Workout>> getWorkoutsStream() {
    return _firestore.collection('workouts').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultWorkouts();
      }
      return snapshot.docs.map((doc) => Workout.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<Workout>> getWorkoutsByCategoryStream(String category) {
    return _firestore
        .collection('workouts')
        .where('category', isEqualTo: category.toLowerCase())
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultWorkouts().where((w) => w.category == category.toLowerCase()).toList();
      }
      return snapshot.docs.map((doc) => Workout.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<Workout>> watchWorkoutsByCategory(String category) {
    return getWorkoutsByCategoryStream(category);
  }

  @override
  Stream<List<Exercise>> getExercisesStream() {
    return _firestore.collection('exercises').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultExercises();
      }
      return snapshot.docs.map((doc) => Exercise.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addWorkout(Workout workout) async {
    await _firestore.collection('workouts').add(workout.toJson());
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await _firestore.collection('workouts').doc(id).delete();
  }

  @override
  Future<void> addExercise(Exercise exercise) async {
    await _firestore.collection('exercises').add(exercise.toJson());
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
        exercises: ['Push-ups', 'Dumbbell Bench Press', 'Tricep Dips', 'Overhead Press'],
        exerciseDetails: _defaultExercises().where((e) => e.category == 'men').toList(),
      ),
      Workout(
        id: 'w2',
        title: 'Women Toned Core & Glutes',
        description: 'High-intensity glute activation and core toning workout.',
        category: 'women',
        duration: '35 min',
        difficulty: 'beginner',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600',
        exercises: ['Glute Bridges', 'Plank Hold', 'Mountain Climbers', 'Squat Pulses'],
        exerciseDetails: _defaultExercises().where((e) => e.category == 'women').toList(),
      ),
      Workout(
        id: 'w3',
        title: 'Kids Fun Agility & Coordination',
        description: 'Playful movement, jump rope, and balance exercises for young athletes.',
        category: 'children',
        duration: '25 min',
        difficulty: 'beginner',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600',
        exercises: ['Jumping Jacks', 'Frog Jumps', 'Bear Crawls', 'Single-leg Balance'],
        exerciseDetails: _defaultExercises().where((e) => e.category == 'children').toList(),
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
