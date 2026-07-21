import '../models/theme_config.dart';
import '../models/feature_flags.dart';
import '../models/layout_section.dart';

abstract class ConfigRepository {
  Stream<ThemeConfig> watchThemeConfig();
  Future<void> updateThemeConfig(ThemeConfig config);

  Stream<FeatureFlags> watchFeatureFlags();
  Future<void> updateFeatureFlags(FeatureFlags flags);

  Stream<List<LayoutSection>> watchLayoutSections();
  Future<void> updateLayoutSections(List<LayoutSection> sections);
}
