import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
  final FirebaseFirestore? _firestoreOverride;
  final List<PushNotification> _localNotifications = [];
  late final StreamController<List<PushNotification>> _streamController;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<List<PushNotification>>.broadcast();
    _localNotifications.addAll(_defaultNotifications());
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
  Stream<List<PushNotification>> getNotificationsStream() {
    final fs = _firestore;
    if (fs == null) return _localStream();
    try {
      return fs
          .collection('notifications')
          .orderBy('sentTime', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return List<PushNotification>.from(_localNotifications);
        final list = snapshot.docs.map((doc) => PushNotification.fromJson(doc.data(), doc.id)).toList();
        _localNotifications.clear();
        _localNotifications.addAll(list);
        return list;
      }).handleError((_) => List<PushNotification>.from(_localNotifications));
    } catch (_) {
      return _localStream();
    }
  }

  Stream<List<PushNotification>> _localStream() async* {
    yield List<PushNotification>.from(_localNotifications);
    yield* _streamController.stream;
  }

  @override
  Future<void> saveNotification(PushNotification notification) async {
    await sendNotification(notification);
  }

  @override
  Future<void> sendNotification(PushNotification notification) async {
    final newNotif = PushNotification(
      id: notification.id.isEmpty ? 'n-${DateTime.now().millisecondsSinceEpoch}' : notification.id,
      title: notification.title,
      body: notification.body,
      sentTime: notification.sentTime,
      type: notification.type,
    );

    _localNotifications.insert(0, newNotif);
    _streamController.add(List<PushNotification>.from(_localNotifications));

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('notifications').add(newNotif.toJson());
      } catch (_) {}
    }
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
