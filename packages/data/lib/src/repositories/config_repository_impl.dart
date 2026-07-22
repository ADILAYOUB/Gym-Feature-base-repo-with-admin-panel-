import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final FirebaseFirestore? _firestoreOverride;

  late ThemeConfig _localThemeConfig;
  late FeatureFlags _localFeatureFlags;
  late List<LayoutSection> _localLayoutSections;

  late final StreamController<ThemeConfig> _themeController;
  late final StreamController<FeatureFlags> _featureController;
  late final StreamController<List<LayoutSection>> _layoutController;

  ConfigRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _themeController = StreamController<ThemeConfig>.broadcast();
    _featureController = StreamController<FeatureFlags>.broadcast();
    _layoutController = StreamController<List<LayoutSection>>.broadcast();

    _localThemeConfig = ThemeConfig.fallback();
    _localFeatureFlags = FeatureFlags.fallback();
    _localLayoutSections = List.from(_defaultLayoutSections());
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

  DocumentReference? get _globalConfigDoc {
    final fs = _firestore;
    if (fs == null) return null;
    return fs.collection('config').doc('global');
  }

  @override
  Stream<ThemeConfig> watchThemeConfig() {
    final doc = _globalConfigDoc;
    if (doc == null) {
      return _localThemeStream();
    }
    try {
      return doc.snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return _localThemeConfig;
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final themeData = data['active_theme'] as Map<String, dynamic>?;
        if (themeData == null) return _localThemeConfig;
        _localThemeConfig = ThemeConfig.fromMap(themeData);
        return _localThemeConfig;
      }).handleError((_) => _localThemeConfig);
    } catch (_) {
      return _localThemeStream();
    }
  }

  Stream<ThemeConfig> _localThemeStream() async* {
    yield _localThemeConfig;
    yield* _themeController.stream;
  }

  @override
  Future<void> updateThemeConfig(ThemeConfig config) async {
    _localThemeConfig = config;
    _themeController.add(config);

    final doc = _globalConfigDoc;
    if (doc != null) {
      try {
        await doc.set({
          'active_theme': config.toMap(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  @override
  Stream<FeatureFlags> watchFeatureFlags() {
    final doc = _globalConfigDoc;
    if (doc == null) {
      return _localFeatureStream();
    }
    try {
      return doc.snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return _localFeatureFlags;
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final featuresData = data['features'] as Map<String, dynamic>?;
        if (featuresData == null) return _localFeatureFlags;
        _localFeatureFlags = FeatureFlags.fromMap(featuresData);
        return _localFeatureFlags;
      }).handleError((_) => _localFeatureFlags);
    } catch (_) {
      return _localFeatureStream();
    }
  }

  Stream<FeatureFlags> _localFeatureStream() async* {
    yield _localFeatureFlags;
    yield* _featureController.stream;
  }

  @override
  Future<void> updateFeatureFlags(FeatureFlags flags) async {
    _localFeatureFlags = flags;
    _featureController.add(flags);

    final doc = _globalConfigDoc;
    if (doc != null) {
      try {
        await doc.set({
          'features': flags.toMap(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  @override
  Stream<List<LayoutSection>> watchLayoutSections() {
    final doc = _globalConfigDoc;
    if (doc == null) {
      return _localLayoutStream();
    }
    try {
      return doc.snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return List<LayoutSection>.from(_localLayoutSections);
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final sectionsData = data['sections_layout'] as List<dynamic>?;
        if (sectionsData == null || sectionsData.isEmpty) {
          return List<LayoutSection>.from(_localLayoutSections);
        }

        final List<LayoutSection> list = sectionsData
            .map((item) => LayoutSection.fromMap(Map<String, dynamic>.from(item)))
            .toList();

        list.sort((a, b) => a.weight.compareTo(b.weight));
        _localLayoutSections = list;
        return list;
      }).handleError((_) => List<LayoutSection>.from(_localLayoutSections));
    } catch (_) {
      return _localLayoutStream();
    }
  }

  Stream<List<LayoutSection>> _localLayoutStream() async* {
    yield List<LayoutSection>.from(_localLayoutSections);
    yield* _layoutController.stream;
  }

  @override
  Future<void> updateLayoutSections(List<LayoutSection> sections) async {
    _localLayoutSections = List.from(sections);
    _layoutController.add(List.from(sections));

    final doc = _globalConfigDoc;
    if (doc != null) {
      try {
        final list = sections.map((s) => s.toMap()).toList();
        await doc.set({
          'sections_layout': list,
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  List<LayoutSection> _defaultLayoutSections() {
    return const [
      LayoutSection(id: 'hero_banners', type: 'carousel', visible: true, weight: 10, properties: {'height': 180.0, 'autoScroll': true}),
      LayoutSection(id: 'gender_selector', type: 'gender_selector', visible: true, weight: 20, properties: {}),
      LayoutSection(id: 'workout_list', type: 'workout_list', visible: true, weight: 30, properties: {'limit': 5, 'cardStyle': 'compact'}),
    ];
  }
}
