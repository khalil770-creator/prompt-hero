import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/prompt_model.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/prompt_form_dialog.dart';

final _adminPromptsStreamProvider =
    StreamProvider.family<List<PromptModel>, String>((ref, categoryId) {
  return ref.watch(firestoreServiceProvider).streamPrompts(categoryId);
});

class ManagePromptsScreen extends ConsumerWidget {
  final String categoryId;

  const ManagePromptsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(_adminPromptsStreamProvider(categoryId));
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Prompts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/admin/categories'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add prompt',
            onPressed: () => _showAddPromptDialog(context, ref, firestoreService, 0),
          ),
        ],
      ),
      body: promptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prompts) {
          if (prompts.isEmpty) {
            return _EmptyState(
              onAdd: () => _showAddPromptDialog(context, ref, firestoreService, 0),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddPromptDialog(context, ref, firestoreService, prompts.length),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add new prompt'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: prompts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
              final prompt = prompts[i];
              return _PromptManageCard(
                prompt: prompt,
                index: i,
                total: prompts.length,
                onMoveUp: i > 0
                    ? () => _swapPrompts(
                          context,
                          firestoreService,
                          prompts[i - 1],
                          prompt,
                        )
                    : null,
                onMoveDown: i < prompts.length - 1
                    ? () => _swapPrompts(
                          context,
                          firestoreService,
                          prompt,
                          prompts[i + 1],
                        )
                    : null,
                onEdit: () => _showEditPromptDialog(
                  context,
                  firestoreService,
                  prompt,
                ),
                onDelete: () => _confirmDelete(context, firestoreService, prompt),
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
        onPressed: () async {
          final prompts =
              await ref.read(_adminPromptsStreamProvider(categoryId).future);
          if (context.mounted) {
            _showAddPromptDialog(context, ref, firestoreService, prompts.length);
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Prompt'),
      ).animate().scale(delay: 300.ms),
    );
  }

  Future<void> _swapPrompts(
    BuildContext context,
    FirestoreService service,
    PromptModel promptA,
    PromptModel promptB,
  ) async {
    try {
      await service.reorderPrompt(
        categoryId: categoryId,
        promptAId: promptA.id,
        orderA: promptA.order,
        promptBId: promptB.id,
        orderB: promptB.order,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reorder: $e')),
        );
      }
    }
  }

  Future<void> _showAddPromptDialog(
    BuildContext context,
    WidgetRef ref,
    FirestoreService service,
    int currentCount,
  ) async {
    if (currentCount >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 15 prompts per category.')),
      );
      return;
    }
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    await showDialog(
      context: context,
      builder: (ctx) => PromptFormDialog(
        categoryId: categoryId,
        onSave: (title, description, text) async {
          await service.createPrompt(
            PromptModel(
              id: '',
              categoryId: categoryId,
              title: title,
              description: description,
              text: text,
              order: currentCount,
              createdAt: DateTime.now(),
              createdBy: user.uid,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditPromptDialog(
    BuildContext context,
    FirestoreService service,
    PromptModel prompt,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => PromptFormDialog(
        categoryId: categoryId,
        existingPrompt: prompt,
        onSave: (title, description, text) async {
          await service.updatePrompt(
              prompt.copyWith(title: title, description: description, text: text));
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FirestoreService service,
    PromptModel prompt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text('Delete "${prompt.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
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
        await service.deletePrompt(categoryId, prompt.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt deleted.')),
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

class _PromptManageCard extends StatelessWidget {
  final PromptModel prompt;
  final int index;
  final int total;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animIndex;

  const _PromptManageCard({
    required this.prompt,
    required this.index,
    required this.total,
    this.onMoveUp,
    this.onMoveDown,
    required this.onEdit,
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prompt.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prompt.truncatedText,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.starActive, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        prompt.ratingCount > 0
                            ? '${prompt.avgRating.toStringAsFixed(1)} (${prompt.ratingCount})'
                            : 'No ratings',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Move up
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: onMoveUp != null
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                  iconSize: 22,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: onMoveUp,
                  tooltip: 'Move up',
                ),
                // Move down
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: onMoveDown != null
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                  iconSize: 22,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: onMoveDown,
                  tooltip: 'Move down',
                ),
                // More actions
                PopupMenuButton<String>(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text('Edit',
                              style: Theme.of(ctx).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              size: 16, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Text('Delete',
                              style: Theme.of(ctx)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.red.shade600)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * animIndex))
        .slideX(begin: 0.05, delay: Duration(milliseconds: 60 * animIndex));
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
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('No Prompts Yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Add the first prompt to this category.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Prompt'),
            ),
          ],
        ),
      ),
    );
  }
}
