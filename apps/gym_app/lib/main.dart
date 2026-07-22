import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';
import 'package:sdui/sdui.dart';
import 'package:core_ui/core_ui.dart';
import 'src/views/shell_view.dart';
import 'src/views/active_workout_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register global tap handler for SDUI workout cards
  globalOnWorkoutSelected = (context, workout) {
    ActiveWorkoutView.start(context, workout);
  };

  // Try initializing Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
    debugPrint('Proceeding with local/offline fallback configuration.');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Link SDUI's abstract workouts provider to the concrete Firestore repository
        sduiWorkoutsProvider.overrideWith((ref, category) {
          final repo = ref.watch(workoutRepositoryProvider);
          return repo.watchWorkoutsByCategory(category);
        }),
      ],
      child: const GymApp(),
    ),
  );
}

class GymApp extends ConsumerWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the active theme configuration stream from Firestore
    final themeConfigAsync = ref.watch(themeConfigProvider);

    return themeConfigAsync.when(
      data: (config) => _buildAppWithConfig(config),
      loading: () => _buildAppWithConfig(ThemeConfig.fallback()),
      error: (_, _) => _buildAppWithConfig(ThemeConfig.fallback()),
    );
  }

  Widget _buildAppWithConfig(ThemeConfig config) {
    final themeData = DynamicThemeBuilder.buildTheme(config, Brightness.dark);
    return MaterialApp(
      title: 'Fitflow Gym App',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const ShellView(),
    );
  }
}
