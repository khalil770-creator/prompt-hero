import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int gradientIndex;
  final int order;
  final DateTime createdAt;
  final String createdBy;
  final int promptCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.gradientIndex,
    required this.order,
    required this.createdAt,
    required this.createdBy,
    this.promptCount = 0,
  });

  IconData get icon => AppConstants.getIcon(iconName);

  List<Color> get gradientColors {
    final idx = gradientIndex % AppColors.categoryGradients.length;
    return AppColors.categoryGradients[idx];
  }

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      );

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'star',
      gradientIndex: (data['gradientIndex'] as num?)?.toInt() ?? 0,
      order: (data['order'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      promptCount: (data['promptCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'iconName': iconName,
        'gradientIndex': gradientIndex,
        'order': order,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
        'promptCount': promptCount,
      };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? gradientIndex,
    int? order,
    DateTime? createdAt,
    String? createdBy,
    int? promptCount,
  }) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        iconName: iconName ?? this.iconName,
        gradientIndex: gradientIndex ?? this.gradientIndex,
        order: order ?? this.order,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        promptCount: promptCount ?? this.promptCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
