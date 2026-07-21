class MealItem {
  final String name;
  final String time; // 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final String imageUrl;

  const MealItem({
    required this.name,
    required this.time,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatsGrams': fatsGrams,
      'imageUrl': imageUrl,
    };
  }

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      time: json['time'] ?? 'Breakfast',
      calories: json['calories'] ?? 300,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 20.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 30.0,
      fatsGrams: (json['fatsGrams'] as num?)?.toDouble() ?? 10.0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class DietPlan {
  final String id;
  final String title;
  final String targetCategory; // 'men', 'women', 'children'
  final int caloriesDaily;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final String description;
  final List<MealItem> meals;

  const DietPlan({
    required this.id,
    required this.title,
    required this.targetCategory,
    required this.caloriesDaily,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.description,
    required this.meals,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetCategory': targetCategory,
      'caloriesDaily': caloriesDaily,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatsGrams': fatsGrams,
      'description': description,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }

  factory DietPlan.fromJson(Map<String, dynamic> json, String docId) {
    return DietPlan(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      title: json['title'] ?? '',
      targetCategory: json['targetCategory'] ?? 'men',
      caloriesDaily: json['caloriesDaily'] ?? 2000,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 150.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 200.0,
      fatsGrams: (json['fatsGrams'] as num?)?.toDouble() ?? 60.0,
      description: json['description'] ?? '',
      meals: (json['meals'] as List?)
              ?.map((e) => MealItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class NutritionLog {
  final String id;
  final String userId;
  final DateTime date;
  final int waterIntakeMl;
  final int waterGoalMl;
  final int caloriesConsumed;
  final int calorieGoal;

  const NutritionLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.waterIntakeMl,
    required this.waterGoalMl,
    required this.caloriesConsumed,
    required this.calorieGoal,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'waterIntakeMl': waterIntakeMl,
      'waterGoalMl': waterGoalMl,
      'caloriesConsumed': caloriesConsumed,
      'calorieGoal': calorieGoal,
    };
  }

  factory NutritionLog.fromJson(Map<String, dynamic> json, String docId) {
    return NutritionLog(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      userId: json['userId'] ?? 'user_1',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      waterIntakeMl: json['waterIntakeMl'] ?? 1250,
      waterGoalMl: json['waterGoalMl'] ?? 2500,
      caloriesConsumed: json['caloriesConsumed'] ?? 1650,
      calorieGoal: json['calorieGoal'] ?? 2400,
    );
  }
}

abstract class DietRepository {
  Stream<List<DietPlan>> getDietPlansStream();
  Future<void> addDietPlan(DietPlan plan);
  Future<void> deleteDietPlan(String id);
}

abstract class NutritionLogRepository {
  Stream<NutritionLog> getTodayNutritionLogStream(String userId);
  Future<void> logWaterIntake(String userId, int addedMl);
  Future<void> logMealCalories(String userId, int addedCalories);
}
