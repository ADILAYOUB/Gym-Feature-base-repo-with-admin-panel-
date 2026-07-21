import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';

class CommunityHubView extends ConsumerStatefulWidget {
  const CommunityHubView({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommunityHubView()),
    );
  }

  @override
  ConsumerState<CommunityHubView> createState() => _CommunityHubViewState();
}

class _CommunityHubViewState extends ConsumerState<CommunityHubView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community & Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Leaderboard'),
            Tab(text: 'Challenges'),
            Tab(text: 'Social Feed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardTab(context, ref),
          _buildChallengesTab(context, ref),
          _buildSocialFeedTab(context, ref),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(context, ref),
        icon: const Icon(Icons.share),
        label: const Text('Share Achievement'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardStreamProvider);

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const Center(child: Text('No leaderboard entries yet.'));
        final top3 = entries.take(3).toList();
        final rest = entries.skip(3).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top 3 Podium Visual
              if (top3.length >= 3)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242533),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd Place (Silver)
                      _buildPodiumItem(top3[1], 2, Colors.grey.shade300, 110),
                      // 1st Place (Gold)
                      _buildPodiumItem(top3[0], 1, Colors.amber, 140),
                      // 3rd Place (Bronze)
                      _buildPodiumItem(top3[2], 3, Colors.orangeAccent.shade200, 95),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Full Leaderboard Table
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rest.length,
                itemBuilder: (context, idx) {
                  final entry = rest[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white12,
                        child: Text('#${entry.rank}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      title: Text(entry.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${entry.workoutsCompleted} Workouts • ${entry.badgeTitle}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      trailing: Text('${entry.points} pts', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, int rank, Color crownColor, double height) {
    return Column(
      children: [
        Icon(Icons.emoji_events, color: crownColor, size: rank == 1 ? 32 : 24),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: rank == 1 ? 32 : 26,
          backgroundImage: NetworkImage(entry.avatarUrl.isNotEmpty ? entry.avatarUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200'),
        ),
        const SizedBox(height: 6),
        Text(entry.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        Text('${entry.points} pts', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildChallengesTab(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesStreamProvider);

    return challengesAsync.when(
      data: (challenges) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, idx) {
            final c = challenges[idx];
            final progressPercent = (c.currentAmount / c.targetAmount).clamp(0.0, 1.0);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(c.rewardBadge, style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(c.description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress: ${c.currentAmount} / ${c.targetAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('${c.daysLeft} days left', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref.read(communityRepositoryProvider).toggleChallengeJoin(c.id, !c.isJoined);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.isJoined ? Colors.grey.shade800 : Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(c.isJoined ? 'Joined Challenge ✓' : 'Join Virtual Challenge'),
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
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildSocialFeedTab(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(socialPostsStreamProvider);

    return postsAsync.when(
      data: (posts) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, idx) {
            final post = posts[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(post.authorAvatar.isNotEmpty ? post.authorAvatar : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200'),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(post.postedTimeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF242533), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.orangeAccent),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.workoutTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(post.metricsText, style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(post.caption, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(post.isLikedByMe ? Icons.favorite : Icons.favorite_border, color: post.isLikedByMe ? Colors.redAccent : Colors.grey),
                          onPressed: () async {
                            await ref.read(communityRepositoryProvider).togglePostLike(post.id, post.isLikedByMe, post.likesCount);
                          },
                        ),
                        Text('${post.likesCount} Likes', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    final captionCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: const Text('Share Achievement with Community', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: captionCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Write a caption about your workout accomplishment...'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (captionCtrl.text.isNotEmpty) {
                  final post = SocialPost(
                    id: '',
                    authorName: 'Alex Rivera',
                    authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
                    postedTimeAgo: 'Just now',
                    workoutTitle: 'Personal Record Smashed!',
                    metricsText: '3,800 KG Lifted • 45 Mins',
                    caption: captionCtrl.text.trim(),
                    likesCount: 1,
                    isLikedByMe: true,
                  );
                  await ref.read(communityRepositoryProvider).createSocialPost(post);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Publish Post'),
            ),
          ],
        );
      },
    );
  }
}
