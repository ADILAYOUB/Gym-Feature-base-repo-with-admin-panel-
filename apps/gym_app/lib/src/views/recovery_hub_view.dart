import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';

class RecoveryHubView extends ConsumerWidget {
  const RecoveryHubView({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecoveryHubView()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recoveryAsync = ref.watch(recoveryDataStreamProvider('user_1'));
    final meditationsAsync = ref.watch(meditationSessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery & Wearable Sync', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wearable Telemetry & Readiness Card
            recoveryAsync.when(
              data: (data) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242533),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BODY READINESS SCORE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${data.recoveryScore}%', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                              Text(data.readinessStatus, style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(recoveryRepositoryProvider).syncWearableData('user_1');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Apple Health / Google Fit Telemetry Synced!')),
                                );
                              }
                            },
                            icon: const Icon(Icons.watch, size: 16),
                            label: const Text('Sync Wearable'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                              foregroundColor: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTelemetryItem(Icons.favorite, '${data.restingHeartRateBpm} BPM', 'Resting HR'),
                          _buildTelemetryItem(Icons.monitor_heart, '${data.hrvMs} ms', 'HRV'),
                          _buildTelemetryItem(Icons.bedtime, '${data.sleepHours} hrs', 'Sleep'),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading recovery metrics: $err'),
            ),
            const SizedBox(height: 24),

            Text('Guided Recovery & Meditation Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            meditationsAsync.when(
              data: (sessions) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  itemBuilder: (context, idx) {
                    final session = sessions[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(session.imageUrl.isNotEmpty ? session.imageUrl : 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${session.category} • ${session.durationMins} mins', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 36),
                          onPressed: () => _playMeditationSession(context, session),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading meditation sessions: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.cyanAccent, size: 20),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  void _playMeditationSession(BuildContext context, MeditationSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(session.imageUrl.isNotEmpty ? session.imageUrl : 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(session.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(session.description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.replay_10, color: Colors.white, size: 28),
                  SizedBox(width: 24),
                  Icon(Icons.pause_circle_filled, color: Colors.greenAccent, size: 54),
                  SizedBox(width: 24),
                  Icon(Icons.forward_10, color: Colors.white, size: 28),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
