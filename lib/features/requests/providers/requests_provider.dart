import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/request_model.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

// User's submitted requests stream
final userRequestsProvider = StreamProvider<List<RequestModel>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).streamUserRequests(user.uid);
});

// Request submission notifier
class RequestSubmitNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submitRequest({
    required String type,
    required String userId,
    required String userEmail,
    required String title,
    required String details,
    String? categoryId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).submitRequest(
            RequestModel(
              id: '',
              type: type,
              userId: userId,
              userEmail: userEmail,
              title: title,
              details: details,
              categoryId: categoryId,
              status: 'pending',
              createdAt: DateTime.now(),
            ),
          ),
    );
  }

  void reset() => state = const AsyncValue.data(null);
}

final requestSubmitProvider =
    NotifierProvider<RequestSubmitNotifier, AsyncValue<void>>(
        RequestSubmitNotifier.new);
