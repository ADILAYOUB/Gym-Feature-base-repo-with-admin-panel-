import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';
import 'package:sdui/sdui.dart';
import '../state/providers.dart';
import 'community_hub_view.dart';
import 'trainer_booking_view.dart';
import 'recovery_hub_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final layoutAsync = ref.watch(layoutSectionsProvider);
    final selectedGender = ref.watch(selectedGenderProvider);
    final featuresAsync = ref.watch(featureFlagsProvider);
    final aiAsync = ref.watch(aiRecommendationStreamProvider('user_1'));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GYM & TRAINING',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Dynamic Fitness Planner',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            onPressed: () => _showNotificationsSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Recovery & Wearable',
            onPressed: () => RecoveryHubView.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Trainers & Classes',
            onPressed: () => TrainerBookingView.show(context),
          ),
          featuresAsync.when(
            data: (flags) => Row(
              children: [
                if (flags.enableLeaderboard)
                  IconButton(
                    icon: const Icon(Icons.leaderboard),
                    tooltip: 'Leaderboard',
                    onPressed: () => CommunityHubView.show(context),
                  ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Smart Coach Recommendation Banner (Phase 9)
          aiAsync.when(
            data: (rec) {
              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary.withOpacity(0.85), Colors.purple.shade900],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(rec.recommendationText, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, _) => const SizedBox.shrink(),
          ),

          // SDUI Dynamic Page Body
          Expanded(
            child: layoutAsync.when(
              data: (sections) {
                return SDUIPageBuilder(
                  sections: sections,
                  selectedGender: selectedGender,
                  onGenderChanged: (gender) {
                    ref.read(selectedGenderProvider.notifier).state = gender;
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Failed to load layout: $err'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(layoutSectionsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.read(notificationsStreamProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.notifications_active, color: Colors.orangeAccent),
                  SizedBox(width: 10),
                  Text('Gym Notifications & Announcements', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              notifsAsync.when(
                data: (list) {
                  return Column(
                    children: list.map((n) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF242533),
                            child: Icon(Icons.campaign, color: Colors.orangeAccent, size: 20),
                          ),
                          title: Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(n.body, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading notifications: $err'),
              ),
            ],
          ),
        );
      },
    );
  }
}
