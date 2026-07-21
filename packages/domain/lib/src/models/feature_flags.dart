import 'package:equatable/equatable.dart';

class FeatureFlags extends Equatable {
  final bool enableLeaderboard;
  final bool enableDietPlans;
  final bool enableChildrenMode;
  final bool enableAiRecommendations;

  const FeatureFlags({
    required this.enableLeaderboard,
    required this.enableDietPlans,
    required this.enableChildrenMode,
    this.enableAiRecommendations = true,
  });

  factory FeatureFlags.fromMap(Map<String, dynamic> map) {
    return FeatureFlags(
      enableLeaderboard: map['enable_leaderboard'] ?? true,
      enableDietPlans: map['enable_diet_plans'] ?? false,
      enableChildrenMode: map['enable_children_mode'] ?? true,
      enableAiRecommendations: map['enable_ai_recommendations'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enable_leaderboard': enableLeaderboard,
      'enable_diet_plans': enableDietPlans,
      'enable_children_mode': enableChildrenMode,
      'enable_ai_recommendations': enableAiRecommendations,
    };
  }

  factory FeatureFlags.fallback() {
    return const FeatureFlags(
      enableLeaderboard: true,
      enableDietPlans: true,
      enableChildrenMode: true,
      enableAiRecommendations: true,
    );
  }

  FeatureFlags copyWith({
    bool? enableLeaderboard,
    bool? enableDietPlans,
    bool? enableChildrenMode,
    bool? enableAiRecommendations,
  }) {
    return FeatureFlags(
      enableLeaderboard: enableLeaderboard ?? this.enableLeaderboard,
      enableDietPlans: enableDietPlans ?? this.enableDietPlans,
      enableChildrenMode: enableChildrenMode ?? this.enableChildrenMode,
      enableAiRecommendations: enableAiRecommendations ?? this.enableAiRecommendations,
    );
  }

  @override
  List<Object?> get props => [
        enableLeaderboard,
        enableDietPlans,
        enableChildrenMode,
        enableAiRecommendations,
      ];
}
