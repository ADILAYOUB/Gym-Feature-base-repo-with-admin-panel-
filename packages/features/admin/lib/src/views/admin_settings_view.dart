import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';

class AdminSettingsView extends ConsumerStatefulWidget {
  const AdminSettingsView({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends ConsumerState<AdminSettingsView> {
  final _notifTitleController = TextEditingController();
  final _notifBodyController = TextEditingController();
  String _notifType = 'workout_reminder';

  @override
  void dispose() {
    _notifTitleController.dispose();
    _notifBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);

    final themeAsync = ref.watch(themeConfigProvider);
    final featuresAsync = ref.watch(featureFlagsProvider);
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin System Settings & Broadcast Center', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Configure global branding, dynamic feature flags, and broadcast push notifications', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),

          // Push Notification Broadcast Dispatcher Card (Phase 9)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Broadcast Push Notification to Members', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.send_rounded, color: activeOrange),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Dispatch real-time notification alerts to mobile app users via Firestore', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notifTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Notification Title (e.g. 🔥 Weekend Special Class!)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notifBodyController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notification Message Body'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _notifType,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Notification Type'),
                  items: const [
                    DropdownMenuItem(value: 'workout_reminder', child: Text('Workout Reminder', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'diet_tip', child: Text('Diet & Nutrition Tip', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'subscription_expiry', child: Text('Subscription Expiry Alert', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _notifType = val);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _broadcastNotification,
                    icon: const Icon(Icons.campaign),
                    label: const Text('Dispatch Push Notification Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: activeOrange, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                const Text('Recent Broadcast History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                notificationsAsync.when(
                  data: (notifs) {
                    return Column(
                      children: notifs.take(3).map((n) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF1E1F2A), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(n.body, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: activeOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text(n.type.toUpperCase(), style: const TextStyle(color: activeOrange, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error: $err'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feature Flags Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dynamic Feature Toggles', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                featuresAsync.when(
                  data: (flags) => Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Member Leaderboard', style: TextStyle(color: Colors.white)),
                        value: flags.enableLeaderboard,
                        onChanged: (val) => _updateFlags(flags.copyWith(enableLeaderboard: val)),
                      ),
                      SwitchListTile(
                        title: const Text('Enable Prescribed Diet Plans', style: TextStyle(color: Colors.white)),
                        value: flags.enableDietPlans,
                        onChanged: (val) => _updateFlags(flags.copyWith(enableDietPlans: val)),
                      ),
                      SwitchListTile(
                        title: const Text('Enable AI Workout Recommendations', style: TextStyle(color: Colors.white)),
                        value: flags.enableAiRecommendations,
                        onChanged: (val) => _updateFlags(flags.copyWith(enableAiRecommendations: val)),
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _broadcastNotification() async {
    if (_notifTitleController.text.trim().isEmpty) return;

    final notification = PushNotification(
      id: '',
      title: _notifTitleController.text.trim(),
      body: _notifBodyController.text.trim(),
      sentTime: DateTime.now(),
      type: _notifType,
    );

    await ref.read(notificationRepositoryProvider).sendNotification(notification);

    _notifTitleController.clear();
    _notifBodyController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Push Notification dispatched to members!')),
    );
  }

  Future<void> _updateFlags(FeatureFlags newFlags) async {
    await ref.read(configRepositoryProvider).updateFeatureFlags(newFlags);
  }
}
