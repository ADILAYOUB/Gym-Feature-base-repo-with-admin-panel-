import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_view.dart';
import 'membership_pass_view.dart';
import 'nutrition_hub_view.dart';
import 'package:admin/admin.dart';

class ShellView extends ConsumerStatefulWidget {
  const ShellView({Key? key}) : super(key: key);

  @override
  ConsumerState<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends ConsumerState<ShellView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 1. Web Platform: Render DEDICATED Desktop Fitflow Admin Portal ONLY
    if (kIsWeb) {
      return const FitflowAdminDashboard();
    }

    // 2. Mobile Platforms (iOS & Android): Render User App ONLY
    final List<Widget> screens = [
      const HomeView(),
      const _MyWorkoutsView(),
      const NutritionHubView(),
      const MembershipPassView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'My Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            label: 'Gym Pass',
          ),
        ],
      ),
    );
  }
}

class _MyWorkoutsView extends StatelessWidget {
  const _MyWorkoutsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Workouts', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.fitness_center, color: theme.colorScheme.primary, size: 32),
              title: const Text('Upper Body Strength', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('45 mins • 8 exercises completed'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.directions_run, color: theme.colorScheme.primary, size: 32),
              title: const Text('Morning Cardio & Core', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('30 mins • Scheduled for tomorrow'),
              trailing: const Icon(Icons.play_circle_fill, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
