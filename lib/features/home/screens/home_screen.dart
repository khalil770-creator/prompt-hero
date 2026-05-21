import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ph_logo.dart';
import '../../../models/category_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../requests/screens/submit_request_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/home_provider.dart';
import '../widgets/category_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = ref.watch(bottomNavIndexProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final userModel = ref.watch(currentUserModelProvider).asData?.value;

    final screens = [
      const _HomeBody(),
      const SubmitRequestScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isAdmin ? _buildAdminDrawer(context) : null,
      body: IndexedStack(
        index: navIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navIndex,
          onDestinationSelected: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded),
              label: 'Request',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(color: AppColors.mint),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your prompts',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _drawerItem(
            context,
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          _drawerItem(
            context,
            icon: Icons.category_rounded,
            label: 'Manage Categories',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/categories');
            },
          ),
          _drawerItem(
            context,
            icon: Icons.reviews_rounded,
            label: 'Review Requests',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/requests');
            },
          ),
          _drawerItem(
            context,
            icon: Icons.analytics_rounded,
            label: 'Analytics',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/analytics');
            },
          ),
          const Divider(height: 24),
          _drawerItem(
            context,
            icon: Icons.home_rounded,
            label: 'Back to Home',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _HomeBody extends ConsumerStatefulWidget {
  const _HomeBody();

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final filteredCategories = ref.watch(filteredCategoriesProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // Hero header
        SliverToBoxAdapter(
          child: _buildHeroSection(context, ref, isAdmin),
        ),

        // Section title
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  searchQuery.isEmpty ? 'All Categories' : 'Search Results',
                  style: theme.textTheme.titleLarge,
                ),
                if (!categoriesAsync.isLoading)
                  Text(
                    '${filteredCategories.length} ${filteredCategories.length == 1 ? 'category' : 'categories'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
        ),

        // Categories grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: categoriesAsync.when(
            loading: () => SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ShimmerCategoryCard(),
                childCount: 6,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: _EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Something went wrong',
                subtitle: 'Could not load categories. Please try again.',
                iconColor: AppColors.error,
              ),
            ),
            data: (_) {
              if (filteredCategories.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.search_off_rounded,
                    title: searchQuery.isEmpty ? 'No Categories Yet' : 'No Results Found',
                    subtitle: searchQuery.isEmpty
                        ? 'Categories will appear here once added by an admin.'
                        : 'Try a different search term.',
                  ),
                );
              }
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final cat = filteredCategories[i];
                    return CategoryCard(
                      category: cat,
                      animationIndex: i,
                      onTap: () => context.go('/category/${cat.id}'),
                    );
                  },
                  childCount: filteredCategories.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref, bool isAdmin) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const PHWordmark(size: 18),
                  if (isAdmin)
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded,
                              color: Colors.white, size: 20),
                        ),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                        tooltip: 'Admin Panel',
                      ),
                    ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // Hero text — mint background with white text
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'A library of\n',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'well-crafted prompts.',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.08),

              const SizedBox(height: 10),

              Text(
                'Curated for Claude AI — ready to copy and use.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                  },
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerCategoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: iconColor ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
