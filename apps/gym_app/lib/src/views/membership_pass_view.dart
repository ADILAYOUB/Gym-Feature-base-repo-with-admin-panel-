import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';

class MembershipPassView extends ConsumerStatefulWidget {
  const MembershipPassView({super.key});

  @override
  ConsumerState<MembershipPassView> createState() => _MembershipPassViewState();
}

class _MembershipPassViewState extends ConsumerState<MembershipPassView> {
  bool _showBackOfCard = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(membersStreamProvider);
    final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1017),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Digital Gym Pass',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showBackOfCard ? Icons.credit_card : Icons.qr_code_scanner,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Flip Pass',
            onPressed: () {
              setState(() {
                _showBackOfCard = !_showBackOfCard;
              });
            },
          ),
        ],
      ),
      body: membersAsync.when(
        data: (members) {
          final member = members.isNotEmpty ? members.first : _fallbackMember();
          final remainingDays = member.expireDate.difference(DateTime.now()).inDays;
          final isExpired = remainingDays <= 0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Holographic Metallic VIP Pass Card (Click to flip)
                GestureDetector(
                  onTap: () => setState(() => _showBackOfCard = !_showBackOfCard),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: Tween<double>(begin: 0.5, end: 1.0).animate(anim),
                      child: child,
                    ),
                    child: _showBackOfCard
                        ? _buildCardBack(context, member, theme)
                        : _buildCardFront(context, member, remainingDays, theme),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Tap pass to flip between Card & Gate Barcode',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Quick Action Strip (Wallet + Upgrade)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1F2E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pass saved to digital wallet!')),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                              SizedBox(width: 8),
                              Text('Add to Wallet', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withRed(255),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _showUpgradeSheet(context, ref, member),
                          borderRadius: BorderRadius.circular(14),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bolt, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text('Upgrade Membership', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 3. Contactless Turnstile Gate Scanner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181924),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gate Turnstile Check-In',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Hold near optical scanner at gym entrance',
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isExpired ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isExpired ? Colors.redAccent : Colors.greenAccent.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 4,
                                  backgroundColor: isExpired ? Colors.redAccent : Colors.greenAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isExpired ? 'EXPIRED' : 'ACCESS ACTIVE',
                                  style: TextStyle(
                                    color: isExpired ? Colors.redAccent : Colors.greenAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.qr_code_2_rounded, size: 140, color: const Color(0xFF10121A)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member.qrCode,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 4. Included Package Perks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Membership Privileges',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.packageTier,
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                subscriptionsAsync.when(
                  data: (tiers) {
                    final currentTier = tiers.firstWhere(
                      (t) => t.name.toLowerCase() == member.packageTier.toLowerCase(),
                      orElse: () => tiers.first,
                    );
                    return Column(
                      children: currentTier.features.map((feature) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161722),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.04)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check, color: theme.colorScheme.primary, size: 14),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading features: $err', style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading member pass: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  // Front Side of Card (Metallic Glossy Finish)
  Widget _buildCardFront(BuildContext context, Member member, int remainingDays, ThemeData theme) {
    final isGold = member.packageTier.toLowerCase().contains('gold');
    final isPlatinum = member.packageTier.toLowerCase().contains('platinum');

    final gradientColors = isPlatinum
        ? [const Color(0xFF2E3141), const Color(0xFF1D1F2C), const Color(0xFF0F1017)]
        : isGold
            ? [const Color(0xFF3B2E16), const Color(0xFF261D0C), const Color(0xFF140F06)]
            : [const Color(0xFF1E2838), const Color(0xFF131A26), const Color(0xFF0A0F17)];

    final badgeColor = isPlatinum
        ? Colors.cyanAccent
        : isGold
            ? Colors.amber
            : theme.colorScheme.primary;

    return Container(
      key: const ValueKey('CardFront'),
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Watermark Logo
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.fitness_center,
              size: 180,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Header: App Brand + Metallic Chip + Tier Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bolt, color: badgeColor, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FITFLOW PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),

                  // Tier Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: badgeColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      member.packageTier.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),

              // EMV Chip + Contactless Symbol
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200, width: 1),
                    ),
                    child: Center(
                      child: Icon(Icons.grid_on, size: 18, color: Colors.amber.shade900),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.wifi, color: Colors.white.withOpacity(0.5), size: 20),
                ],
              ),

              // Bottom Details: Member Name & Expiry Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${member.id} • ${member.email}',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'REMAINING',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      Text(
                        '$remainingDays Days',
                        style: TextStyle(
                          color: remainingDays <= 7 ? Colors.redAccent : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Back Side of Card (Barcode & Pass Details)
  Widget _buildCardBack(BuildContext context, Member member, ThemeData theme) {
    return Container(
      key: const ValueKey('CardBack'),
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Black Magnetic Strip
          Container(
            height: 36,
            width: double.infinity,
            color: Colors.black,
          ),

          // Barcode Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.document_scanner, color: Colors.black87),
                Text(
                  member.qrCode,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status: ${member.status}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('FitFlow Official Pass', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context, WidgetRef ref, Member member) {
    final subscriptionsAsync = ref.read(subscriptionsStreamProvider);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14151F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upgrade Membership Tier', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 2),
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
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary.withOpacity(0.15) : const Color(0xFF1E1F2C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.white.withOpacity(0.06),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(tier.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        if (isSelected) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('\$${tier.price.toStringAsFixed(2)} / month', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Text(tier.features.join(' • '), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
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
                                  backgroundColor: isSelected ? Colors.grey.shade800 : theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(isSelected ? 'Current' : 'Select'),
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
