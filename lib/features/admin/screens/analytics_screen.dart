import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/admin_provider.dart';

// ─────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────

final _dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(analyticsServiceProvider).getDashboardStats();
});

final _eventCountsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(analyticsServiceProvider).getEventCountsByType();
});

final _mostViewedProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(analyticsServiceProvider).getMostViewedPrompts(limit: 10);
});

final _mostSharedProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(analyticsServiceProvider).getMostSharedPrompts(limit: 5);
});

final _recentActivityProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(analyticsServiceProvider).getRecentActivity(limit: 20);
});

final _dailyActivityProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(analyticsServiceProvider).getDailyActivity(days: 7);
});

// ─────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/admin'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.analytics_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Analytics Dashboard',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── 1. Stats Row ──────────────────────────────────────
                _SectionTitle(title: 'Overview'),
                const SizedBox(height: 12),
                ref.watch(_dashboardStatsProvider).when(
                      loading: () => _ShimmerRow(count: 4),
                      error: (_, __) => const _ErrorChip(),
                      data: (stats) => _StatsRow(stats: stats),
                    ),

                const SizedBox(height: 28),

                // ── 2. Event Breakdown ────────────────────────────────
                _SectionTitle(title: 'Event Breakdown'),
                const SizedBox(height: 12),
                ref.watch(_eventCountsProvider).when(
                      loading: () => _ShimmerRow(count: 4, height: 72),
                      error: (_, __) => const _ErrorChip(),
                      data: (counts) => _EventBreakdown(counts: counts),
                    ),

                const SizedBox(height: 28),

                // ── 3. Most Viewed Prompts ────────────────────────────
                _SectionTitle(title: 'Most Viewed Prompts (Top 10)'),
                const SizedBox(height: 12),
                ref.watch(_mostViewedProvider).when(
                      loading: () => _ShimmerList(count: 5),
                      error: (_, __) => const _ErrorChip(),
                      data: (items) => items.isEmpty
                          ? const _EmptyDataState(
                              message: 'No view data yet.')
                          : _RankedList(items: items, type: 'view'),
                    ),

                const SizedBox(height: 28),

                // ── 4. Most Shared Prompts ────────────────────────────
                _SectionTitle(title: 'Most Shared Prompts (Top 5)'),
                const SizedBox(height: 12),
                ref.watch(_mostSharedProvider).when(
                      loading: () => _ShimmerList(count: 3),
                      error: (_, __) => const _ErrorChip(),
                      data: (items) => items.isEmpty
                          ? const _EmptyDataState(
                              message: 'No share data yet.')
                          : _RankedList(items: items, type: 'share'),
                    ),

                const SizedBox(height: 28),

                // ── 5. Daily Activity Bar Chart ───────────────────────
                _SectionTitle(title: 'Daily Activity (Last 7 Days)'),
                const SizedBox(height: 12),
                ref.watch(_dailyActivityProvider).when(
                      loading: () => const SizedBox(
                          height: 140,
                          child: Center(
                              child: CircularProgressIndicator())),
                      error: (_, __) => const _ErrorChip(),
                      data: (days) => _DailyBarChart(days: days),
                    ),

                const SizedBox(height: 28),

                // ── 6. Recent Activity Feed ───────────────────────────
                _SectionTitle(title: 'Recent Activity'),
                const SizedBox(height: 12),
                ref.watch(_recentActivityProvider).when(
                      loading: () => _ShimmerList(count: 5),
                      error: (_, __) => const _ErrorChip(),
                      data: (events) => events.isEmpty
                          ? const _EmptyDataState(
                              message: 'No activity yet.')
                          : _ActivityFeed(events: events),
                    ),

                const SizedBox(height: 40),
              ]),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────
// 1. STATS ROW
// ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
          label: 'Users',
          value: '${stats['totalUsers'] ?? 0}',
          icon: Icons.people_rounded,
          color: AppColors.primary),
      _StatItem(
          label: 'Prompts',
          value: '${stats['totalPrompts'] ?? 0}',
          icon: Icons.auto_awesome_rounded,
          color: AppColors.info),
      _StatItem(
          label: 'Views',
          value: '${stats['totalViews'] ?? 0}',
          icon: Icons.visibility_rounded,
          color: AppColors.success),
      _StatItem(
          label: 'Shares',
          value: '${stats['totalShares'] ?? 0}',
          icon: Icons.share_rounded,
          color: const Color(0xFF8B5CF6)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items
          .asMap()
          .entries
          .map((e) => _StatCard(item: e.value, animIndex: e.key))
          .toList(),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  final int animIndex;
  const _StatCard({required this.item, required this.animIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 22),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: item.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(item.label, style: theme.textTheme.bodySmall),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 * animIndex))
        .slideY(begin: 0.2, delay: Duration(milliseconds: 80 * animIndex));
  }
}

// ─────────────────────────────────────────────────────────────────
// 2. EVENT BREAKDOWN
// ─────────────────────────────────────────────────────────────────

class _EventBreakdown extends StatelessWidget {
  final Map<String, int> counts;
  const _EventBreakdown({required this.counts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (
        label: 'Views',
        count: counts['views'] ?? 0,
        icon: Icons.visibility_rounded,
        color: AppColors.info
      ),
      (
        label: 'Copies',
        count: counts['copies'] ?? 0,
        icon: Icons.copy_rounded,
        color: AppColors.success
      ),
      (
        label: 'Shares',
        count: counts['shares'] ?? 0,
        icon: Icons.share_rounded,
        color: const Color(0xFF8B5CF6)
      ),
      (
        label: 'Ratings',
        count: counts['ratings'] ?? 0,
        icon: Icons.star_rounded,
        color: AppColors.starActive
      ),
    ];

    return Row(
      children: items
          .map((item) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.color.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(item.icon, color: item.color, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        '${item.count}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: item.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        item.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 3 & 4. RANKED LIST
// ─────────────────────────────────────────────────────────────────

class _RankedList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String type;
  const _RankedList({required this.items, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: items.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final item = entry.value;
        final medalColors = [
          const Color(0xFFFFD700),
          const Color(0xFFC0C0C0),
          const Color(0xFFCD7F32),
        ];
        final isMedal = rank <= 3;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: isMedal
                    ? Icon(Icons.emoji_events_rounded,
                        color: medalColors[rank - 1], size: 22)
                    : Text(
                        '#$rank',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['promptTitle'] as String? ?? '',
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item['categoryName'] as String? ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (type == 'view' ? AppColors.info : const Color(0xFF8B5CF6))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item['count']}',
                  style: TextStyle(
                    color: type == 'view'
                        ? AppColors.info
                        : const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * entry.key));
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 5. DAILY BAR CHART
// ─────────────────────────────────────────────────────────────────

class _DailyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> days;
  const _DailyBarChart({required this.days});

  String _dayLabel(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final d = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return labels[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (days.isEmpty) {
      return const _EmptyDataState(message: 'No activity data yet.');
    }

    final maxCount = days
        .map((d) => (d['count'] as int?) ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    final effectiveMax = maxCount == 0 ? 1 : maxCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final count = (day['count'] as int?) ?? 0;
                final ratio = count / effectiveMax;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (count > 0)
                          Text(
                            '$count',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: (96 * ratio).clamp(4.0, 96.0),
                          decoration: BoxDecoration(
                            gradient: AppColors.headerGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: days.map((day) {
              return Expanded(
                child: Text(
                  _dayLabel(day['date'] as String? ?? ''),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 6. ACTIVITY FEED
// ─────────────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  const _ActivityFeed({required this.events});

  static final _typeConfig = {
    'view': (
      icon: Icons.visibility_rounded,
      label: 'Viewed',
      color: AppColors.info
    ),
    'copy': (
      icon: Icons.copy_rounded,
      label: 'Copied',
      color: AppColors.success
    ),
    'share': (
      icon: Icons.share_rounded,
      label: 'Shared',
      color: const Color(0xFF8B5CF6)
    ),
    'rating': (
      icon: Icons.star_rounded,
      label: 'Rated',
      color: AppColors.starActive
    ),
  };

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    try {
      final date = (ts as Timestamp).toDate();
      final diff = DateTime.now().difference(date);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: events.asMap().entries.map((entry) {
        final event = entry.value;
        final type = event['type'] as String? ?? 'view';
        final config = _typeConfig[type] ??
            (
              icon: Icons.circle,
              label: type,
              color: AppColors.textSecondary,
            );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(config.icon,
                    color: config.color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['promptTitle'] as String? ?? '',
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      config.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: config.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _timeAgo(event['timestamp']),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 30 * entry.key));
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHIMMER PLACEHOLDERS
// ─────────────────────────────────────────────────────────────────

class _ShimmerRow extends StatelessWidget {
  final int count;
  final double height;
  const _ShimmerRow({required this.count, this.height = 90});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  final int count;
  const _ShimmerList({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────

class _EmptyDataState extends StatelessWidget {
  final String message;
  const _EmptyDataState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.bar_chart_rounded,
              color: AppColors.textDisabled, size: 20),
          const SizedBox(width: 12),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}

class _ErrorChip extends StatelessWidget {
  const _ErrorChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Text(
            'Failed to load data',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
