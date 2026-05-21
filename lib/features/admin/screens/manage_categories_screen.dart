import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/category_form_dialog.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add category',
            onPressed: () => _showAddCategoryDialog(context, ref, firestoreService),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return _EmptyState(
              onAdd: () => _showAddCategoryDialog(context, ref, firestoreService),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context, ref, firestoreService),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add new category'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
              final cat = categories[i];
              return _CategoryManageCard(
                category: cat,
                canMoveUp: i > 0,
                canMoveDown: i < categories.length - 1,
                onMoveUp: () => _swapCategories(
                  context,
                  firestoreService,
                  categories[i - 1],
                  cat,
                ),
                onMoveDown: () => _swapCategories(
                  context,
                  firestoreService,
                  cat,
                  categories[i + 1],
                ),
                onEdit: () => _showEditCategoryDialog(
                  context,
                  ref,
                  firestoreService,
                  cat,
                ),
                onManagePrompts: () => context.go('/admin/categories/${cat.id}/prompts'),
                onDelete: () => _confirmDelete(context, ref, firestoreService, cat),
                animIndex: i,
              );
            },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, ref, firestoreService),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ).animate().scale(delay: 300.ms),
    );
  }

  Future<void> _swapCategories(
    BuildContext context,
    FirestoreService service,
    CategoryModel catA,
    CategoryModel catB,
  ) async {
    try {
      await service.reorderCategory(catA.id, catA.order, catB.id, catB.order);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reorder: $e')),
        );
      }
    }
  }

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    FirestoreService service,
  ) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    await showDialog(
      context: context,
      builder: (ctx) => CategoryFormDialog(
        onSave: (name, description, iconName, gradientIndex) async {
          await service.createCategory(
            CategoryModel(
              id: '',
              name: name,
              description: description,
              iconName: iconName,
              gradientIndex: gradientIndex,
              order: 0,
              createdAt: DateTime.now(),
              createdBy: user.uid,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    FirestoreService service,
    CategoryModel category,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => CategoryFormDialog(
        existingCategory: category,
        onSave: (name, description, iconName, gradientIndex) async {
          await service.updateCategory(category.copyWith(
            name: name,
            description: description,
            iconName: iconName,
            gradientIndex: gradientIndex,
          ));
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FirestoreService service,
    CategoryModel category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Delete "${category.name}"? This will also delete all ${category.promptCount} prompts inside it. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.deleteCategory(category.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${category.name}" deleted.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

class _CategoryManageCard extends StatelessWidget {
  final CategoryModel category;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onEdit;
  final VoidCallback onManagePrompts;
  final VoidCallback onDelete;
  final int animIndex;

  const _CategoryManageCard({
    required this.category,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEdit,
    required this.onManagePrompts,
    required this.onDelete,
    required this.animIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 6,
            height: 72,
            decoration: BoxDecoration(
              gradient: category.gradient,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
            ),
          ),

          // Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: category.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: Colors.white, size: 20),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${category.promptCount} prompts',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Move up/down
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: canMoveUp ? onMoveUp : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 20,
                        color: canMoveUp
                            ? AppColors.textSecondary
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: canMoveDown ? onMoveDown : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: canMoveDown
                            ? AppColors.textSecondary
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                ],
              ),

              // More menu
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                itemBuilder: (ctx) => [
                  _popupItem(ctx, 'edit', Icons.edit_rounded, 'Edit', null),
                  _popupItem(ctx, 'prompts', Icons.list_rounded,
                      'Manage Prompts', null),
                  _popupItem(ctx, 'delete', Icons.delete_rounded, 'Delete',
                      Colors.red.shade600),
                ],
                onSelected: (val) {
                  switch (val) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'prompts':
                      onManagePrompts();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * animIndex))
        .slideX(begin: 0.05, delay: Duration(milliseconds: 60 * animIndex));
  }

  PopupMenuItem<String> _popupItem(
    BuildContext ctx,
    String value,
    IconData icon,
    String label,
    Color? color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.category_rounded,
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('No Categories Yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Create your first category to get started.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}
