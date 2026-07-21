import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';

class DietChartView extends ConsumerStatefulWidget {
  const DietChartView({Key? key}) : super(key: key);

  @override
  ConsumerState<DietChartView> createState() => _DietChartViewState();
}

class _DietChartViewState extends ConsumerState<DietChartView> {
  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF242533);
    const activeOrange = Color(0xFFFF5500);
    final dietPlansAsync = ref.watch(dietPlansStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Diet Chart & Nutrition Manager', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Manage nutritional meal charts for Men, Women, and Children in Firestore', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddDietPlanDialog,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Add Meal Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          dietPlansAsync.when(
            data: (plans) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.25,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: activeOrange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(plan.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: activeOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text(plan.targetCategory.toUpperCase(), style: const TextStyle(color: activeOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${plan.caloriesDaily} kcal/day', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('P: ${plan.proteinGrams.toStringAsFixed(0)}g • C: ${plan.carbsGrams.toStringAsFixed(0)}g • F: ${plan.fatsGrams.toStringAsFixed(0)}g', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 12),
                        Expanded(child: Text(plan.description, style: TextStyle(color: Colors.grey.shade400, fontSize: 12))),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                            onPressed: () async {
                              await ref.read(dietRepositoryProvider).deleteDietPlan(plan.id);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading diet plans: $err', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDietPlanDialog() {
    final titleCtrl = TextEditingController();
    final calsCtrl = TextEditingController(text: '2400');
    final proteinCtrl = TextEditingController(text: '160');
    final carbsCtrl = TextEditingController(text: '180');
    final fatsCtrl = TextEditingController(text: '60');
    final descCtrl = TextEditingController();
    String category = 'men';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242533),
          title: const Text('Add Nutritional Meal Plan', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Plan Title (e.g. Keto Shred)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF242533),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Target Category'),
                  items: const [
                    DropdownMenuItem(value: 'men', child: Text('Men', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'women', child: Text('Women', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'children', child: Text('Children', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) category = val;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: calsCtrl,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Daily Calories (kcal)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: proteinCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Protein (g)'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: carbsCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carbs (g)'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: fatsCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Fats (g)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Description / Instructions'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isNotEmpty) {
                  final plan = DietPlan(
                    id: '',
                    title: titleCtrl.text.trim(),
                    targetCategory: category,
                    caloriesDaily: int.tryParse(calsCtrl.text) ?? 2000,
                    proteinGrams: double.tryParse(proteinCtrl.text) ?? 150.0,
                    carbsGrams: double.tryParse(carbsCtrl.text) ?? 200.0,
                    fatsGrams: double.tryParse(fatsCtrl.text) ?? 60.0,
                    description: descCtrl.text.trim().isEmpty ? 'Nutritional diet chart.' : descCtrl.text.trim(),
                    meals: const [
                      MealItem(name: 'Oatmeal & Protein Shake', time: 'Breakfast', calories: 500, proteinGrams: 40, carbsGrams: 60, fatsGrams: 10, imageUrl: ''),
                      MealItem(name: 'Chicken Breast & Brown Rice', time: 'Lunch', calories: 650, proteinGrams: 50, carbsGrams: 70, fatsGrams: 12, imageUrl: ''),
                    ],
                  );

                  await ref.read(dietRepositoryProvider).addDietPlan(plan);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Diet Plan'),
            ),
          ],
        );
      },
    );
  }
}
