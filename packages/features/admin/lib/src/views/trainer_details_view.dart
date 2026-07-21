import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';

class TrainerDetailsView extends ConsumerStatefulWidget {
  const TrainerDetailsView({Key? key}) : super(key: key);

  @override
  ConsumerState<TrainerDetailsView> createState() => _TrainerDetailsViewState();
}

class _TrainerDetailsViewState extends ConsumerState<TrainerDetailsView> {
  int _selectedTrainerIndex = 0;

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);
    final trainersAsync = ref.watch(trainersStreamProvider);

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
                  Text('Trainer Profiles & Schedule Management', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Manage certified gym coaches and class batch schedules in Firestore', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddTrainerDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add New Trainer', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          trainersAsync.when(
            data: (trainers) {
              if (trainers.isEmpty) {
                return const Center(child: Text('No trainers found.', style: TextStyle(color: Colors.grey)));
              }
              final trainer = _selectedTrainerIndex < trainers.length ? trainers[_selectedTrainerIndex] : trainers.first;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trainer Selection Pills
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trainers.length,
                      itemBuilder: (context, idx) {
                        final isSelected = _selectedTrainerIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedTrainerIndex = idx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? activeOrange : cardBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                trainers[idx].name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Content Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Profile Card, Contact, Certifications
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundImage: NetworkImage(
                                      trainer.photoUrl.isNotEmpty
                                          ? trainer.photoUrl
                                          : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(trainer.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(trainer.role, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildMetricItem('${trainer.experienceYears} yrs', 'Experience'),
                                      _buildMetricItem('${trainer.memberCount}+', 'Members'),
                                      _buildMetricItem('${trainer.rating}/5', 'Rating'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Contact', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  _buildContactRow(Icons.email_outlined, 'Email', trainer.email),
                                  const SizedBox(height: 12),
                                  _buildContactRow(Icons.phone_outlined, 'Phone', trainer.phone),
                                  const SizedBox(height: 12),
                                  _buildContactRow(Icons.home_outlined, 'Address', trainer.address),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Certifications', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  ...trainer.certifications.map((cert) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: _buildCertItem(cert, 'Verified'),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Right Column: Activity Line Painter & Schedule List
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Training Activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: activeOrange, borderRadius: BorderRadius.circular(8)),
                                        child: const Text('1-12 January 2025 ▼', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 180,
                                    child: CustomPaint(size: Size.infinite, painter: ActivityLinePainter()),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${trainer.name}\'s Class Schedule', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 16),
                                  ...trainer.schedule.map((item) => Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: const Color(0xFF1E1F2A), borderRadius: BorderRadius.circular(8)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                                Text('${item.dateStr} • ${item.timeStr}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text('${item.participantsCount} Participants • ${item.durationMins} Mins', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading trainers: $err', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCertItem(String title, String status) {
    return Row(
      children: [
        const Icon(Icons.workspace_premium, color: Color(0xFFFF5500), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(status, style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
            ],
          ),
        )
      ],
    );
  }

  void _showAddTrainerDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Strength & Conditioning Coach');
    final expCtrl = TextEditingController(text: '5');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final certsCtrl = TextEditingController(text: 'NASM Certified, ACE Personal Trainer');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: const Text('Add New Gym Trainer', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Trainer Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Role / Specialization'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expCtrl,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Years of Experience'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: certsCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Certifications (comma separated)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final certsList = certsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  final trainer = Trainer(
                    id: '',
                    name: nameCtrl.text.trim(),
                    role: roleCtrl.text.trim(),
                    photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300',
                    bio: 'Certified elite fitness trainer.',
                    experienceYears: int.tryParse(expCtrl.text) ?? 5,
                    memberCount: 100,
                    rating: 5.0,
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    address: '4517 Washington Ave.',
                    certifications: certsList,
                    schedule: const [
                      TrainerScheduleItem(title: 'Strength & Power', dateStr: 'Mon, 6 Jan', timeStr: '09:00 AM', participantsCount: 15, durationMins: 45),
                    ],
                  );

                  await ref.read(trainerRepositoryProvider).addTrainer(trainer);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Trainer'),
            ),
          ],
        );
      },
    );
  }
}

class ActivityLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(size.width * 0.2, size.height * 0.7, size.width * 0.4, size.height * 0.2, size.width * 0.5, size.height * 0.15);
    path.cubicTo(size.width * 0.7, size.height * 0.3, size.width * 0.8, size.height * 0.6, size.width, size.height * 0.5);

    canvas.drawPath(path, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
