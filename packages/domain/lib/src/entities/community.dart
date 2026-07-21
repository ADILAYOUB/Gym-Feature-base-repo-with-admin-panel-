class LeaderboardEntry {
  final int rank;
  final String userName;
  final String avatarUrl;
  final int points;
  final int workoutsCompleted;
  final String badgeTitle;

  const LeaderboardEntry({
    required this.rank,
    required this.userName,
    required this.avatarUrl,
    required this.points,
    required this.workoutsCompleted,
    required this.badgeTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'points': points,
      'workoutsCompleted': workoutsCompleted,
      'badgeTitle': badgeTitle,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 1,
      userName: json['userName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      points: json['points'] ?? 0,
      workoutsCompleted: json['workoutsCompleted'] ?? 0,
      badgeTitle: json['badgeTitle'] ?? 'Gym Veteran',
    );
  }
}

class VirtualChallenge {
  final String id;
  final String title;
  final String description;
  final String targetType; // 'workouts', 'volume', 'steps'
  final int targetAmount;
  final int currentAmount;
  final int daysLeft;
  final String imageUrl;
  final int participantsCount;
  final String rewardBadge;
  final bool isJoined;

  const VirtualChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetAmount,
    required this.currentAmount,
    required this.daysLeft,
    required this.imageUrl,
    required this.participantsCount,
    required this.rewardBadge,
    this.isJoined = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetType': targetType,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'daysLeft': daysLeft,
      'imageUrl': imageUrl,
      'participantsCount': participantsCount,
      'rewardBadge': rewardBadge,
      'isJoined': isJoined,
    };
  }

  factory VirtualChallenge.fromJson(Map<String, dynamic> json, String docId) {
    return VirtualChallenge(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetType: json['targetType'] ?? 'workouts',
      targetAmount: json['targetAmount'] ?? 20,
      currentAmount: json['currentAmount'] ?? 12,
      daysLeft: json['daysLeft'] ?? 14,
      imageUrl: json['imageUrl'] ?? '',
      participantsCount: json['participantsCount'] ?? 85,
      rewardBadge: json['rewardBadge'] ?? 'Iron Titan',
      isJoined: json['isJoined'] ?? false,
    );
  }
}

class SocialPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String postedTimeAgo;
  final String workoutTitle;
  final String metricsText;
  final String caption;
  final int likesCount;
  final bool isLikedByMe;

  const SocialPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.postedTimeAgo,
    required this.workoutTitle,
    required this.metricsText,
    required this.caption,
    required this.likesCount,
    this.isLikedByMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'postedTimeAgo': postedTimeAgo,
      'workoutTitle': workoutTitle,
      'metricsText': metricsText,
      'caption': caption,
      'likesCount': likesCount,
      'isLikedByMe': isLikedByMe,
    };
  }

  factory SocialPost.fromJson(Map<String, dynamic> json, String docId) {
    return SocialPost(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      authorName: json['authorName'] ?? 'Member',
      authorAvatar: json['authorAvatar'] ?? '',
      postedTimeAgo: json['postedTimeAgo'] ?? '2h ago',
      workoutTitle: json['workoutTitle'] ?? 'Upper Body Strength',
      metricsText: json['metricsText'] ?? '3,450 KG • 45 Mins',
      caption: json['caption'] ?? 'New Personal Record today! 🔥',
      likesCount: json['likesCount'] ?? 24,
      isLikedByMe: json['isLikedByMe'] ?? false,
    );
  }
}

abstract class CommunityRepository {
  Stream<List<LeaderboardEntry>> getLeaderboardStream();
  Stream<List<VirtualChallenge>> getChallengesStream();
  Stream<List<SocialPost>> getSocialPostsStream();
  Future<void> addChallenge(VirtualChallenge challenge);
  Future<void> toggleChallengeJoin(String challengeId, bool join);
  Future<void> togglePostLike(String postId, bool isLiked, int currentLikes);
  Future<void> createSocialPost(SocialPost post);
}
