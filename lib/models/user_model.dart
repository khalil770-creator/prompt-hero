import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class UserModel {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? displayName;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
    this.displayName,
  });

  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isUser => role == AppConstants.roleUser;

  String get displayEmail => displayName?.isNotEmpty == true ? displayName! : email;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? AppConstants.roleUser,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      displayName: data['displayName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
        if (displayName != null) 'displayName': displayName,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    DateTime? createdAt,
    String? displayName,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        displayName: displayName ?? this.displayName,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
