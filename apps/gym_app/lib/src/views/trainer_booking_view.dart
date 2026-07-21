import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';

class TrainerBookingView extends ConsumerWidget {
  const TrainerBookingView({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerBookingView()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trainersAsync = ref.watch(trainersStreamProvider);
    final bookingsAsync = ref.watch(userBookingsStreamProvider('user_1'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Trainers & Classes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Confirmed Bookings Section
            bookingsAsync.when(
              data: (bookings) {
                if (bookings.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.event_available, color: Colors.greenAccent),
                          SizedBox(width: 8),
                          Text('My Confirmed Class Bookings', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...bookings.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('• ${b.className} with ${b.trainerName} (${b.status})', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                          )),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
            ),

            Text('Certified Gym Coaches', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            trainersAsync.when(
              data: (trainers) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trainers.length,
                  itemBuilder: (context, index) {
                    final trainer = trainers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundImage: NetworkImage(
                                    trainer.photoUrl.isNotEmpty
                                        ? trainer.photoUrl
                                        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(trainer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(trainer.role, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text('${trainer.rating} (${trainer.memberCount}+ members)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(trainer.bio, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showTrainerScheduleSheet(context, ref, trainer),
                                icon: const Icon(Icons.calendar_month, size: 18),
                                label: const Text('View Schedule & Book Class'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading trainers: $err'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainerScheduleSheet(BuildContext context, WidgetRef ref, Trainer trainer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1F2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${trainer.name}\'s Classes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              const Text('Select an upcoming session to reserve your slot', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: trainer.schedule.isEmpty ? 1 : trainer.schedule.length,
                  itemBuilder: (context, idx) {
                    if (trainer.schedule.isEmpty) {
                      return const Text('No active classes scheduled.', style: TextStyle(color: Colors.grey));
                    }
                    final item = trainer.schedule[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF242533), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('${item.dateStr} • ${item.timeStr} (${item.durationMins} mins)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final booking = ClassBooking(
                                id: '',
                                userId: 'user_1',
                                trainerName: trainer.name,
                                className: item.title,
                                bookingTime: DateTime.now(),
                                status: 'Confirmed',
                              );
                              await ref.read(bookingRepositoryProvider).createBooking(booking);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Booked ${item.title} with ${trainer.name}!')),
                                );
                              }
                            },
                            child: const Text('Book Slot'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
