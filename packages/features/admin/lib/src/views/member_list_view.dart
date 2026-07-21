import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';

class MemberListView extends ConsumerStatefulWidget {
  const MemberListView({Key? key}) : super(key: key);

  @override
  ConsumerState<MemberListView> createState() => _MemberListViewState();
}

class _MemberListViewState extends ConsumerState<MemberListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);
    final membersAsync = ref.watch(membersStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Member Directory & Subscriptions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Manage active gym members and membership packages in Firestore', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Filter Bar + Add Member Action Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search here....',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333547),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: const Text('Search'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddMemberDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Member Data Table Card
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: membersAsync.when(
              data: (membersList) {
                final filtered = membersList.where((m) {
                  return m.name.toLowerCase().contains(_searchQuery) ||
                         m.id.toLowerCase().contains(_searchQuery) ||
                         m.packageTier.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No members match your query.', style: TextStyle(color: Colors.grey))),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 48,
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 64,
                    horizontalMargin: 20,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Photo', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Name', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Member Id', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Package', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Joining Date', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Expire Date', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Paid', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Due', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Action', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                    ],
                    rows: filtered.map((member) {
                      final isPaid = member.status == 'Paid';
                      return DataRow(
                        cells: [
                          DataCell(
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(
                                member.photoUrl.isNotEmpty
                                    ? member.photoUrl
                                    : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
                              ),
                            ),
                          ),
                          DataCell(Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(Text(member.id, style: const TextStyle(color: Colors.grey))),
                          DataCell(Text(member.packageTier, style: const TextStyle(color: Colors.white))),
                          DataCell(Text('${member.joiningDate.month}/${member.joiningDate.day}/${member.joiningDate.year}', style: const TextStyle(color: Colors.grey))),
                          DataCell(Text('${member.expireDate.month}/${member.expireDate.day}/${member.expireDate.year}', style: const TextStyle(color: Colors.grey))),
                          DataCell(Text('\$${member.paidAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white))),
                          DataCell(Text('\$${member.dueAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPaid ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                member.status,
                                style: TextStyle(
                                  color: isPaid ? Colors.greenAccent : Colors.orangeAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(onPressed: () => _viewMemberDetails(member), icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.tealAccent, size: 18)),
                                IconButton(onPressed: () => _showEditMemberDialog(member), icon: const Icon(Icons.edit_outlined, color: Colors.orangeAccent, size: 18)),
                                IconButton(
                                  onPressed: () => _deleteMember(member.id),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error loading members: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Subscription Tiers Manager Card Section
          _buildSubscriptionTiersSection(),
        ],
      ),
    );
  }

  // Subscription Tier Management Section
  Widget _buildSubscriptionTiersSection() {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);
    final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Subscription Packages & Pricing Tiers', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Configure membership packages, prices, and feature perks in Firestore', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddSubscriptionDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create New Tier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          subscriptionsAsync.when(
            data: (tiers) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: tiers.length,
                itemBuilder: (context, index) {
                  final tier = tiers[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: activeOrange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tier.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('\$${tier.price.toStringAsFixed(2)}/mo', style: const TextStyle(color: activeOrange, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${tier.durationMonths} Month Duration', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            children: tier.features.map((feat) => Text('• $feat', style: const TextStyle(color: Colors.white70, fontSize: 11))).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading tiers: $err', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewMemberDetails(Member member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Member ID: ${member.id}', style: const TextStyle(color: Colors.grey)),
              Text('Email: ${member.email}', style: const TextStyle(color: Colors.grey)),
              Text('Package: ${member.packageTier}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Status: ${member.status}', style: TextStyle(color: member.status == 'Paid' ? Colors.greenAccent : Colors.orangeAccent)),
              const SizedBox(height: 12),
              Text('Paid: \$${member.paidAmount} | Due: \$${member.dueAmount}', style: const TextStyle(color: Colors.white)),
              Text('Pass Code: ${member.qrCode}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        );
      },
    );
  }

  void _showEditMemberDialog(Member member) {
    final nameCtrl = TextEditingController(text: member.name);
    final emailCtrl = TextEditingController(text: member.email);
    final paidCtrl = TextEditingController(text: member.paidAmount.toStringAsFixed(0));
    final dueCtrl = TextEditingController(text: member.dueAmount.toStringAsFixed(0));
    String pkg = member.packageTier;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: const Text('Edit Member Details', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Member Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: pkg,
                isExpanded: true,
                dropdownColor: const Color(0xFF242533),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Membership Package'),
                items: const [
                  DropdownMenuItem(value: 'Gold Membership', child: Text('Gold Membership', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Silver Membership', child: Text('Silver Membership', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Platinum Membership', child: Text('Platinum Membership', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  if (val != null) pkg = val;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: paidCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Paid (\$)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: dueCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Due (\$)'),
                    ),
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updated = Member(
                  id: member.id,
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  photoUrl: member.photoUrl,
                  packageTier: pkg,
                  joiningDate: member.joiningDate,
                  expireDate: member.expireDate,
                  paidAmount: double.tryParse(paidCtrl.text) ?? member.paidAmount,
                  dueAmount: double.tryParse(dueCtrl.text) ?? member.dueAmount,
                  status: (double.tryParse(dueCtrl.text) ?? 0) > 0 ? 'Not paid' : 'Paid',
                  qrCode: member.qrCode,
                );

                await ref.read(memberRepositoryProvider).updateMember(updated);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Update Member'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSubscriptionDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '49.99');
    final featuresCtrl = TextEditingController(text: 'Full Access, Personal Workouts, Sauna');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: const Text('Create New Subscription Tier', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Tier Name (e.g. VIP VIP Membership)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Price (\$)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: featuresCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Perks (comma separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final featuresList = featuresCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  final tier = SubscriptionTier(
                    id: '',
                    name: nameCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 49.99,
                    durationMonths: 1,
                    features: featuresList,
                  );

                  await ref.read(subscriptionRepositoryProvider).addSubscriptionTier(tier);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Package Tier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMember(String id) async {
    try {
      await ref.read(memberRepositoryProvider).deleteMember(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting member: $e')),
      );
    }
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final paidCtrl = TextEditingController(text: '450');
    final dueCtrl = TextEditingController(text: '0');
    String pkg = 'Gold Membership';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: const Text('Add New Gym Member', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Member Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: pkg,
                isExpanded: true,
                dropdownColor: const Color(0xFF242533),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Membership Package'),
                items: const [
                  DropdownMenuItem(value: 'Gold Membership', child: Text('Gold Membership', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Silver Membership', child: Text('Silver Membership', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Platinum Membership', child: Text('Platinum Membership', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  if (val != null) pkg = val;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: paidCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Paid (\$)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: dueCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Due (\$)'),
                    ),
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final newMember = Member(
                    id: '',
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
                    packageTier: pkg,
                    joiningDate: DateTime.now(),
                    expireDate: DateTime.now().add(const Duration(days: 365)),
                    paidAmount: double.tryParse(paidCtrl.text) ?? 450.0,
                    dueAmount: double.tryParse(dueCtrl.text) ?? 0.0,
                    status: (double.tryParse(dueCtrl.text) ?? 0) > 0 ? 'Not paid' : 'Paid',
                    qrCode: 'GYM-MEMBER-${DateTime.now().millisecondsSinceEpoch}',
                  );

                  await ref.read(memberRepositoryProvider).addMember(newMember);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Member'),
            ),
          ],
        );
      },
    );
  }
}
