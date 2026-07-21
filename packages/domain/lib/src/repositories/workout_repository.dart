import '../models/workout.dart';

abstract class WorkoutRepository {
  Stream<List<Workout>> getWorkoutsStream();
  Stream<List<Workout>> getWorkoutsByCategoryStream(String category);
  Stream<List<Workout>> watchWorkoutsByCategory(String category);
  Stream<List<Exercise>> getExercisesStream();
  Future<void> addWorkout(Workout workout);
  Future<void> deleteWorkout(String id);
  Future<void> addExercise(Exercise exercise);
}
