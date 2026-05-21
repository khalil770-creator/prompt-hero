import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/category/screens/category_detail_screen.dart';
import '../../features/prompt/screens/prompt_detail_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/manage_categories_screen.dart';
import '../../features/admin/screens/manage_prompts_screen.dart';
import '../../features/admin/screens/analytics_screen.dart';
import '../../features/admin/screens/review_requests_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isAdmin = ref.watch(isAdminProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isLoadingAuth = authState.isLoading;

      // Don't redirect while auth is loading
      if (isLoadingAuth) return null;

      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Redirect unauthenticated users to login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/login';
      }

      // Redirect logged-in users away from auth pages
      if (isLoggedIn && isOnAuthPage) {
        return '/';
      }

      // Protect admin routes
      if (state.matchedLocation.startsWith('/admin') && !isAdmin) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Category detail
      GoRoute(
        path: '/category/:categoryId',
        name: 'categoryDetail',
        builder: (context, state) => CategoryDetailScreen(
          categoryId: state.pathParameters['categoryId']!,
        ),
        routes: [
          // Prompt detail (nested under category)
          GoRoute(
            path: 'prompt/:promptId',
            name: 'promptDetail',
            builder: (context, state) => PromptDetailScreen(
              categoryId: state.pathParameters['categoryId']!,
              promptId: state.pathParameters['promptId']!,
            ),
          ),
        ],
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/categories',
        name: 'manageCategories',
        builder: (context, state) => const ManageCategoriesScreen(),
      ),
      GoRoute(
        path: '/admin/categories/:categoryId/prompts',
        name: 'managePrompts',
        builder: (context, state) => ManagePromptsScreen(
          categoryId: state.pathParameters['categoryId']!,
        ),
      ),
      GoRoute(
        path: '/admin/requests',
        name: 'reviewRequests',
        builder: (context, state) => const ReviewRequestsScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404 — Page not found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
