import 'package:cloud_firestore/cloud_firestore.dart';

class PromptModel {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String text;
  final int order;
  final double avgRating;
  final int ratingCount;
  final DateTime createdAt;
  final String createdBy;

  const PromptModel({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description = '',
    required this.text,
    required this.order,
    this.avgRating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    required this.createdBy,
  });

  String get truncatedText {
    if (text.length <= 120) return text;
    return '${text.substring(0, 120)}...';
  }

  factory PromptModel.fromFirestore(DocumentSnapshot doc, {String categoryId = ''}) {
    final data = doc.data() as Map<String, dynamic>;
    return PromptModel(
      id: doc.id,
      categoryId: categoryId.isNotEmpty ? categoryId : (data['categoryId'] as String? ?? ''),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      text: data['text'] as String? ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'text': text,
        'order': order,
        'avgRating': avgRating,
        'ratingCount': ratingCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };

  PromptModel copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    String? text,
    int? order,
    double? avgRating,
    int? ratingCount,
    DateTime? createdAt,
    String? createdBy,
  }) =>
      PromptModel(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        title: title ?? this.title,
        description: description ?? this.description,
        text: text ?? this.text,
        order: order ?? this.order,
        avgRating: avgRating ?? this.avgRating,
        ratingCount: ratingCount ?? this.ratingCount,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
