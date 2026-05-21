import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/prompt_model.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _db.collection(AppConstants.categoriesCollection);

  Stream<List<CategoryModel>> streamCategories() {
    return _categoriesRef
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(CategoryModel.fromFirestore).toList());
  }

  Future<CategoryModel?> getCategory(String id) async {
    final doc = await _categoriesRef.doc(id).get();
    if (!doc.exists) return null;
    return CategoryModel.fromFirestore(doc);
  }

  Future<String> createCategory(CategoryModel category) async {
    // Determine next order
    final snap = await _categoriesRef.orderBy('order', descending: true).limit(1).get();
    final nextOrder = snap.docs.isEmpty
        ? 0
        : ((snap.docs.first.data()['order'] as num?)?.toInt() ?? 0) + 1;

    final ref = _categoriesRef.doc();
    await ref.set({
      ...category.copyWith(order: nextOrder).toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoriesRef.doc(category.id).update(category.toFirestore());
  }

  Future<void> deleteCategory(String categoryId) async {
    final batch = _db.batch();

    // Delete all prompts in category
    final prompts = await _categoriesRef
        .doc(categoryId)
        .collection(AppConstants.promptsCollection)
        .get();
    for (final doc in prompts.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_categoriesRef.doc(categoryId));
    await batch.commit();
  }

  /// Swap the order of two adjacent categories.
  Future<void> reorderCategory(
    String categoryId,
    int currentOrder,
    String targetId,
    int targetOrder,
  ) async {
    final batch = _db.batch();
    batch.update(_categoriesRef.doc(categoryId), {'order': targetOrder});
    batch.update(_categoriesRef.doc(targetId), {'order': currentOrder});
    await batch.commit();
  }

  Future<void> incrementPromptCount(String categoryId, int delta) async {
    await _categoriesRef.doc(categoryId).update({
      'promptCount': FieldValue.increment(delta),
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // PROMPTS
  // ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _promptsRef(String categoryId) =>
      _categoriesRef.doc(categoryId).collection(AppConstants.promptsCollection);

  Stream<List<PromptModel>> streamPrompts(String categoryId) {
    return _promptsRef(categoryId)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PromptModel.fromFirestore(doc, categoryId: categoryId))
            .toList());
  }

  Future<PromptModel?> getPrompt(String categoryId, String promptId) async {
    final doc = await _promptsRef(categoryId).doc(promptId).get();
    if (!doc.exists) return null;
    return PromptModel.fromFirestore(doc, categoryId: categoryId);
  }

  Future<String> createPrompt(PromptModel prompt) async {
    final snap = await _promptsRef(prompt.categoryId)
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    final nextOrder = snap.docs.isEmpty
        ? 0
        : ((snap.docs.first.data()['order'] as num?)?.toInt() ?? 0) + 1;

    final ref = _promptsRef(prompt.categoryId).doc();
    await ref.set({
      ...prompt.copyWith(order: nextOrder).toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await incrementPromptCount(prompt.categoryId, 1);
    return ref.id;
  }

  Future<void> updatePrompt(PromptModel prompt) async {
    await _promptsRef(prompt.categoryId).doc(prompt.id).update({
      'title': prompt.title,
      'description': prompt.description,
      'text': prompt.text,
    });
  }

  Future<void> deletePrompt(String categoryId, String promptId) async {
    await _promptsRef(categoryId).doc(promptId).delete();
    await incrementPromptCount(categoryId, -1);
  }

  /// Swap order of two prompts (move up/down).
  Future<void> reorderPrompt({
    required String categoryId,
    required String promptAId,
    required int orderA,
    required String promptBId,
    required int orderB,
  }) async {
    final batch = _db.batch();
    batch.update(_promptsRef(categoryId).doc(promptAId), {'order': orderB});
    batch.update(_promptsRef(categoryId).doc(promptBId), {'order': orderA});
    await batch.commit();
  }

  // ─────────────────────────────────────────────────────────────────
  // RATINGS
  // ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _ratingsRef =>
      _db.collection(AppConstants.ratingsCollection);

  String _ratingDocId(String userId, String promptId) => '${userId}_$promptId';

  Future<double?> getUserRating({
    required String userId,
    required String promptId,
  }) async {
    final doc = await _ratingsRef.doc(_ratingDocId(userId, promptId)).get();
    if (!doc.exists) return null;
    return (doc.data()?['rating'] as num?)?.toDouble();
  }

  Stream<double?> streamUserRating({
    required String userId,
    required String promptId,
  }) {
    return _ratingsRef
        .doc(_ratingDocId(userId, promptId))
        .snapshots()
        .map((snap) => snap.exists ? (snap.data()?['rating'] as num?)?.toDouble() : null);
  }

  /// Submit or update a rating using a Firestore transaction to keep avgRating consistent.
  Future<void> submitRating({
    required String userId,
    required String promptId,
    required String categoryId,
    required double rating,
  }) async {
    final ratingDocRef = _ratingsRef.doc(_ratingDocId(userId, promptId));
    final promptRef = _promptsRef(categoryId).doc(promptId);

    await _db.runTransaction((tx) async {
      final ratingSnap = await tx.get(ratingDocRef);
      final promptSnap = await tx.get(promptRef);

      if (!promptSnap.exists) return;

      final promptData = promptSnap.data()!;
      double currentAvg = (promptData['avgRating'] as num?)?.toDouble() ?? 0.0;
      int currentCount = (promptData['ratingCount'] as num?)?.toInt() ?? 0;

      double newAvg;
      int newCount;

      if (ratingSnap.exists) {
        // Update existing rating
        final oldRating = (ratingSnap.data()?['rating'] as num?)?.toDouble() ?? 0.0;
        final totalPoints = currentAvg * currentCount - oldRating + rating;
        newCount = currentCount;
        newAvg = currentCount > 0 ? totalPoints / currentCount : rating;
      } else {
        // New rating
        final totalPoints = currentAvg * currentCount + rating;
        newCount = currentCount + 1;
        newAvg = totalPoints / newCount;
      }

      tx.set(ratingDocRef, {
        'userId': userId,
        'promptId': promptId,
        'categoryId': categoryId,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      tx.update(promptRef, {
        'avgRating': newAvg,
        'ratingCount': newCount,
      });
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // REQUESTS
  // ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _requestsRef =>
      _db.collection(AppConstants.requestsCollection);

  Stream<List<RequestModel>> streamRequests({String? status}) {
    Query<Map<String, dynamic>> query = _requestsRef.orderBy('createdAt', descending: true);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map(
          (snap) => snap.docs.map(RequestModel.fromFirestore).toList(),
        );
  }

  Stream<List<RequestModel>> streamUserRequests(String userId) {
    return _requestsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RequestModel.fromFirestore).toList());
  }

  Future<String> submitRequest(RequestModel request) async {
    final ref = _requestsRef.doc();
    await ref.set({
      ...request.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? reviewNote,
  }) async {
    await _requestsRef.doc(requestId).update({
      'status': status,
      if (reviewNote != null) 'reviewNote': reviewNote,
    });
  }

  Future<void> deleteRequest(String requestId) async {
    await _requestsRef.doc(requestId).delete();
  }

  // ─────────────────────────────────────────────────────────────────
  // USERS
  // ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection(AppConstants.usersCollection);

  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map(
          (snap) => snap.exists ? UserModel.fromFirestore(snap) : null,
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(UserModel user) async {
    await _usersRef.doc(user.id).update(user.toFirestore());
  }

  // ─────────────────────────────────────────────────────────────────
  // ADMIN STATS
  // ─────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getAdminStats() async {
    final categoriesSnap = await _categoriesRef.count().get();
    final requestsSnap =
        await _requestsRef.where('status', isEqualTo: AppConstants.statusPending).count().get();
    final usersSnap = await _usersRef.count().get();

    return {
      'categories': categoriesSnap.count ?? 0,
      'pendingRequests': requestsSnap.count ?? 0,
      'users': usersSnap.count ?? 0,
    };
  }
}
