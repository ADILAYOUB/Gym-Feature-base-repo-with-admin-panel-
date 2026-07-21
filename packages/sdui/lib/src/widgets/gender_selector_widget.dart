import 'package:flutter/material.dart';

class GenderSelectorWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const GenderSelectorWidget({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who is training today?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: categories.map((category) {
              final isSelected = selectedCategory.toLowerCase() == category.toLowerCase();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () => onCategoryChanged(category),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : theme.colorScheme.onSurface.withOpacity(0.08),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
