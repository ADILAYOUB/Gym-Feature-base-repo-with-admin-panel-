import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final FirebaseFirestore? _firestoreOverride;
  final List<LeaderboardEntry> _localLeaderboard = [];
  final List<VirtualChallenge> _localChallenges = [];
  final List<SocialPost> _localPosts = [];

  late final StreamController<List<LeaderboardEntry>> _leaderboardController;
  late final StreamController<List<VirtualChallenge>> _challengeController;
  late final StreamController<List<SocialPost>> _postController;

  CommunityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _leaderboardController = StreamController<List<LeaderboardEntry>>.broadcast();
    _challengeController = StreamController<List<VirtualChallenge>>.broadcast();
    _postController = StreamController<List<SocialPost>>.broadcast();

    _localLeaderboard.addAll(_defaultLeaderboard());
    _localChallenges.addAll(_defaultChallenges());
    _localPosts.addAll(_defaultPosts());
  }

  FirebaseFirestore? get _firestore {
    if (_firestoreOverride != null) return _firestoreOverride;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  @override
  Stream<List<LeaderboardEntry>> getLeaderboardStream() {
    final fs = _firestore;
    if (fs == null) return _localLeaderboardStream();
    try {
      return fs
          .collection('leaderboard')
          .orderBy('points', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return List<LeaderboardEntry>.from(_localLeaderboard);
        final list = snapshot.docs.map((doc) => LeaderboardEntry.fromJson(doc.data())).toList();
        _localLeaderboard.clear();
        _localLeaderboard.addAll(list);
        return list;
      }).handleError((_) => List<LeaderboardEntry>.from(_localLeaderboard));
    } catch (_) {
      return _localLeaderboardStream();
    }
  }

  Stream<List<LeaderboardEntry>> _localLeaderboardStream() async* {
    yield List<LeaderboardEntry>.from(_localLeaderboard);
    yield* _leaderboardController.stream;
  }

  @override
  Stream<List<VirtualChallenge>> getChallengesStream() {
    final fs = _firestore;
    if (fs == null) return _localChallengeStream();
    try {
      return fs.collection('challenges').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return List<VirtualChallenge>.from(_localChallenges);
        final list = snapshot.docs.map((doc) => VirtualChallenge.fromJson(doc.data(), doc.id)).toList();
        _localChallenges.clear();
        _localChallenges.addAll(list);
        return list;
      }).handleError((_) => List<VirtualChallenge>.from(_localChallenges));
    } catch (_) {
      return _localChallengeStream();
    }
  }

  Stream<List<VirtualChallenge>> _localChallengeStream() async* {
    yield List<VirtualChallenge>.from(_localChallenges);
    yield* _challengeController.stream;
  }

  @override
  Stream<List<SocialPost>> getSocialPostsStream() {
    final fs = _firestore;
    if (fs == null) return _localPostStream();
    try {
      return fs.collection('social_posts').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return List<SocialPost>.from(_localPosts);
        final list = snapshot.docs.map((doc) => SocialPost.fromJson(doc.data(), doc.id)).toList();
        _localPosts.clear();
        _localPosts.addAll(list);
        return list;
      }).handleError((_) => List<SocialPost>.from(_localPosts));
    } catch (_) {
      return _localPostStream();
    }
  }

  Stream<List<SocialPost>> _localPostStream() async* {
    yield List<SocialPost>.from(_localPosts);
    yield* _postController.stream;
  }

  @override
  Future<void> addChallenge(VirtualChallenge challenge) async {
    final newChallenge = VirtualChallenge(
      id: challenge.id.isEmpty ? 'c-${DateTime.now().millisecondsSinceEpoch}' : challenge.id,
      title: challenge.title,
      description: challenge.description,
      targetType: challenge.targetType,
      targetAmount: challenge.targetAmount,
      currentAmount: challenge.currentAmount,
      daysLeft: challenge.daysLeft,
      imageUrl: challenge.imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600' : challenge.imageUrl,
      participantsCount: challenge.participantsCount,
      rewardBadge: challenge.rewardBadge,
      isJoined: challenge.isJoined,
    );

    _localChallenges.insert(0, newChallenge);
    _challengeController.add(List<VirtualChallenge>.from(_localChallenges));

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('challenges').add(newChallenge.toJson());
      } catch (_) {}
    }
  }

  @override
  Future<void> toggleChallengeJoin(String challengeId, bool join) async {
    final idx = _localChallenges.indexWhere((c) => c.id == challengeId);
    if (idx != -1) {
      final old = _localChallenges[idx];
      _localChallenges[idx] = VirtualChallenge(
        id: old.id,
        title: old.title,
        description: old.description,
        targetType: old.targetType,
        targetAmount: old.targetAmount,
        currentAmount: old.currentAmount,
        daysLeft: old.daysLeft,
        imageUrl: old.imageUrl,
        participantsCount: join ? old.participantsCount + 1 : old.participantsCount - 1,
        rewardBadge: old.rewardBadge,
        isJoined: join,
      );
      _challengeController.add(List<VirtualChallenge>.from(_localChallenges));
    }

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('challenges').doc(challengeId).update({'isJoined': join});
      } catch (_) {}
    }
  }

  @override
  Future<void> togglePostLike(String postId, bool isLiked, int currentLikes) async {
    final idx = _localPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final old = _localPosts[idx];
      final nextCount = isLiked ? currentLikes - 1 : currentLikes + 1;
      _localPosts[idx] = SocialPost(
        id: old.id,
        authorName: old.authorName,
        authorAvatar: old.authorAvatar,
        postedTimeAgo: old.postedTimeAgo,
        workoutTitle: old.workoutTitle,
        metricsText: old.metricsText,
        caption: old.caption,
        likesCount: nextCount > 0 ? nextCount : 0,
        isLikedByMe: !isLiked,
      );
      _postController.add(List<SocialPost>.from(_localPosts));
    }

    final fs = _firestore;
    if (fs != null) {
      try {
        final nextCount = isLiked ? currentLikes - 1 : currentLikes + 1;
        await fs.collection('social_posts').doc(postId).update({
          'isLikedByMe': !isLiked,
          'likesCount': nextCount > 0 ? nextCount : 0,
        });
      } catch (_) {}
    }
  }

  @override
  Future<void> createSocialPost(SocialPost post) async {
    final newPost = SocialPost(
      id: post.id.isEmpty ? 'p-${DateTime.now().millisecondsSinceEpoch}' : post.id,
      authorName: post.authorName,
      authorAvatar: post.authorAvatar,
      postedTimeAgo: 'Just now',
      workoutTitle: post.workoutTitle,
      metricsText: post.metricsText,
      caption: post.caption,
      likesCount: post.likesCount,
      isLikedByMe: post.isLikedByMe,
    );

    _localPosts.insert(0, newPost);
    _postController.add(List<SocialPost>.from(_localPosts));

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('social_posts').add(newPost.toJson());
      } catch (_) {}
    }
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
        participantsCount: 89,
        rewardBadge: 'Heavy Metal 🏋️‍♂️',
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
        postedTimeAgo: '2 hours ago',
        workoutTitle: 'Men Upper Body Strength',
        metricsText: '45 Mins • 3,450 KG • 420 Kcal',
        caption: 'Hit a new PR today on Deadlifts! 220KG for 3 smooth reps. Hard work in FitFlow routine paying off! 🔥💪',
        likesCount: 34,
        isLikedByMe: true,
      ),
      SocialPost(
        id: 'p2',
        authorName: 'Sophia Chen',
        authorAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200',
        postedTimeAgo: '5 hours ago',
        workoutTitle: 'Women Toned Core & Glutes',
        metricsText: '35 Mins • 1,800 KG • 310 Kcal',
        caption: 'Morning HIIT session completed! 45 Mins of non-stop cardio energy. Loved the recovery smoothie afterwards! 🥤✨',
        likesCount: 52,
        isLikedByMe: false,
      ),
    ];
  }
}
