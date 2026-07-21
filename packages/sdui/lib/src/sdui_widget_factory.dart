import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'widgets/banner_carousel_widget.dart';
import 'widgets/gender_selector_widget.dart';
import 'widgets/workout_list_widget.dart';

class SDUIWidgetFactory {
  const SDUIWidgetFactory();

  Widget buildWidget({
    required LayoutSection section,
    required BuildContext context,
    required String selectedGender,
    required ValueChanged<String> onGenderChanged,
  }) {
    if (!section.visible) return const SizedBox.shrink();

    switch (section.type) {
      case 'carousel':
        final double height = (section.properties['height'] as num?)?.toDouble() ?? 200.0;
        final bool autoScroll = section.properties['autoScroll'] as bool? ?? true;
        return BannerCarouselWidget(
          height: height,
          autoScroll: autoScroll,
        );
      case 'gender_selector':
        final List<String> categories = List<String>.from(section.properties['categories'] ?? ['Men', 'Women', 'Children']);
        return GenderSelectorWidget(
          categories: categories,
          selectedCategory: selectedGender,
          onCategoryChanged: onGenderChanged,
        );
      case 'workout_list':
        final int limit = (section.properties['limit'] as num?)?.toInt() ?? 5;
        final String cardStyle = section.properties['cardStyle'] ?? 'compact';
        return WorkoutListWidget(
          category: selectedGender,
          limit: limit,
          cardStyle: cardStyle,
        );
      default:
        // Graceful fallback for unrecognized section types - supports hot adding/testing
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Unrecognized section type: ${section.type}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
        );
    }
  }
}
