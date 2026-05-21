import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/theme/app_colors.dart';

class RatingBarWidget extends StatelessWidget {
  final double initialRating;
  final double? userRating;
  final bool readOnly;
  final void Function(double)? onRatingUpdate;
  final double itemSize;
  final String? label;

  const RatingBarWidget({
    super.key,
    this.initialRating = 0,
    this.userRating,
    this.readOnly = false,
    this.onRatingUpdate,
    this.itemSize = 32,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        if (readOnly)
          RatingBarIndicator(
            rating: initialRating,
            itemBuilder: (context, _) => const Icon(
              Icons.star_rounded,
              color: AppColors.starActive,
            ),
            unratedColor: AppColors.starInactive,
            itemCount: 5,
            itemSize: itemSize,
          )
        else
          RatingBar.builder(
            initialRating: userRating ?? 0,
            minRating: 1,
            maxRating: 5,
            allowHalfRating: false,
            unratedColor: AppColors.starInactive,
            glow: false,
            itemBuilder: (context, _) => const Icon(
              Icons.star_rounded,
              color: AppColors.starActive,
            ),
            itemSize: itemSize,
            onRatingUpdate: onRatingUpdate ?? (_) {},
          ),
      ],
    );
  }
}

class CompactRatingDisplay extends StatelessWidget {
  final double avgRating;
  final int ratingCount;

  const CompactRatingDisplay({
    super.key,
    required this.avgRating,
    required this.ratingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (ratingCount == 0) {
      return Text(
        'No ratings yet',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textDisabled,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.starActive, size: 16),
        const SizedBox(width: 4),
        Text(
          avgRating.toStringAsFixed(1),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($ratingCount)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
