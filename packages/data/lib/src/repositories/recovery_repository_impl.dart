import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  final FirebaseFirestore? _firestoreOverride;
  late RecoveryData _localData;
  final List<MeditationSession> _localSessions = [];
  late final StreamController<RecoveryData> _dataController;
  late final StreamController<List<MeditationSession>> _sessionController;

  RecoveryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _dataController = StreamController<RecoveryData>.broadcast();
    _sessionController = StreamController<List<MeditationSession>>.broadcast();

    _localData = const RecoveryData(
      recoveryScore: 92,
      restingHeartRateBpm: 54,
      hrvMs: 68,
      sleepHours: 7.8,
      readinessStatus: 'Optimal Recovery',
    );
    _localSessions.addAll(_defaultSessions());
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
  Stream<RecoveryData> getRecoveryDataStream(String userId) {
    final fs = _firestore;
    if (fs == null) return _localDataStream();
    try {
      return fs.collection('recovery').doc(userId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return _localData;
        _localData = RecoveryData.fromJson(doc.data()!);
        return _localData;
      }).handleError((_) => _localData);
    } catch (_) {
      return _localDataStream();
    }
  }

  Stream<RecoveryData> _localDataStream() async* {
    yield _localData;
    yield* _dataController.stream;
  }

  @override
  Stream<List<MeditationSession>> getMeditationSessionsStream() {
    final fs = _firestore;
    if (fs == null) return _localSessionStream();
    try {
      return fs.collection('meditation_sessions').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return List<MeditationSession>.from(_localSessions);
        final list = snapshot.docs.map((doc) => MeditationSession.fromJson(doc.data(), doc.id)).toList();
        _localSessions.clear();
        _localSessions.addAll(list);
        return list;
      }).handleError((_) => List<MeditationSession>.from(_localSessions));
    } catch (_) {
      return _localSessionStream();
    }
  }

  Stream<List<MeditationSession>> _localSessionStream() async* {
    yield List<MeditationSession>.from(_localSessions);
    yield* _sessionController.stream;
  }

  @override
  Future<void> syncWearableData(String userId) async {
    _localData = const RecoveryData(
      recoveryScore: 95,
      restingHeartRateBpm: 52,
      hrvMs: 74,
      sleepHours: 8.2,
      readinessStatus: 'Optimal Recovery (Wearable Synced)',
    );
    _dataController.add(_localData);

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('recovery').doc(userId).set({
          'recoveryScore': 95,
          'restingHeartRateBpm': 52,
          'hrvMs': 74,
          'sleepHours': 8.2,
          'readinessStatus': 'Optimal Recovery (Wearable Synced)',
        });
      } catch (_) {}
    }
  }

  @override
  Future<void> addMeditationSession(MeditationSession session) async {
    final newSession = MeditationSession(
      id: session.id.isEmpty ? 'med-${DateTime.now().millisecondsSinceEpoch}' : session.id,
      title: session.title,
      durationMins: session.durationMins,
      category: session.category,
      audioUrl: session.audioUrl,
      imageUrl: session.imageUrl,
      description: session.description,
    );

    _localSessions.insert(0, newSession);
    _sessionController.add(List<MeditationSession>.from(_localSessions));

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('meditation_sessions').add(newSession.toJson());
      } catch (_) {}
    }
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
