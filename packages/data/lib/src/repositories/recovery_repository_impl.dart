import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  final FirebaseFirestore _firestore;

  RecoveryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<RecoveryData> getRecoveryDataStream(String userId) {
    return _firestore.collection('recovery').doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return const RecoveryData(
          recoveryScore: 92,
          restingHeartRateBpm: 54,
          hrvMs: 68,
          sleepHours: 7.8,
          readinessStatus: 'Optimal Recovery',
        );
      }
      return RecoveryData.fromJson(doc.data()!);
    });
  }

  @override
  Stream<List<MeditationSession>> getMeditationSessionsStream() {
    return _firestore.collection('meditation_sessions').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultSessions();
      }
      return snapshot.docs.map((doc) => MeditationSession.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> syncWearableData(String userId) async {
    await _firestore.collection('recovery').doc(userId).set({
      'recoveryScore': 95,
      'restingHeartRateBpm': 52,
      'hrvMs': 74,
      'sleepHours': 8.2,
      'readinessStatus': 'Optimal Recovery (Wearable Synced)',
    });
  }

  @override
  Future<void> addMeditationSession(MeditationSession session) async {
    await _firestore.collection('meditation_sessions').add(session.toJson());
  }

  List<MeditationSession> _defaultSessions() {
    return const [
      MeditationSession(
        id: 'med1',
        title: 'Post-Workout Muscle De-stress',
        durationMins: 10,
        category: 'Post-Workout Recovery',
        audioUrl: 'https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600',
        description: 'Guided breathwork to decrease cortisol and lower heart rate after heavy lifting.',
      ),
      MeditationSession(
        id: 'med2',
        title: 'Deep REM Sleep Regeneration',
        durationMins: 15,
        category: 'Deep Sleep',
        audioUrl: 'https://assets.mixkit.co/music/preview/mixkit-sleepy-cat-135.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1511295742362-92c96b124e52?q=80&w=600',
        description: 'Delta wave soundscape designed for full muscular repair and cellular regeneration.',
      ),
    ];
  }
}
