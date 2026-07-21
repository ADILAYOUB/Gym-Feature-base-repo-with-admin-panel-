import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';

class AnalyticsReportView extends ConsumerWidget {
  const AnalyticsReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);

    final membersAsync = ref.watch(membersStreamProvider);
    final workoutLogsAsync = ref.watch(workoutLogsStreamProvider);
    final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Executive Analytics & Financial Reports', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Deep dive into club MRR, member retention, and workout performance metrics', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, color: activeOrange, size: 18),
                    SizedBox(width: 8),
                    Text('This Month (January 2025) ▼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Executive Summary KPI Cards
          Row(
            children: [
              Expanded(child: _buildKpiCard('Total Monthly Revenue', '\$48,500', '+18.4% vs last month', Icons.monetization_on, Colors.greenAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard('Class Capacity Rate', '94.2%', '+5.1% efficiency', Icons.groups, Colors.orangeAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard('Member Retention', '98.2%', '-0.4% churn rate', Icons.verified_user, Colors.cyanAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard('Avg Workout Duration', '42.5 Mins', '+3 mins engagement', Icons.timer, Colors.purpleAccent)),
            ],
          ),
          const SizedBox(height: 24),

          // Charts Row: Revenue Growth Chart + Subscription Package Share
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Bar Chart
              Expanded(
                flex: 3,
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Revenue Growth (\$ USD)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: RevenueBarChartPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Subscription Share Breakdown
              Expanded(
                flex: 2,
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Active Package Tier Distribution', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      subscriptionsAsync.when(
                        data: (tiers) {
                          return Column(
                            children: [
                              _buildTierDistributionRow('Gold Package', '55%', activeOrange, 0.55),
                              const SizedBox(height: 12),
                              _buildTierDistributionRow('Silver Package', '30%', Colors.grey, 0.30),
                              const SizedBox(height: 12),
                              _buildTierDistributionRow('Platinum Package', '15%', Colors.cyanAccent, 0.15),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error: $err'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Real-Time Member Workout Logs Audit Table
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Member Workout Performance Log', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Audit report of completed member workouts synced from mobile devices', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                workoutLogsAsync.when(
                  data: (logs) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logs.length,
                      itemBuilder: (context, idx) {
                        final log = logs[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1E1F2A), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFF242533),
                                    child: Icon(Icons.fitness_center, color: activeOrange, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(log.workoutTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('Completed by ${log.userId} • ${(log.durationSeconds / 60).toStringAsFixed(0)} mins', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${log.totalVolumeKg.toStringAsFixed(0)} KG Lifted', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${log.caloriesBurned.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error: $err'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String val, String trend, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF242533), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(trend, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTierDistributionRow(String label, String pct, Color color, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(pct, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 8,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class RevenueBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5500)
      ..style = PaintingStyle.fill;

    final double barWidth = size.width / 14;
    final heights = [0.4, 0.55, 0.65, 0.5, 0.8, 0.9, 0.75, 0.85, 0.95, 0.7, 0.88, 1.0];

    for (int i = 0; i < heights.length; i++) {
      final x = i * (barWidth * 1.2) + 20;
      final h = size.height * heights[i] * 0.8;
      final y = size.height - h;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, h), const Radius.circular(6)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
