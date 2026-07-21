import 'package:equatable/equatable.dart';

class LayoutSection extends Equatable {
  final String id;
  final String type;
  final bool visible;
  final int weight;
  final Map<String, dynamic> properties;

  const LayoutSection({
    required this.id,
    required this.type,
    required this.visible,
    required this.weight,
    required this.properties,
  });

  factory LayoutSection.fromMap(Map<String, dynamic> map) {
    return LayoutSection(
      id: map['id'] ?? '',
      type: map['type'] ?? 'unrecognized',
      visible: map['visible'] ?? true,
      weight: map['weight'] ?? 100,
      properties: Map<String, dynamic>.from(map['properties'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'visible': visible,
      'weight': weight,
      'properties': properties,
    };
  }

  @override
  List<Object?> get props => [id, type, visible, weight, properties];
}
