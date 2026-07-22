import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';

class NutritionHubView extends ConsumerStatefulWidget {
  const NutritionHubView({Key? key}) : super(key: key);

  @override
  ConsumerState<NutritionHubView> createState() => _NutritionHubViewState();
}

class _NutritionHubViewState extends ConsumerState<NutritionHubView> {
  String _selectedCategory = 'men';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nutritionLogAsync = ref.watch(todayNutritionLogStreamProvider('user_1'));
    final dietPlansAsync = ref.watch(dietPlansStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Macro Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Calorie & Macro Target Card
            nutritionLogAsync.when(
              data: (log) {
                final caloriePercent = (log.caloriesConsumed / log.calorieGoal).clamp(0.0, 1.0);
                final waterPercent = (log.waterIntakeMl / log.waterGoalMl).clamp(0.0, 1.0);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242533),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Radial Progress Ring
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: caloriePercent,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${log.caloriesConsumed}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('/ ${log.calorieGoal} kcal', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),

                          // Macro Breakdown Bars
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMacroBar('Protein', '120g / 160g', 0.75, Colors.greenAccent),
                                const SizedBox(height: 10),
                                _buildMacroBar('Carbs', '180g / 220g', 0.81, Colors.orangeAccent),
                                const SizedBox(height: 10),
                                _buildMacroBar('Fats', '45g / 65g', 0.69, Colors.blueAccent),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),

                      // Interactive Water Hydration Tracker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.water_drop, color: Colors.cyanAccent, size: 28),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Hydration Tracker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${log.waterIntakeMl} / ${log.waterGoalMl} mL (${(waterPercent * 100).toStringAsFixed(0)}%)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(nutritionLogRepositoryProvider).logWaterIntake('user_1', 250);
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('+250 mL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan.withOpacity(0.3),
                              foregroundColor: Colors.cyanAccent,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 24),

            // Gender / Category Filter Tabs (Men, Women, Children)
            Row(
              children: [
                _buildCategoryTab('men', 'Men'),
                const SizedBox(width: 8),
                _buildCategoryTab('women', 'Women'),
                const SizedBox(width: 8),
                _buildCategoryTab('children', 'Children'),
              ],
            ),
            const SizedBox(height: 16),

            // Prescribed Diet Charts Catalog
            Text('Prescribed Diet Plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            dietPlansAsync.when(
              data: (plans) {
                final filtered = plans.where((p) => p.targetCategory == _selectedCategory).toList();
                final displayPlans = filtered.isNotEmpty ? filtered : plans;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayPlans.length,
                  itemBuilder: (context, index) {
                    final plan = displayPlans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    plan.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                  child: Text('${plan.caloriesDaily} kcal', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(plan.description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 12),
                            Text('Macro Split: P ${plan.proteinGrams.toStringAsFixed(0)}g | C ${plan.carbsGrams.toStringAsFixed(0)}g | F ${plan.fatsGrams.toStringAsFixed(0)}g', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            if (plan.meals.isNotEmpty) ...[
                              const Divider(height: 20),
                              ...plan.meals.map((m) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Expanded(
                                           child: Text(
                                             '${m.time}: ${m.name}',
                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ),
                                         const SizedBox(width: 8),
                                         Text('${m.calories} kcal', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                       ],
                                     ),
                                  )),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading diet plans: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : const Color(0xFF242533),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
