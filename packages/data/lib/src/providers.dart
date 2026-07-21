import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import './repositories/config_repository_impl.dart';
import './repositories/workout_repository_impl.dart';
import './repositories/member_repository_impl.dart';
import './repositories/workout_log_repository_impl.dart';
import './repositories/diet_repository_impl.dart';
import './repositories/trainer_repository_impl.dart';
import './repositories/community_repository_impl.dart';
import './repositories/recovery_repository_impl.dart';
import './repositories/ai_notification_repository_impl.dart';

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl();
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl();
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepositoryImpl();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl();
});

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return WorkoutLogRepositoryImpl();
});

final dietRepositoryProvider = Provider<DietRepository>((ref) {
  return DietRepositoryImpl();
});

final nutritionLogRepositoryProvider = Provider<NutritionLogRepository>((ref) {
  return NutritionLogRepositoryImpl();
});

final trainerRepositoryProvider = Provider<TrainerRepository>((ref) {
  return TrainerRepositoryImpl();
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl();
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl();
});

final recoveryRepositoryProvider = Provider<RecoveryRepository>((ref) {
  return RecoveryRepositoryImpl();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

final themeConfigProvider = StreamProvider<ThemeConfig>((ref) {
  return ref.watch(configRepositoryProvider).watchThemeConfig();
});

final featureFlagsProvider = StreamProvider<FeatureFlags>((ref) {
  return ref.watch(configRepositoryProvider).watchFeatureFlags();
});

final layoutSectionsProvider = StreamProvider<List<LayoutSection>>((ref) {
  return ref.watch(configRepositoryProvider).watchLayoutSections();
});

final membersStreamProvider = StreamProvider<List<Member>>((ref) {
  return ref.watch(memberRepositoryProvider).getMembersStream();
});

final subscriptionsStreamProvider = StreamProvider<List<SubscriptionTier>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).getSubscriptionsStream();
});

final workoutsStreamProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutRepositoryProvider).getWorkoutsStream();
});

final exercisesStreamProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(workoutRepositoryProvider).getExercisesStream();
});

final workoutLogsStreamProvider = StreamProvider<List<WorkoutLog>>((ref) {
  return ref.watch(workoutLogRepositoryProvider).getWorkoutLogsStream();
});

final dietPlansStreamProvider = StreamProvider<List<DietPlan>>((ref) {
  return ref.watch(dietRepositoryProvider).getDietPlansStream();
});

final todayNutritionLogStreamProvider = StreamProvider.family<NutritionLog, String>((ref, userId) {
  return ref.watch(nutritionLogRepositoryProvider).getTodayNutritionLogStream(userId);
});

final trainersStreamProvider = StreamProvider<List<Trainer>>((ref) {
  return ref.watch(trainerRepositoryProvider).getTrainersStream();
});

final userBookingsStreamProvider = StreamProvider.family<List<ClassBooking>, String>((ref, userId) {
  return ref.watch(bookingRepositoryProvider).getUserBookingsStream(userId);
});

final leaderboardStreamProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  return ref.watch(communityRepositoryProvider).getLeaderboardStream();
});

final challengesStreamProvider = StreamProvider<List<VirtualChallenge>>((ref) {
  return ref.watch(communityRepositoryProvider).getChallengesStream();
});

final socialPostsStreamProvider = StreamProvider<List<SocialPost>>((ref) {
  return ref.watch(communityRepositoryProvider).getSocialPostsStream();
});

final recoveryDataStreamProvider = StreamProvider.family<RecoveryData, String>((ref, userId) {
  return ref.watch(recoveryRepositoryProvider).getRecoveryDataStream(userId);
});

final meditationSessionsStreamProvider = StreamProvider<List<MeditationSession>>((ref) {
  return ref.watch(recoveryRepositoryProvider).getMeditationSessionsStream();
});

final aiRecommendationStreamProvider = StreamProvider.family<AiRecommendation, String>((ref, userId) {
  return ref.watch(aiRepositoryProvider).getAiRecommendationStream(userId);
});

final notificationsStreamProvider = StreamProvider<List<PushNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).getNotificationsStream();
});
