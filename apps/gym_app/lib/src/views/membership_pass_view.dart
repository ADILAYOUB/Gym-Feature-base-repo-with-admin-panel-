import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';

class MembershipPassView extends ConsumerWidget {
  const MembershipPassView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(membersStreamProvider);
    final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Gym Pass', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: membersAsync.when(
        data: (members) {
          final member = members.isNotEmpty ? members.first : _fallbackMember();
          final remainingDays = member.expireDate.difference(DateTime.now()).inDays;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Digital Pass Metallic Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                        const Color(0xFF1E1F2A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.fitness_center, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text('FITFLOW PASS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              member.packageTier.toUpperCase(),
                              style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        member.name,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${member.id} • ${member.email}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('STATUS', style: TextStyle(color: Colors.white60, fontSize: 10)),
                              Text(member.status, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('REMAINING', style: TextStyle(color: Colors.white60, fontSize: 10)),
                              Text('$remainingDays Days Left', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // QR Code Gym Check-in Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text('Contactless Gym Check-In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('Scan this QR code at the turnstile gate', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 16),
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2, size: 120, color: theme.colorScheme.primary),
                              Text(member.qrCode, style: const TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Active Package Perks & Upgrade Button Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Package Features', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showUpgradeSheet(context, ref, member),
                      icon: const Icon(Icons.upgrade),
                      label: const Text('Upgrade Tier'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                subscriptionsAsync.when(
                  data: (tiers) {
                    final currentTier = tiers.firstWhere(
                      (t) => t.name.toLowerCase() == member.packageTier.toLowerCase(),
                      orElse: () => tiers.first,
                    );
                    return Column(
                      children: currentTier.features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 12),
                              Text(feature, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading tier features: $err'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading member pass: $err')),
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context, WidgetRef ref, Member member) {
    final subscriptionsAsync = ref.read(subscriptionsStreamProvider);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1F2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upgrade Membership Tier', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Select a package to unlock VIP lounge, trainers, and unlimited charts', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              Expanded(
                child: subscriptionsAsync.when(
                  data: (tiers) {
                    return ListView.builder(
                      itemCount: tiers.length,
                      itemBuilder: (context, index) {
                        final tier = tiers[index];
                        final isSelected = tier.name.toLowerCase() == member.packageTier.toLowerCase();
                        return Card(
                          color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : const Color(0xFF242533),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(tier.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('\$${tier.price.toStringAsFixed(2)} / month', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(tier.features.join(' • '), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: isSelected ? null : () async {
                                final updated = Member(
                                  id: member.id,
                                  name: member.name,
                                  email: member.email,
                                  photoUrl: member.photoUrl,
                                  packageTier: tier.name,
                                  joiningDate: member.joiningDate,
                                  expireDate: member.expireDate,
                                  paidAmount: member.paidAmount + tier.price,
                                  dueAmount: 0.0,
                                  status: 'Paid',
                                  qrCode: member.qrCode,
                                );
                                await ref.read(memberRepositoryProvider).updateMember(updated);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Upgraded package to ${tier.name} successfully!')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? Colors.grey : theme.colorScheme.primary,
                              ),
                              child: Text(isSelected ? 'Active' : 'Choose'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading tiers: $err'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Member _fallbackMember() {
    return Member(
      id: '3536',
      name: 'Cody Fisher',
      email: 'cody@example.com',
      photoUrl: '',
      packageTier: 'Gold Membership',
      joiningDate: DateTime.now(),
      expireDate: DateTime.now().add(const Duration(days: 248)),
      paidAmount: 450.0,
      dueAmount: 0.0,
      status: 'Paid',
      qrCode: 'GYM-PASS-3536',
    );
  }
}
