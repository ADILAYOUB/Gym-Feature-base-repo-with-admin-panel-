class AiRecommendation {
  final String title;
  final String recommendationText;
  final String suggestedWorkoutTitle;
  final String targetCategory;
  final double confidenceScore;

  const AiRecommendation({
    required this.title,
    required this.recommendationText,
    required this.suggestedWorkoutTitle,
    required this.targetCategory,
    required this.confidenceScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'recommendationText': recommendationText,
      'suggestedWorkoutTitle': suggestedWorkoutTitle,
      'targetCategory': targetCategory,
      'confidenceScore': confidenceScore,
    };
  }

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      title: json['title'] ?? 'AI Smart Coach Recommendation',
      recommendationText: json['recommendationText'] ?? 'Your recovery score is optimal today (92%). We recommend an intermediate upper body strength session.',
      suggestedWorkoutTitle: json['suggestedWorkoutTitle'] ?? 'Men Upper Body Strength',
      targetCategory: json['targetCategory'] ?? 'men',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.94,
    );
  }
}

class PushNotification {
  final String id;
  final String title;
  final String body;
  final DateTime sentTime;
  final String type; // 'workout_reminder', 'diet_tip', 'subscription_expiry', 'pr_celebration'

  const PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.sentTime,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'sentTime': sentTime.toIso8601String(),
      'type': type,
    };
  }

  factory PushNotification.fromJson(Map<String, dynamic> json, String docId) {
    return PushNotification(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      sentTime: DateTime.tryParse(json['sentTime'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'workout_reminder',
    );
  }
}

abstract class AiRepository {
  Stream<AiRecommendation> getAiRecommendationStream(String userId);
}

abstract class NotificationRepository {
  Stream<List<PushNotification>> getNotificationsStream();
  Future<void> sendNotification(PushNotification notification);
}
