import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/category_model.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

// Stream of all categories
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamCategories();
});

// Search query state
class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
}

final searchQueryProvider =
    NotifierProvider<_SearchQueryNotifier, String>(_SearchQueryNotifier.new);

// Filtered categories based on search query
final filteredCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categoriesAsync = ref.watch(categoriesStreamProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return categoriesAsync.when(
    data: (categories) {
      if (query.isEmpty) return categories;
      return categories.where((cat) {
        return cat.name.toLowerCase().contains(query) ||
            cat.description.toLowerCase().contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Bottom nav index
class _BottomNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
}

final bottomNavIndexProvider =
    NotifierProvider<_BottomNavIndexNotifier, int>(_BottomNavIndexNotifier.new);
