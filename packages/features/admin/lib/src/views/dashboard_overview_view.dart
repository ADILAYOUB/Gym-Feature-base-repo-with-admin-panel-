import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';

class DashboardOverviewView extends ConsumerWidget {
  const DashboardOverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);
    final workoutLogsAsync = ref.watch(workoutLogsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Welcome Banner + Member Activity Card
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Hero Banner
              Expanded(
                flex: 3,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: const NetworkImage('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800'),
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'January 11, 2024',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Welcome Back, Emon',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ready to set up your club\'s\nLoyalty Card?',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Set Up', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Member Activity Card
              Expanded(
                flex: 2,
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Member Activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            // Circular Indicator Visual
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 110,
                                    height: 110,
                                    child: CircularProgressIndicator(
                                      value: 0.90,
                                      strokeWidth: 12,
                                      backgroundColor: Colors.amber.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: 0.65,
                                      strokeWidth: 10,
                                      backgroundColor: Colors.green.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                    ),
                                  ),
                                  const Text('90%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Legend Text
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem('08:00 - 10:00', Colors.orangeAccent),
                                const SizedBox(height: 8),
                                _buildLegendItem('10:00 - 14:00', Colors.greenAccent),
                                const SizedBox(height: 8),
                                _buildLegendItem('14:00 - 18:00', Colors.blueAccent),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Middle Row: 3 Metric Cards
          Row(
            children: [
              Expanded(child: _buildMetricCard('Current Members', '5,890', '+3,840 (26.80%)', Icons.people)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('New Members', '2,000', '+530 (8.38%)', Icons.trending_up)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Today Visitors', '500', '+530 (8.38%)', Icons.directions_walk)),
            ],
          ),
          const SizedBox(height: 20),

          // Bottom Row: Membership Status Report + Target Gauge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line Chart Report
              Expanded(
                flex: 3,
                child: Container(
                  height: 260,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Membership Status Report', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              _buildDotLegend('Gold', activeOrange),
                              const SizedBox(width: 12),
                              _buildDotLegend('Silver', Colors.grey),
                              const SizedBox(width: 12),
                              _buildDotLegend('Platinum', Colors.tealAccent),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: ReportChartPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Target Radial Gauge
              Expanded(
                flex: 2,
                child: Container(
                  height: 260,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Membership Target', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            const Text('75.55%', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: const Text('+10%', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),
                            const Text('It\'s higher than yesterday', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Target: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                Text('200 ↓  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Today: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                Text('250 ↑', style: TextStyle(color: activeOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Live Workout Performance Analytics Log Feed Card (Phase 4)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Real-Time User Workout Logs & Analytics', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.bar_chart, color: activeOrange),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Live feed of workout routines completed by gym members', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                workoutLogsAsync.when(
                  data: (logs) {
                    if (logs.isEmpty) {
                      return const Text('No workout logs recorded yet.', style: TextStyle(color: Colors.grey));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1E1F2A), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log.workoutTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text('User ID: ${log.userId} • ${log.exercisesLogged.length} Exercises Executed', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${log.totalVolumeKg.toStringAsFixed(0)} KG Lifted', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${log.caloriesBurned.toStringAsFixed(0)} kcal • ${(log.durationSeconds / 60).toStringAsFixed(0)} mins', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
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

  Widget _buildMetricCard(String title, String count, String trend, IconData icon) {
    const cardBg = Color(0xFF242533);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Icon(icon, color: Colors.grey.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(trend, style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildDotLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class ReportChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFFF5500)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final tealPaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.3);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.4);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.8, size.width * 0.6, size.height * 0.3);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.1, size.width, size.height * 0.6);

    canvas.drawPath(path1, linePaint);
    canvas.drawPath(path2, tealPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
