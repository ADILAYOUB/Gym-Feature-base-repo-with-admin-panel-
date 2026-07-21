import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<LeaderboardEntry>> getLeaderboardStream() {
    return _firestore
        .collection('leaderboard')
        .orderBy('points', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultLeaderboard();
      }
      return snapshot.docs.map((doc) => LeaderboardEntry.fromJson(doc.data())).toList();
    });
  }

  @override
  Stream<List<VirtualChallenge>> getChallengesStream() {
    return _firestore.collection('challenges').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultChallenges();
      }
      return snapshot.docs.map((doc) => VirtualChallenge.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<SocialPost>> getSocialPostsStream() {
    return _firestore.collection('social_posts').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultPosts();
      }
      return snapshot.docs.map((doc) => SocialPost.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addChallenge(VirtualChallenge challenge) async {
    await _firestore.collection('challenges').add(challenge.toJson());
  }

  @override
  Future<void> toggleChallengeJoin(String challengeId, bool join) async {
    await _firestore.collection('challenges').doc(challengeId).update({'isJoined': join});
  }

  @override
  Future<void> togglePostLike(String postId, bool isLiked, int currentLikes) async {
    final nextCount = isLiked ? currentLikes - 1 : currentLikes + 1;
    await _firestore.collection('social_posts').doc(postId).update({
      'isLikedByMe': !isLiked,
      'likesCount': nextCount > 0 ? nextCount : 0,
    });
  }

  @override
  Future<void> createSocialPost(SocialPost post) async {
    await _firestore.collection('social_posts').add(post.toJson());
  }

  List<LeaderboardEntry> _defaultLeaderboard() {
    return const [
      LeaderboardEntry(rank: 1, userName: 'Alex Rivera', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200', points: 3450, workoutsCompleted: 28, badgeTitle: '🏆 Gym Champion'),
      LeaderboardEntry(rank: 2, userName: 'Sophia Chen', avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200', points: 3100, workoutsCompleted: 24, badgeTitle: '🥈 Iron Legend'),
      LeaderboardEntry(rank: 3, userName: 'Marcus Vance', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200', points: 2890, workoutsCompleted: 22, badgeTitle: '🥉 Power Master'),
      LeaderboardEntry(rank: 4, userName: 'Emma Watson', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200', points: 2450, workoutsCompleted: 19, badgeTitle: 'Fitness Beast'),
      LeaderboardEntry(rank: 5, userName: 'David Miller', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200', points: 2100, workoutsCompleted: 16, badgeTitle: 'Cardio Titan'),
    ];
  }

  List<VirtualChallenge> _defaultChallenges() {
    return const [
      VirtualChallenge(
        id: 'c1',
        title: '30-Day New Year Hypertrophy',
        description: 'Complete 25 strength routines this month to earn the exclusive Gold Titan Badge!',
        targetType: 'workouts',
        targetAmount: 25,
        currentAmount: 18,
        daysLeft: 12,
        imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600',
        participantsCount: 142,
        rewardBadge: 'Gold Titan 🏅',
        isJoined: true,
      ),
      VirtualChallenge(
        id: 'c2',
        title: '100,000 KG Heavy Volume Club',
        description: 'Accumulate 100,000 KG total volume lifted in your active workout tracking mode.',
        targetType: 'volume',
        targetAmount: 100000,
        currentAmount: 48500,
        daysLeft: 20,
        imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600',
        participantsCount: 98,
        rewardBadge: 'Iron Lifter 🏋️‍♂️',
        isJoined: false,
      ),
    ];
  }

  List<SocialPost> _defaultPosts() {
    return const [
      SocialPost(
        id: 'p1',
        authorName: 'Alex Rivera',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
        postedTimeAgo: '1h ago',
        workoutTitle: 'Men Upper Body Strength',
        metricsText: '4,200 KG Lifted • 48 Mins • 480 kcal',
        caption: 'Crushed a new Personal Record on Dumbbell Press! 30kg x 12 reps! 💪🔥',
        likesCount: 38,
        isLikedByMe: true,
      ),
      SocialPost(
        id: 'p2',
        authorName: 'Sophia Chen',
        authorAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200',
        postedTimeAgo: '3h ago',
        workoutTitle: 'Women Toned Core & Glutes',
        metricsText: '2,100 KG Lifted • 35 Mins • 320 kcal',
        caption: 'Glute bridge burnout session complete! Hydration on point today 💦',
        likesCount: 29,
        isLikedByMe: false,
      ),
    ];
  }
}
