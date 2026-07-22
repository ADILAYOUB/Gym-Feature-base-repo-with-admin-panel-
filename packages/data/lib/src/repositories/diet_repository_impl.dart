import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class DietRepositoryImpl implements DietRepository {
  final FirebaseFirestore? _firestoreOverride;
  final List<DietPlan> _localDietPlans = [];
  late final StreamController<List<DietPlan>> _streamController;

  DietRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<List<DietPlan>>.broadcast();
    _localDietPlans.addAll(_defaultDietPlans());
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
  Stream<List<DietPlan>> getDietPlansStream() {
    final fs = _firestore;
    if (fs == null) {
      return _localStream();
    }
    try {
      return fs.collection('diet_plans').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return List<DietPlan>.from(_localDietPlans);
        }
        final list = snapshot.docs.map((doc) => DietPlan.fromJson(doc.data(), doc.id)).toList();
        _localDietPlans.clear();
        _localDietPlans.addAll(list);
        return list;
      }).handleError((_) => List<DietPlan>.from(_localDietPlans));
    } catch (_) {
      return _localStream();
    }
  }

  Stream<List<DietPlan>> _localStream() async* {
    yield List<DietPlan>.from(_localDietPlans);
    yield* _streamController.stream;
  }

  void _notify() {
    if (!_streamController.isClosed) {
      _streamController.add(List<DietPlan>.from(_localDietPlans));
    }
  }

  @override
  Future<void> addDietPlan(DietPlan plan) async {
    final newPlan = DietPlan(
      id: plan.id.isEmpty ? 'diet-${DateTime.now().millisecondsSinceEpoch}' : plan.id,
      title: plan.title,
      targetCategory: plan.targetCategory,
      caloriesDaily: plan.caloriesDaily,
      proteinGrams: plan.proteinGrams,
      carbsGrams: plan.carbsGrams,
      fatsGrams: plan.fatsGrams,
      description: plan.description,
      meals: plan.meals,
    );

    _localDietPlans.insert(0, newPlan);
    _notify();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('diet_plans').add(newPlan.toJson());
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteDietPlan(String id) async {
    _localDietPlans.removeWhere((d) => d.id == id);
    _notify();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('diet_plans').doc(id).delete();
      } catch (_) {}
    }
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
  final FirebaseFirestore? _firestoreOverride;
  late NutritionLog _localLog;
  late final StreamController<NutritionLog> _streamController;

  NutritionLogRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<NutritionLog>.broadcast();
    _localLog = NutritionLog(
      id: 'default',
      userId: 'default',
      date: DateTime.now(),
      waterIntakeMl: 1250,
      waterGoalMl: 2500,
      caloriesConsumed: 1650,
      calorieGoal: 2400,
    );
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
  Stream<NutritionLog> getTodayNutritionLogStream(String userId) {
    final fs = _firestore;
    if (fs == null) {
      return _localStream();
    }
    try {
      return fs
          .collection('nutrition_logs')
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (!doc.exists || doc.data() == null) {
          return _localLog;
        }
        return NutritionLog.fromJson(doc.data()!, doc.id);
      }).handleError((_) => _localLog);
    } catch (_) {
      return _localStream();
    }
  }

  Stream<NutritionLog> _localStream() async* {
    yield _localLog;
    yield* _streamController.stream;
  }

  @override
  Future<void> logWaterIntake(String userId, int addedMl) async {
    _localLog = NutritionLog(
      id: _localLog.id,
      userId: userId,
      date: DateTime.now(),
      waterIntakeMl: _localLog.waterIntakeMl + addedMl,
      waterGoalMl: _localLog.waterGoalMl,
      caloriesConsumed: _localLog.caloriesConsumed,
      calorieGoal: _localLog.calorieGoal,
    );
    _streamController.add(_localLog);

    final fs = _firestore;
    if (fs != null) {
      try {
        final ref = fs.collection('nutrition_logs').doc(userId);
        await fs.runTransaction((tx) async {
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
      } catch (_) {}
    }
  }

  @override
  Future<void> logMealCalories(String userId, int addedCalories) async {
    _localLog = NutritionLog(
      id: _localLog.id,
      userId: userId,
      date: DateTime.now(),
      waterIntakeMl: _localLog.waterIntakeMl,
      waterGoalMl: _localLog.waterGoalMl,
      caloriesConsumed: _localLog.caloriesConsumed + addedCalories,
      calorieGoal: _localLog.calorieGoal,
    );
    _streamController.add(_localLog);

    final fs = _firestore;
    if (fs != null) {
      try {
        final ref = fs.collection('nutrition_logs').doc(userId);
        await fs.runTransaction((tx) async {
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
      } catch (_) {}
    }
  }
}
