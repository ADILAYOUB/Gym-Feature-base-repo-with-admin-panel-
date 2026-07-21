import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class AiRepositoryImpl implements AiRepository {
  @override
  Stream<AiRecommendation> getAiRecommendationStream(String userId) {
    return Stream.value(const AiRecommendation(
      title: 'Gemini AI Coach Recommendation',
      recommendationText: 'Based on your 92% readiness score and high HRV (68ms), your muscle fibers are fully restored. We recommend a hypertrophy upper body workout today.',
      suggestedWorkoutTitle: 'Men Upper Body Strength',
      targetCategory: 'men',
      confidenceScore: 0.96,
    ));
  }
}

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<PushNotification>> getNotificationsStream() {
    return _firestore
        .collection('notifications')
        .orderBy('sentTime', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultNotifications();
      }
      return snapshot.docs.map((doc) => PushNotification.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> saveNotification(PushNotification notification) async {
    await sendNotification(notification);
  }

  @override
  Future<void> sendNotification(PushNotification notification) async {
    await _firestore.collection('notifications').add(notification.toJson());
  }

  List<PushNotification> _defaultNotifications() {
    return [
      PushNotification(
        id: 'n1',
        title: '🔥 Don\'t Miss Today\'s Workout!',
        body: 'Your personalized Men Upper Body Strength routine is waiting. Keep up your streak!',
        sentTime: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'workout_reminder',
      ),
      PushNotification(
        id: 'n2',
        title: '🥗 Nutrition Reminder',
        body: 'Don\'t forget to hit your 160g protein target today. Check out the Keto Power Plan!',
        sentTime: DateTime.now().subtract(const Duration(hours: 6)),
        type: 'diet_tip',
      ),
    ];
  }
}
