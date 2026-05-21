import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../providers/requests_provider.dart';

class SubmitRequestScreen extends ConsumerStatefulWidget {
  const SubmitRequestScreen({super.key});

  @override
  ConsumerState<SubmitRequestScreen> createState() =>
      _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends ConsumerState<SubmitRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String _requestType = AppConstants.requestTypePrompt;
  CategoryModel? _selectedCategory;
  bool _submitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = ref.read(authStateProvider).asData?.value;
    final userModel = ref.read(currentUserModelProvider).asData?.value;

    if (user == null || userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a request.')),
      );
      return;
    }

    await ref.read(requestSubmitProvider.notifier).submitRequest(
          type: _requestType,
          userId: user.uid,
          userEmail: user.email ?? userModel.email,
          title: _titleController.text.trim(),
          details: _detailsController.text.trim(),
          categoryId: _requestType == AppConstants.requestTypePrompt
              ? _selectedCategory?.id
              : null,
        );

    final state = ref.read(requestSubmitProvider);
    if (state.hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _submitted = true);
    }
  }

  void _reset() {
    ref.read(requestSubmitProvider.notifier).reset();
    _titleController.clear();
    _detailsController.clear();
    setState(() {
      _requestType = AppConstants.requestTypePrompt;
      _selectedCategory = null;
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitState = ref.watch(requestSubmitProvider);
    final isLoading = submitState.isLoading;
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    if (_submitted) {
      return _SuccessView(onReset: _reset);
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Submit a Request',
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

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Request a new category or prompt. Our admins will review and add it to the vault.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // Request type selector
                  Text('Request Type',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ))
                      .animate()
                      .fadeIn(delay: 150.ms),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeButton(
                          label: 'New Prompt',
                          icon: Icons.auto_awesome_rounded,
                          isSelected:
                              _requestType == AppConstants.requestTypePrompt,
                          onTap: () => setState(() {
                            _requestType = AppConstants.requestTypePrompt;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TypeButton(
                          label: 'New Category',
                          icon: Icons.category_rounded,
                          isSelected:
                              _requestType == AppConstants.requestTypeCategory,
                          onTap: () => setState(() {
                            _requestType = AppConstants.requestTypeCategory;
                            _selectedCategory = null;
                          }),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 20),

                  // Category selector (for prompt requests)
                  if (_requestType == AppConstants.requestTypePrompt) ...[
                    Text('Category (optional)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ))
                        .animate()
                        .fadeIn(),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (categories) => DropdownButtonFormField<CategoryModel?>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          hintText: 'Select a category...',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: [
                          const DropdownMenuItem<CategoryModel?>(
                            value: null,
                            child: Text('No specific category'),
                          ),
                          ...categories.map(
                            (cat) => DropdownMenuItem<CategoryModel?>(
                              value: cat,
                              child: Text(cat.name),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val),
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 20),
                  ],

                  // Title
                  TextFormField(
                    controller: _titleController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText:
                          _requestType == AppConstants.requestTypeCategory
                              ? 'Category Name *'
                              : 'Prompt Title *',
                      hintText: _requestType == AppConstants.requestTypeCategory
                          ? 'e.g. Data Science & Analytics'
                          : 'e.g. Weekly Report Writer',
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Title is required';
                      if (v.trim().length < 3) return 'At least 3 characters';
                      if (v.trim().length > 100) return 'Max 100 characters';
                      return null;
                    },
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 16),

                  // Details
                  TextFormField(
                    controller: _detailsController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: _requestType == AppConstants.requestTypeCategory
                          ? 'Description & Why *'
                          : 'Prompt Text & Context *',
                      hintText: _requestType == AppConstants.requestTypeCategory
                          ? 'Describe the category and why it would be valuable...'
                          : 'Write the prompt text and explain its use case...',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    maxLines: 8,
                    minLines: 4,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Details are required';
                      if (v.trim().length < 20) return 'At least 20 characters';
                      if (v.trim().length > 2000) return 'Max 2000 characters';
                      return null;
                    },
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Submit Request'),
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onReset;

  const _SuccessView({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: AppColors.success,
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Request Submitted!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'Our admins will review your submission and add it to the vault if approved. Thank you for helping grow the library!',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Submit Another'),
            ).animate().fadeIn(delay: 400.ms),
          ],
            ),
          ),
        ),
      ),
    );
  }
}
