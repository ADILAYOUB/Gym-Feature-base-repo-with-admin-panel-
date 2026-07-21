import 'package:equatable/equatable.dart';

class ThemeConfig extends Equatable {
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String surfaceColor;
  final String fontFamily;
  final double borderRadius;

  const ThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.fontFamily,
    required this.borderRadius,
  });

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      primaryColor: map['primaryColor'] ?? '#FF5722',
      secondaryColor: map['secondaryColor'] ?? '#1E1E2C',
      backgroundColor: map['backgroundColor'] ?? '#121212',
      surfaceColor: map['surfaceColor'] ?? '#1E1E1E',
      fontFamily: map['fontFamily'] ?? 'Outfit',
      borderRadius: (map['borderRadius'] as num?)?.toDouble() ?? 12.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'surfaceColor': surfaceColor,
      'fontFamily': fontFamily,
      'borderRadius': borderRadius,
    };
  }

  // A factory for a fallback theme
  factory ThemeConfig.fallback() {
    return const ThemeConfig(
      primaryColor: '#FF5722',
      secondaryColor: '#1E1E2C',
      backgroundColor: '#121212',
      surfaceColor: '#1E1E1E',
      fontFamily: 'Outfit',
      borderRadius: 12.0,
    );
  }

  @override
  List<Object?> get props => [
        primaryColor,
        secondaryColor,
        backgroundColor,
        surfaceColor,
        fontFamily,
        borderRadius,
      ];
}
