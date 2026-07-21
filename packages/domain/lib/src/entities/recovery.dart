class RecoveryData {
  final int recoveryScore; // 0-100%
  final int restingHeartRateBpm;
  final int hrvMs;
  final double sleepHours;
  final String readinessStatus; // 'Optimal Recovery', 'Moderate Fatigue', 'Rest Recommended'

  const RecoveryData({
    required this.recoveryScore,
    required this.restingHeartRateBpm,
    required this.hrvMs,
    required this.sleepHours,
    required this.readinessStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'recoveryScore': recoveryScore,
      'restingHeartRateBpm': restingHeartRateBpm,
      'hrvMs': hrvMs,
      'sleepHours': sleepHours,
      'readinessStatus': readinessStatus,
    };
  }

  factory RecoveryData.fromJson(Map<String, dynamic> json) {
    return RecoveryData(
      recoveryScore: json['recoveryScore'] ?? 92,
      restingHeartRateBpm: json['restingHeartRateBpm'] ?? 54,
      hrvMs: json['hrvMs'] ?? 68,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 7.8,
      readinessStatus: json['readinessStatus'] ?? 'Optimal Recovery',
    );
  }
}

class MeditationSession {
  final String id;
  final String title;
  final int durationMins;
  final String category; // 'Post-Workout Recovery', 'Deep Sleep', 'Mindful Breathing', 'Stress Relief'
  final String audioUrl;
  final String imageUrl;
  final String description;

  const MeditationSession({
    required this.id,
    required this.title,
    required this.durationMins,
    required this.category,
    required this.audioUrl,
    required this.imageUrl,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationMins': durationMins,
      'category': category,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory MeditationSession.fromJson(Map<String, dynamic> json, String docId) {
    return MeditationSession(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      title: json['title'] ?? '',
      durationMins: json['durationMins'] ?? 10,
      category: json['category'] ?? 'Post-Workout Recovery',
      audioUrl: json['audioUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

abstract class RecoveryRepository {
  Stream<RecoveryData> getRecoveryDataStream(String userId);
  Stream<List<MeditationSession>> getMeditationSessionsStream();
  Future<void> syncWearableData(String userId);
  Future<void> addMeditationSession(MeditationSession session);
}
