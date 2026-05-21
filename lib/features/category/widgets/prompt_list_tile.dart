import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/share_utils.dart';
import '../../../models/prompt_model.dart';

class PromptListTile extends StatelessWidget {
  final PromptModel prompt;
  final bool isAdmin;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canMoveUp;
  final bool canMoveDown;
  final int animationIndex;

  const PromptListTile({
    super.key,
    required this.prompt,
    this.isAdmin = false,
    this.onMoveUp,
    this.onMoveDown,
    this.onEdit,
    this.onDelete,
    this.canMoveUp = true,
    this.canMoveDown = true,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.go('/category/${prompt.categoryId}/prompt/${prompt.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/category/${prompt.categoryId}/prompt/${prompt.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + admin controls
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          prompt.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        _AdminControls(
                          onMoveUp: canMoveUp ? onMoveUp : null,
                          onMoveDown: canMoveDown ? onMoveDown : null,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      ],
                    ],
                  ),

                  if (prompt.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      prompt.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Truncated prompt text
                  Text(
                    prompt.truncatedText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Tap to read more hint
                  Text(
                    'Tap to read more →',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom row: rating + actions
                  Row(
                    children: [
                      // Star rating display
                      if (prompt.ratingCount > 0) ...[
                        RatingBarIndicator(
                          rating: prompt.avgRating,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_rounded,
                            color: AppColors.starActive,
                          ),
                          unratedColor: AppColors.starInactive,
                          itemCount: 5,
                          itemSize: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${prompt.avgRating.toStringAsFixed(1)} (${prompt.ratingCount})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ] else
                        Text(
                          'No ratings yet',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),

                      const Spacer(),

                      // Copy button
                      _ActionIconButton(
                        icon: Icons.copy_rounded,
                        tooltip: 'Copy prompt',
                        onTap: () => ShareUtils.copyToClipboard(
                          context: context,
                          text: prompt.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // WhatsApp share button
                      _ActionIconButton(
                        icon: Icons.share_rounded,
                        tooltip: 'Share via WhatsApp',
                        color: const Color(0xFF25D366),
                        onTap: () => ShareUtils.shareViaWhatsApp(
                          context: context,
                          promptTitle: prompt.title,
                          promptText: prompt.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * animationIndex),
          duration: 350.ms,
        )
        .slideY(
          begin: 0.15,
          delay: Duration(milliseconds: 80 * animationIndex),
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _AdminControls extends StatelessWidget {
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AdminControls({
    this.onMoveUp,
    this.onMoveDown,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onMoveUp != null)
          _SmallIconButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: onMoveUp!,
            tooltip: 'Move up',
          ),
        if (onMoveDown != null)
          _SmallIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: onMoveDown!,
            tooltip: 'Move down',
          ),
        PopupMenuButton<String>(
          iconSize: 18,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('Edit', style: Theme.of(ctx).textTheme.bodyMedium),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 16, color: Colors.red.shade600),
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
            if (val == 'edit') onEdit?.call();
            if (val == 'delete') onDelete?.call();
          },
        ),
      ],
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _SmallIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
