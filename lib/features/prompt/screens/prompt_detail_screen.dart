import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/share_utils.dart';
import '../../../models/prompt_model.dart';
import '../../../services/firestore_service.dart';
import '../../admin/providers/admin_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/rating_bar_widget.dart';

final _promptDetailProvider =
    FutureProvider.family<PromptModel?, ({String categoryId, String promptId})>(
        (ref, args) {
  return ref
      .watch(firestoreServiceProvider)
      .getPrompt(args.categoryId, args.promptId);
});

final _userRatingProvider =
    StreamProvider.family<double?, ({String userId, String promptId})>(
        (ref, args) {
  return ref.watch(firestoreServiceProvider).streamUserRating(
        userId: args.userId,
        promptId: args.promptId,
      );
});

class PromptDetailScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String promptId;

  const PromptDetailScreen({
    super.key,
    required this.categoryId,
    required this.promptId,
  });

  @override
  ConsumerState<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen> {
  bool _isTextExpanded = false;
  bool _viewLogged = false;
  static const int _collapseThreshold = 300;

  @override
  Widget build(BuildContext context) {
    final args = (categoryId: widget.categoryId, promptId: widget.promptId);
    final promptAsync = ref.watch(_promptDetailProvider(args));
    final theme = Theme.of(context);
    final currentUser = ref.watch(authStateProvider).asData?.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: promptAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: BackButton(
              onPressed: () => context.go('/category/${widget.categoryId}'),
            ),
          ),
          body: Center(child: Text('Failed to load prompt: $e')),
        ),
        data: (prompt) {
          if (prompt == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primary,
                leading: BackButton(
                    onPressed: () =>
                        context.go('/category/${widget.categoryId}')),
              ),
              body: const Center(child: Text('Prompt not found')),
            );
          }

          // Log view event once per screen load
          if (!_viewLogged) {
            _viewLogged = true;
            final currentUser = ref.read(authStateProvider).asData?.value;
            ref.read(analyticsServiceProvider).logEvent(
                  type: 'view',
                  promptId: prompt.id,
                  promptTitle: prompt.title,
                  categoryId: prompt.categoryId,
                  categoryName: '',
                  userId: currentUser?.uid,
                );
          }

          final isLongText = prompt.text.length > _collapseThreshold;
          final displayText = isLongText && !_isTextExpanded
              ? '${prompt.text.substring(0, _collapseThreshold)}...'
              : prompt.text;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 18),
                  ),
                  onPressed: () =>
                      context.go('/category/${widget.categoryId}'),
                ),
                title: Text(
                  prompt.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.white),
                    tooltip: 'Copy prompt',
                    onPressed: () {
                      final currentUser =
                          ref.read(authStateProvider).asData?.value;
                      ref.read(analyticsServiceProvider).logEvent(
                            type: 'copy',
                            promptId: prompt.id,
                            promptTitle: prompt.title,
                            categoryId: prompt.categoryId,
                            categoryName: '',
                            userId: currentUser?.uid,
                            platform: 'clipboard',
                          );
                      ShareUtils.copyToClipboard(
                        context: context,
                        text: prompt.text,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    tooltip: 'Share via WhatsApp',
                    onPressed: () {
                      final currentUser =
                          ref.read(authStateProvider).asData?.value;
                      ref.read(analyticsServiceProvider).logEvent(
                            type: 'share',
                            promptId: prompt.id,
                            promptTitle: prompt.title,
                            categoryId: prompt.categoryId,
                            categoryName: '',
                            userId: currentUser?.uid,
                            platform: 'whatsapp',
                          );
                      ShareUtils.shareViaWhatsApp(
                        context: context,
                        promptTitle: prompt.title,
                        promptText: prompt.text,
                      );
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    prompt.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CompactRatingDisplay(
                              avgRating: prompt.avgRating,
                              ratingCount: prompt.ratingCount,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                      // Description section
                      if (prompt.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  prompt.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.1),
                      ],

                      const SizedBox(height: 24),

                      // Prompt text section
                      Text(
                        'Prompt',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              displayText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.7,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (isLongText) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => setState(
                                    () => _isTextExpanded = !_isTextExpanded),
                                child: Text(
                                  _isTextExpanded ? 'Show Less' : 'Show More',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      final currentUser = ref
                                          .read(authStateProvider)
                                          .asData
                                          ?.value;
                                      ref
                                          .read(analyticsServiceProvider)
                                          .logEvent(
                                            type: 'copy',
                                            promptId: prompt.id,
                                            promptTitle: prompt.title,
                                            categoryId: prompt.categoryId,
                                            categoryName: '',
                                            userId: currentUser?.uid,
                                            platform: 'clipboard',
                                          );
                                      ShareUtils.copyToClipboard(
                                        context: context,
                                        text: prompt.text,
                                      );
                                    },
                                    icon: const Icon(Icons.copy_rounded,
                                        size: 16),
                                    label: const Text('Copy Prompt'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final currentUser = ref
                                          .read(authStateProvider)
                                          .asData
                                          ?.value;
                                      ref
                                          .read(analyticsServiceProvider)
                                          .logEvent(
                                            type: 'share',
                                            promptId: prompt.id,
                                            promptTitle: prompt.title,
                                            categoryId: prompt.categoryId,
                                            categoryName: '',
                                            userId: currentUser?.uid,
                                            platform: 'whatsapp',
                                          );
                                      ShareUtils.shareViaWhatsApp(
                                        context: context,
                                        promptTitle: prompt.title,
                                        promptText: prompt.text,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                    ),
                                    icon: const Icon(Icons.share_rounded,
                                        size: 16),
                                    label: const Text('WhatsApp'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

                      const SizedBox(height: 28),

                      // Rating section
                      if (currentUser != null) ...[
                        Text(
                          'Rate this Prompt',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 8),
                        Text(
                          'How useful was this prompt?',
                          style: theme.textTheme.bodyMedium,
                        ).animate().fadeIn(delay: 250.ms),
                        const SizedBox(height: 16),

                        _RatingSection(
                          prompt: prompt,
                          userId: currentUser.uid,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Sign in to rate this prompt',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 250.ms),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RatingSection extends ConsumerWidget {
  final PromptModel prompt;
  final String userId;

  const _RatingSection({required this.prompt, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (userId: userId, promptId: prompt.id);
    final userRatingAsync = ref.watch(_userRatingProvider(args));
    final firestoreService = ref.watch(firestoreServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);

    return userRatingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Failed to load rating'),
      data: (userRating) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userRating != null) ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'You rated this ${userRating.toInt()} star${userRating.toInt() == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Update your rating:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
              ],
              RatingBarWidget(
                initialRating: prompt.avgRating,
                userRating: userRating,
                readOnly: false,
                itemSize: 36,
                onRatingUpdate: (rating) async {
                  try {
                    await firestoreService.submitRating(
                      userId: userId,
                      promptId: prompt.id,
                      categoryId: prompt.categoryId,
                      rating: rating,
                    );
                    analyticsService.logEvent(
                      type: 'rating',
                      promptId: prompt.id,
                      promptTitle: prompt.title,
                      categoryId: prompt.categoryId,
                      categoryName: '',
                      userId: userId,
                      rating: rating,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                  'Thanks for rating ${rating.toInt()} star${rating.toInt() == 1 ? '' : 's'}!'),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to submit rating: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Tap a star to rate. Your rating helps others discover great prompts.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
