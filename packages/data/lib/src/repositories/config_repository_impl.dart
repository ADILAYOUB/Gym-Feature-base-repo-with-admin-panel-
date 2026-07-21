import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final FirebaseFirestore _firestore;

  ConfigRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference get _globalConfigDoc =>
      _firestore.collection('config').doc('global');

  @override
  Stream<ThemeConfig> watchThemeConfig() {
    return _globalConfigDoc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return ThemeConfig.fallback();
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final themeData = data['active_theme'] as Map<String, dynamic>?;
      if (themeData == null) return ThemeConfig.fallback();
      return ThemeConfig.fromMap(themeData);
    });
  }

  @override
  Future<void> updateThemeConfig(ThemeConfig config) async {
    await _globalConfigDoc.set({
      'active_theme': config.toMap(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<FeatureFlags> watchFeatureFlags() {
    return _globalConfigDoc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return FeatureFlags.fallback();
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final featuresData = data['features'] as Map<String, dynamic>?;
      if (featuresData == null) return FeatureFlags.fallback();
      return FeatureFlags.fromMap(featuresData);
    });
  }

  @override
  Future<void> updateFeatureFlags(FeatureFlags flags) async {
    await _globalConfigDoc.set({
      'features': flags.toMap(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<LayoutSection>> watchLayoutSections() {
    return _globalConfigDoc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return _defaultLayoutSections();
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final sectionsData = data['sections_layout'] as List<dynamic>?;
      if (sectionsData == null || sectionsData.isEmpty) {
        return _defaultLayoutSections();
      }
      
      final List<LayoutSection> list = sectionsData
          .map((item) => LayoutSection.fromMap(Map<String, dynamic>.from(item)))
          .toList();
          
      list.sort((a, b) => a.weight.compareTo(b.weight));
      return list;
    });
  }

  @override
  Future<void> updateLayoutSections(List<LayoutSection> sections) async {
    final list = sections.map((s) => s.toMap()).toList();
    await _globalConfigDoc.set({
      'sections_layout': list,
    }, SetOptions(merge: true));
  }

  List<LayoutSection> _defaultLayoutSections() {
    return const [
      LayoutSection(id: 'hero_banners', type: 'carousel', visible: true, weight: 10, properties: {'height': 180.0, 'autoScroll': true}),
      LayoutSection(id: 'gender_selector', type: 'gender_selector', visible: true, weight: 20, properties: {}),
      LayoutSection(id: 'workout_list', type: 'workout_list', visible: true, weight: 30, properties: {'limit': 5, 'cardStyle': 'compact'}),
    ];
  }
}
