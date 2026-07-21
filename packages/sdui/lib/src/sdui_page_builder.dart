import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'sdui_widget_factory.dart';

class SDUIPageBuilder extends StatelessWidget {
  final List<LayoutSection> sections;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final SDUIWidgetFactory widgetFactory;

  const SDUIPageBuilder({
    Key? key,
    required this.sections,
    required this.selectedGender,
    required this.onGenderChanged,
    this.widgetFactory = const SDUIWidgetFactory(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeSections = sections.isNotEmpty
        ? sections
        : const [
            LayoutSection(id: 'hero_banners', type: 'carousel', visible: true, weight: 10, properties: {'height': 180.0, 'autoScroll': true}),
            LayoutSection(id: 'gender_selector', type: 'gender_selector', visible: true, weight: 20, properties: {}),
            LayoutSection(id: 'workout_list', type: 'workout_list', visible: true, weight: 30, properties: {'limit': 5, 'cardStyle': 'compact'}),
          ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: activeSections.length,
      itemBuilder: (context, index) {
        final section = activeSections[index];
        return widgetFactory.buildWidget(
          section: section,
          context: context,
          selectedGender: selectedGender,
          onGenderChanged: onGenderChanged,
        );
      },
    );
  }
}
