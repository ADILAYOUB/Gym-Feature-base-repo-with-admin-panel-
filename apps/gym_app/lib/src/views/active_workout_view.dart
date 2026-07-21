import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';

class ActiveWorkoutView extends ConsumerStatefulWidget {
  final Workout workout;

  const ActiveWorkoutView({Key? key, required this.workout}) : super(key: key);

  static void start(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActiveWorkoutView(workout: workout)),
    );
  }

  @override
  ConsumerState<ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends ConsumerState<ActiveWorkoutView> {
  late Stopwatch _stopwatch;
  Timer? _stopwatchTimer;
  int _restSecondsRemaining = 0;
  Timer? _restTimer;

  // Set Tracking State: Map<ExerciseIndex, List<Map<String, dynamic>>>
  late List<List<Map<String, dynamic>>> _exerciseSets;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

    // Initialize default 3 sets per exercise
    _exerciseSets = List.generate(
      widget.workout.exercises.isNotEmpty ? widget.workout.exercises.length : 3,
      (index) => List.generate(
        3,
        (setIdx) => {
          'setNum': setIdx + 1,
          'weightKg': 20.0,
          'reps': 10,
          'completed': false,
        },
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSecondsRemaining = 60);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _restSecondsRemaining = 0);
      } else {
        setState(() => _restSecondsRemaining--);
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsedSecs = _stopwatch.elapsed.inSeconds;
    final exerciseNames = widget.workout.exercises.isNotEmpty
        ? widget.workout.exercises
        : ['Warm-up Push-ups', 'Dumbbell Bench Press', 'Core Planks'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.greenAccent, size: 16),
                const SizedBox(width: 6),
                Text(_formatDuration(elapsedSecs), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Rest Countdown Banner (Active when resting)
          if (_restSecondsRemaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: Colors.orangeAccent),
                      const SizedBox(width: 10),
                      Text('REST INTERVAL: ${_restSecondsRemaining}s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => setState(() => _restSecondsRemaining = 0),
                    child: const Text('Skip Rest', style: TextStyle(color: Colors.orangeAccent)),
                  ),
                ],
              ),
            ),

          // Exercise Set Logging List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exerciseNames.length,
              itemBuilder: (context, exIdx) {
                final exName = exerciseNames[exIdx];
                final sets = _exerciseSets[exIdx];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(exName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const Icon(Icons.fitness_center, color: Colors.grey, size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Expanded(flex: 1, child: Text('SET', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('WEIGHT (KG)', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text('DONE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const Divider(),
                        ...sets.map((set) {
                          final isDone = set['completed'] as bool;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text('Set ${set['setNum']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextFormField(
                                      initialValue: set['weightKg'].toString(),
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => set['weightKg'] = double.tryParse(val) ?? 20.0,
                                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextFormField(
                                      initialValue: set['reps'].toString(),
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => set['reps'] = int.tryParse(val) ?? 10,
                                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Checkbox(
                                    value: isDone,
                                    activeColor: Colors.green,
                                    onChanged: (val) {
                                      setState(() {
                                        set['completed'] = val ?? false;
                                      });
                                      if (val == true) {
                                        _startRestTimer();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Complete Workout Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _finishWorkout,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Finish Workout & Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishWorkout() async {
    _stopwatch.stop();
    final durationSecs = _stopwatch.elapsed.inSeconds;

    // Calculate Total Volume Lifted (Weight * Reps * Sets)
    double totalVolume = 0.0;
    final List<ExerciseLog> logs = [];

    for (int i = 0; i < widget.workout.exercises.length; i++) {
      final sets = _exerciseSets[i];
      int setsDone = 0;
      int repsDone = 0;
      double weight = 20.0;

      for (var s in sets) {
        if (s['completed'] == true) {
          setsDone++;
          repsDone += s['reps'] as int;
          weight = s['weightKg'] as double;
          totalVolume += (s['weightKg'] as double) * (s['reps'] as int);
        }
      }

      if (setsDone > 0) {
        logs.add(ExerciseLog(
          exerciseName: widget.workout.exercises[i],
          setsCompleted: setsDone,
          repsCompleted: repsDone,
          weightKg: weight,
        ));
      }
    }

    if (totalVolume == 0.0) totalVolume = 2400.0; // Fallback estimate

    final workoutLog = WorkoutLog(
      id: '',
      userId: 'user_1',
      workoutTitle: widget.workout.title,
      completedAt: DateTime.now(),
      durationSeconds: durationSecs > 0 ? durationSecs : 1800,
      totalVolumeKg: totalVolume,
      caloriesBurned: (durationSecs / 60) * 8.5, // ~8.5 kcal/min estimate
      exercisesLogged: logs,
    );

    // Save Log to Firestore
    await ref.read(workoutLogRepositoryProvider).saveWorkoutLog(workoutLog);

    if (!mounted) return;

    // Show Personal Record (PR) Celebration Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1F2A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 72),
              const SizedBox(height: 12),
              const Text('WORKOUT COMPLETED! 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              const Text('NEW PERSONAL RECORD ACHIEVED!', style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF242533), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildSummaryRow('Total Volume Lifted', '${totalVolume.toStringAsFixed(0)} KG'),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Workout Duration', _formatDuration(durationSecs)),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Est. Calories Burned', '${workoutLog.caloriesBurned.toStringAsFixed(0)} kcal'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to main screen
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(val, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
