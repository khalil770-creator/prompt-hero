import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class RequestModel {
  final String id;
  final String type; // 'category' | 'prompt'
  final String userId;
  final String userEmail;
  final String title;
  final String details;
  final String? categoryId; // for prompt requests
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime createdAt;
  final String? reviewNote;

  const RequestModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.userEmail,
    required this.title,
    required this.details,
    this.categoryId,
    required this.status,
    required this.createdAt,
    this.reviewNote,
  });

  bool get isPending => status == AppConstants.statusPending;
  bool get isApproved => status == AppConstants.statusApproved;
  bool get isRejected => status == AppConstants.statusRejected;
  bool get isCategory => type == AppConstants.requestTypeCategory;
  bool get isPrompt => type == AppConstants.requestTypePrompt;

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      type: data['type'] as String? ?? AppConstants.requestTypePrompt,
      userId: data['userId'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      categoryId: data['categoryId'] as String?,
      status: data['status'] as String? ?? AppConstants.statusPending,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewNote: data['reviewNote'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type,
        'userId': userId,
        'userEmail': userEmail,
        'title': title,
        'details': details,
        if (categoryId != null) 'categoryId': categoryId,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        if (reviewNote != null) 'reviewNote': reviewNote,
      };

  RequestModel copyWith({
    String? id,
    String? type,
    String? userId,
    String? userEmail,
    String? title,
    String? details,
    String? categoryId,
    String? status,
    DateTime? createdAt,
    String? reviewNote,
  }) =>
      RequestModel(
        id: id ?? this.id,
        type: type ?? this.type,
        userId: userId ?? this.userId,
        userEmail: userEmail ?? this.userEmail,
        title: title ?? this.title,
        details: details ?? this.details,
        categoryId: categoryId ?? this.categoryId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        reviewNote: reviewNote ?? this.reviewNote,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
