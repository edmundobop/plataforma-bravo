import 'package:flutter/material.dart';
import 'checklist_item.dart';

class ChecklistCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<ChecklistItem> items;

  ChecklistCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.items,
  });

  // Getters calculados
  int get completedCount => items.where((item) => item.isChecked).length;
  
  bool get isCompleted => items.isNotEmpty && items.every((item) => item.isChecked);
  
  double get completionPercentage {
    if (items.isEmpty) return 0.0;
    return (completedCount / items.length) * 100;
  }

  // Método copyWith
  ChecklistCategory copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    List<ChecklistItem>? items,
  }) {
    return ChecklistCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      items: items ?? this.items,
    );
  }

  // Serialização para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'items': items.map((item) => item.toMap()).toList(),
      'completedCount': completedCount,
      'isCompleted': isCompleted,
      'completionPercentage': completionPercentage,
    };
  }

  // Deserialização do Firebase
  factory ChecklistCategory.fromMap(Map<String, dynamic> map) {
    return ChecklistCategory(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: IconData(
        map['iconCodePoint'] ?? Icons.help.codePoint,
        fontFamily: map['iconFontFamily'],
      ),
      items: (map['items'] as List<dynamic>?)
          ?.map((itemMap) => ChecklistItem.fromMap(itemMap))
          .toList() ?? [],
    );
  }

  // Método para JSON (útil para debug)
  Map<String, dynamic> toJson() => toMap();

  factory ChecklistCategory.fromJson(Map<String, dynamic> json) {
    return ChecklistCategory.fromMap(json);
  }

  @override
  String toString() {
    return 'ChecklistCategory(id: $id, title: $title, '
           'completedCount: $completedCount/${items.length}, '
           'isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}