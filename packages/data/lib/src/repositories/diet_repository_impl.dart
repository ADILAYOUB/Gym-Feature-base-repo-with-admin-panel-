import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class DietRepositoryImpl implements DietRepository {
  final FirebaseFirestore _firestore;

  DietRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<DietPlan>> getDietPlansStream() {
    return _firestore.collection('diet_plans').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultDietPlans();
      }
      return snapshot.docs.map((doc) => DietPlan.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addDietPlan(DietPlan plan) async {
    await _firestore.collection('diet_plans').add(plan.toJson());
  }

  @override
  Future<void> deleteDietPlan(String id) async {
    await _firestore.collection('diet_plans').doc(id).delete();
  }

  List<DietPlan> _defaultDietPlans() {
    return const [
      DietPlan(
        id: 'diet1',
        title: 'Keto Power Plan',
        targetCategory: 'men',
        caloriesDaily: 2400,
        proteinGrams: 160.0,
        carbsGrams: 30.0,
        fatsGrams: 180.0,
        description: 'High fats, adequate protein, ultra-low carb feed for maximum fat burning.',
        meals: [
          MealItem(name: 'Avocado & Scrambled Eggs', time: 'Breakfast', calories: 600, proteinGrams: 35.0, carbsGrams: 6.0, fatsGrams: 48.0, imageUrl: ''),
          MealItem(name: 'Grilled Salmon & Asparagus', time: 'Lunch', calories: 750, proteinGrams: 55.0, carbsGrams: 8.0, fatsGrams: 52.0, imageUrl: ''),
        ],
      ),
      DietPlan(
        id: 'diet2',
        title: 'Clean Lean Muscle Gain',
        targetCategory: 'women',
        caloriesDaily: 2100,
        proteinGrams: 140.0,
        carbsGrams: 210.0,
        fatsGrams: 50.0,
        description: 'Clean high protein surplus diet for lean muscle hypertrophy and energy.',
        meals: [
          MealItem(name: 'Oatmeal & Protein Shake', time: 'Breakfast', calories: 500, proteinGrams: 40.0, carbsGrams: 65.0, fatsGrams: 10.0, imageUrl: ''),
          MealItem(name: 'Chicken Breast & Sweet Potato', time: 'Lunch', calories: 650, proteinGrams: 50.0, carbsGrams: 70.0, fatsGrams: 12.0, imageUrl: ''),
        ],
      ),
      DietPlan(
        id: 'diet3',
        title: 'Youth Active Growth Diet',
        targetCategory: 'children',
        caloriesDaily: 1800,
        proteinGrams: 80.0,
        carbsGrams: 230.0,
        fatsGrams: 45.0,
        description: 'Balanced calcium and protein rich diet for growing young athletes.',
        meals: [
          MealItem(name: 'Whole Grain Pancakes & Berry Smoothie', time: 'Breakfast', calories: 450, proteinGrams: 18.0, carbsGrams: 70.0, fatsGrams: 10.0, imageUrl: ''),
        ],
      ),
    ];
  }
}

class NutritionLogRepositoryImpl implements NutritionLogRepository {
  final FirebaseFirestore _firestore;

  NutritionLogRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<NutritionLog> getTodayNutritionLogStream(String userId) {
    return _firestore
        .collection('nutrition_logs')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return NutritionLog(
          id: userId,
          userId: userId,
          date: DateTime.now(),
          waterIntakeMl: 1250,
          waterGoalMl: 2500,
          caloriesConsumed: 1650,
          calorieGoal: 2400,
        );
      }
      return NutritionLog.fromJson(doc.data()!, doc.id);
    });
  }

  @override
  Future<void> logWaterIntake(String userId, int addedMl) async {
    final ref = _firestore.collection('nutrition_logs').doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          'id': userId,
          'userId': userId,
          'date': DateTime.now().toIso8601String(),
          'waterIntakeMl': addedMl,
          'waterGoalMl': 2500,
          'caloriesConsumed': 1650,
          'calorieGoal': 2400,
        });
      } else {
        final current = (snap.data()?['waterIntakeMl'] as num?)?.toInt() ?? 1250;
        tx.update(ref, {'waterIntakeMl': current + addedMl});
      }
    });
  }

  @override
  Future<void> logMealCalories(String userId, int addedCalories) async {
    final ref = _firestore.collection('nutrition_logs').doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          'id': userId,
          'userId': userId,
          'date': DateTime.now().toIso8601String(),
          'waterIntakeMl': 1250,
          'waterGoalMl': 2500,
          'caloriesConsumed': addedCalories,
          'calorieGoal': 2400,
        });
      } else {
        final current = (snap.data()?['caloriesConsumed'] as num?)?.toInt() ?? 1650;
        tx.update(ref, {'caloriesConsumed': current + addedCalories});
      }
    });
  }
}
