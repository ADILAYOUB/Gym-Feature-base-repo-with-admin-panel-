import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  // Theme controllers
  final _primaryController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _radiusController = TextEditingController();
  String _selectedFont = 'Outfit';

  // Workout Manager controllers
  final _workoutTitleController = TextEditingController();
  final _workoutDurationController = TextEditingController();
  final _workoutImageController = TextEditingController();
  final _workoutExercisesController = TextEditingController();
  String _workoutCategory = 'men';
  String _workoutDifficulty = 'beginner';

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _backgroundController.dispose();
    _surfaceController.dispose();
    _radiusController.dispose();
    _workoutTitleController.dispose();
    _workoutDurationController.dispose();
    _workoutImageController.dispose();
    _workoutExercisesController.dispose();
    super.dispose();
  }

  void _initializeControllers(ThemeConfig config) {
    if (_primaryController.text.isEmpty) {
      _primaryController.text = config.primaryColor;
      _secondaryController.text = config.secondaryColor;
      _backgroundController.text = config.backgroundColor;
      _surfaceController.text = config.surfaceColor;
      _radiusController.text = config.borderRadius.toString();
      _selectedFont = config.fontFamily;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeConfigAsync = ref.watch(themeConfigProvider);
    final featuresAsync = ref.watch(featureFlagsProvider);
    final layoutAsync = ref.watch(layoutSectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Theme & Design Customizer
              themeConfigAsync.when(
                data: (config) {
                  _initializeControllers(config);
                  return _buildThemeSection(config);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading theme config: $err'),
              ),
              const SizedBox(height: 24),

              // 2. Feature Toggles
              featuresAsync.when(
                data: (flags) => _buildFeaturesSection(flags),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading feature flags: $err'),
              ),
              const SizedBox(height: 24),

              // 3. Layout Reorderable List
              layoutAsync.when(
                data: (sections) => _buildLayoutSection(sections),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading layout: $err'),
              ),
              const SizedBox(height: 24),

              // 4. Exercise & Workout Content Manager
              _buildWorkoutManagerSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Theme Configuration Card
  Widget _buildThemeSection(ThemeConfig currentConfig) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Design System', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildColorField('Primary Color', _primaryController),
            const SizedBox(height: 8),
            _buildColorField('Secondary Color', _secondaryController),
            const SizedBox(height: 8),
            _buildColorField('Background Color', _backgroundController),
            const SizedBox(height: 8),
            _buildColorField('Card Surface Color', _surfaceController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFont,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Font Family'),
                    items: const [
                      DropdownMenuItem(value: 'Outfit', child: Text('Outfit', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Inter', child: Text('Inter', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Teko', child: Text('Teko', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Playfair', child: Text('Playfair Display', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Roboto', child: Text('Roboto', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFont = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Corner Radius'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _saveThemeSettings(currentConfig),
                icon: const Icon(Icons.palette),
                label: const Text('Publish Styling Changes'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildColorField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: '#HEXCODE',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _parseColor(controller.text),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
        )
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  Future<void> _saveThemeSettings(ThemeConfig current) async {
    final updated = ThemeConfig(
      primaryColor: _primaryController.text.trim(),
      secondaryColor: _secondaryController.text.trim(),
      backgroundColor: _backgroundController.text.trim(),
      surfaceColor: _surfaceController.text.trim(),
      fontFamily: _selectedFont,
      borderRadius: double.tryParse(_radiusController.text) ?? current.borderRadius,
    );
    
    try {
      await ref.read(configRepositoryProvider).updateThemeConfig(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theme settings published successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: $e')),
      );
    }
  }

  // 2. Feature Toggles Card
  Widget _buildFeaturesSection(FeatureFlags flags) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Feature Toggles', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Leaderboards'),
              subtitle: const Text('Enable community ranking table'),
              value: flags.enableLeaderboard,
              onChanged: (val) => _updateFeature('leaderboard', val, flags),
            ),
            SwitchListTile(
              title: const Text('Diet Plans'),
              subtitle: const Text('Enable nutritional training feeds'),
              value: flags.enableDietPlans,
              onChanged: (val) => _updateFeature('diet', val, flags),
            ),
            SwitchListTile(
              title: const Text('Children Mode'),
              subtitle: const Text('Enable fun exercises for kids'),
              value: flags.enableChildrenMode,
              onChanged: (val) => _updateFeature('children', val, flags),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateFeature(String key, bool value, FeatureFlags current) async {
    final updated = FeatureFlags(
      enableLeaderboard: key == 'leaderboard' ? value : current.enableLeaderboard,
      enableDietPlans: key == 'diet' ? value : current.enableDietPlans,
      enableChildrenMode: key == 'children' ? value : current.enableChildrenMode,
    );
    await ref.read(configRepositoryProvider).updateFeatureFlags(updated);
  }

  // 3. Layout Reorderable List
  Widget _buildLayoutSection(List<LayoutSection> sections) {
    final theme = Theme.of(context);
    
    if (sections.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('No dynamic layout configuration found in Firestore.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _seedDefaultLayout,
                child: const Text('Seed Default Layout Config'),
              )
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Homepage Layout Order', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Re-order or toggle section visibility for users in real-time.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return ListTile(
                  key: ValueKey(section.id),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(section.id.replaceAll('_', ' ').toUpperCase()),
                  subtitle: Text('Type: ${section.type} | Weight: ${section.weight}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: section.visible,
                        onChanged: (val) {
                          if (val != null) {
                            _toggleSectionVisibility(section, val, sections);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        onPressed: index > 0 ? () => _moveSection(index, index - 1, sections) : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward, size: 18),
                        onPressed: index < sections.length - 1 ? () => _moveSection(index, index + 1, sections) : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 4. Exercise & Workout Content Manager Card
  Widget _buildWorkoutManagerSection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercise & Workout Manager', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Add new training routines to Firestore for Men, Women, or Children', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _workoutTitleController,
              decoration: const InputDecoration(labelText: 'Workout Title (e.g. Core Blast)'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _workoutCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Target Category'),
                    items: const [
                      DropdownMenuItem(value: 'men', child: Text('Men')),
                      DropdownMenuItem(value: 'women', child: Text('Women')),
                      DropdownMenuItem(value: 'children', child: Text('Children')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _workoutCategory = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _workoutDifficulty,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: const [
                      DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                      DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _workoutDifficulty = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _workoutDurationController,
              decoration: const InputDecoration(labelText: 'Duration (e.g. 30 min)'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _workoutImageController,
              decoration: const InputDecoration(labelText: 'Image / Banner URL'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _workoutExercisesController,
              decoration: const InputDecoration(labelText: 'Exercises (comma separated: Pushups, Squats, Planks)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createNewWorkout,
                icon: const Icon(Icons.add_task),
                label: const Text('Add Workout to Firestore'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewWorkout() async {
    if (_workoutTitleController.text.trim().isEmpty) return;

    final exercises = _workoutExercisesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final workout = Workout(
      id: '',
      title: _workoutTitleController.text.trim(),
      description: 'Training routine for ${_workoutCategory.toUpperCase()}',
      category: _workoutCategory,
      duration: _workoutDurationController.text.trim().isEmpty ? '30 min' : _workoutDurationController.text.trim(),
      difficulty: _workoutDifficulty,
      imageUrl: _workoutImageController.text.trim(),
      exercises: exercises.isEmpty ? ['Dynamic warm-up', 'Core training'] : exercises,
    );

    try {
      await ref.read(workoutRepositoryProvider).addWorkout(workout);
      _workoutTitleController.clear();
      _workoutImageController.clear();
      _workoutExercisesController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Workout added to Firestore successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add workout: $e')),
      );
    }
  }

  Future<void> _seedDefaultLayout() async {
    final defaults = [
      const LayoutSection(id: 'hero_banners', type: 'carousel', visible: true, weight: 10, properties: {'height': 200.0, 'autoScroll': true}),
      const LayoutSection(id: 'gender_selector', type: 'gender_selector', visible: true, weight: 20, properties: {}),
      const LayoutSection(id: 'workout_list', type: 'workout_list', visible: true, weight: 30, properties: {'limit': 5, 'cardStyle': 'compact'}),
    ];
    await ref.read(configRepositoryProvider).updateLayoutSections(defaults);
  }

  Future<void> _toggleSectionVisibility(LayoutSection target, bool visible, List<LayoutSection> all) async {
    final updated = all.map((sec) {
      if (sec.id == target.id) {
        return LayoutSection(
          id: sec.id,
          type: sec.type,
          visible: visible,
          weight: sec.weight,
          properties: sec.properties,
        );
      }
      return sec;
    }).toList();
    await ref.read(configRepositoryProvider).updateLayoutSections(updated);
  }

  Future<void> _moveSection(int oldIndex, int newIndex, List<LayoutSection> all) async {
    final list = List<LayoutSection>.from(all);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    
    final reweighted = list.asMap().entries.map((entry) {
      final idx = entry.key;
      final sec = entry.value;
      return LayoutSection(
        id: sec.id,
        type: sec.type,
        visible: sec.visible,
        weight: (idx + 1) * 10,
        properties: sec.properties,
      );
    }).toList();
    
    await ref.read(configRepositoryProvider).updateLayoutSections(reweighted);
  }
}
