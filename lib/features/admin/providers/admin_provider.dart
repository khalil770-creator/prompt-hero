import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/category_model.dart';
import '../../../models/request_model.dart';
import '../../../services/analytics_service.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService());

// All categories for admin management
final adminCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamCategories();
});

// Pending requests for review
final pendingRequestsProvider = StreamProvider<List<RequestModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamRequests(status: 'pending');
});

// All requests (for full review panel)
final allRequestsProvider = StreamProvider<List<RequestModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamRequests();
});

// Admin stats
final adminStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(firestoreServiceProvider).getAdminStats();
});

// Currently selected category for prompt management
class _SelectedCategoryIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}

final selectedCategoryIdProvider =
    NotifierProvider<_SelectedCategoryIdNotifier, String?>(
        _SelectedCategoryIdNotifier.new);

// Admin action notifier
class AdminNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(firestoreServiceProvider).deleteCategory(categoryId));
  }

  Future<void> approveRequest(String requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).updateRequestStatus(
            requestId: requestId,
            status: 'approved',
          ),
    );
  }

  Future<void> rejectRequest(String requestId, {String? note}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).updateRequestStatus(
            requestId: requestId,
            status: 'rejected',
            reviewNote: note,
          ),
    );
  }

  void reset() => state = const AsyncValue.data(null);
}

final adminNotifierProvider =
    NotifierProvider<AdminNotifier, AsyncValue<void>>(AdminNotifier.new);
