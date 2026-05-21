import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/prompt_model.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/widgets/prompt_form_dialog.dart';
import '../widgets/prompt_list_tile.dart';

final _promptsStreamProvider =
    StreamProvider.family<List<PromptModel>, String>((ref, categoryId) {
  return ref.watch(firestoreServiceProvider).streamPrompts(categoryId);
});

class CategoryDetailScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(_promptsStreamProvider(categoryId));
    final isAdmin = ref.watch(isAdminProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: promptsAsync.when(
        loading: () => _buildLoadingState(context),
        error: (e, _) => _buildErrorState(context, e),
        data: (prompts) {
          return CustomScrollView(
            slivers: [
              // Gradient app bar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: () => context.go('/'),
                ),
                flexibleSpace: FutureBuilder(
                  future: ref
                      .read(firestoreServiceProvider)
                      .getCategory(categoryId),
                  builder: (ctx, snap) {
                    final cat = snap.data;
                    return FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: cat?.gradient ??
                              const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (cat != null)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(cat.icon, color: Colors.white, size: 24),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  cat?.name ?? 'Loading...',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (cat?.description.isNotEmpty == true)
                                  Text(
                                    cat!.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      collapseMode: CollapseMode.parallax,
                    );
                  },
                ),
              ),

              // Prompts count + admin info
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        '${prompts.length} ${prompts.length == 1 ? 'prompt' : 'prompts'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isAdmin) ...[
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _showAddPromptDialog(
                            context,
                            ref,
                            firestoreService,
                            prompts.length,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Prompt'),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                ),
              ),

              // Prompts list
              if (prompts.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyPromptsState(isAdmin: isAdmin),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final prompt = prompts[i];
                        return PromptListTile(
                          prompt: prompt,
                          isAdmin: isAdmin,
                          animationIndex: i,
                          canMoveUp: i > 0,
                          canMoveDown: i < prompts.length - 1,
                          onMoveUp: i > 0
                              ? () => _swapPrompts(
                                    ref,
                                    firestoreService,
                                    context,
                                    prompts[i - 1],
                                    prompt,
                                  )
                              : null,
                          onMoveDown: i < prompts.length - 1
                              ? () => _swapPrompts(
                                    ref,
                                    firestoreService,
                                    context,
                                    prompt,
                                    prompts[i + 1],
                                  )
                              : null,
                          onEdit: () => _showEditPromptDialog(
                            context,
                            ref,
                            firestoreService,
                            prompt,
                          ),
                          onDelete: () => _confirmDeletePrompt(
                            context,
                            firestoreService,
                            prompt,
                          ),
                        );
                      },
                      childCount: prompts.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FutureBuilder<List<PromptModel>>(
              future: ref.read(firestoreServiceProvider).streamPrompts(categoryId).first,
              builder: (ctx, snap) {
                final count = snap.data?.length ?? 0;
                if (count >= AppConstants.maxPromptsPerCategory) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: () => _showAddPromptDialog(
                    context,
                    ref,
                    ref.read(firestoreServiceProvider),
                    count,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Prompt'),
                ).animate().scale(delay: 300.ms);
              },
            )
          : null,
    );
  }

  Future<void> _swapPrompts(
    WidgetRef ref,
    FirestoreService service,
    BuildContext context,
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
    if (currentCount >= AppConstants.maxPromptsPerCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 15 prompts per category.')),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (ctx) => PromptFormDialog(
        categoryId: categoryId,
        onSave: (title, description, text) async {
          final user = ref.read(authServiceProvider).currentUser;
          if (user == null) return;
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
    WidgetRef ref,
    FirestoreService service,
    PromptModel prompt,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => PromptFormDialog(
        categoryId: categoryId,
        existingPrompt: prompt,
        onSave: (title, description, text) async {
          await service.updatePrompt(prompt.copyWith(title: title, description: description, text: text));
        },
      ),
    );
  }

  Future<void> _confirmDeletePrompt(
    BuildContext context,
    FirestoreService service,
    PromptModel prompt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text('Are you sure you want to delete "${prompt.title}"? This cannot be undone.'),
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
        await service.deletePrompt(prompt.categoryId, prompt.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt deleted successfully.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Failed to load prompts'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPromptsState extends StatelessWidget {
  final bool isAdmin;

  const _EmptyPromptsState({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
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
          Text(
            'No Prompts Yet',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Tap the + button to add the first prompt to this category.'
                : 'Prompts will appear here once added by an admin.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
