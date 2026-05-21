import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/prompt_model.dart';

class PromptFormDialog extends StatefulWidget {
  final String categoryId;
  final PromptModel? existingPrompt;
  final Future<void> Function(String title, String description, String text) onSave;

  const PromptFormDialog({
    super.key,
    required this.categoryId,
    this.existingPrompt,
    required this.onSave,
  });

  @override
  State<PromptFormDialog> createState() => _PromptFormDialogState();
}

class _PromptFormDialogState extends State<PromptFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _textController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingPrompt?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingPrompt?.description ?? '',
    );
    _textController = TextEditingController(
      text: widget.existingPrompt?.text ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _textController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existingPrompt != null;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 780),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Prompt' : 'New Prompt',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Prompt Title *',
                          hintText: 'e.g. Viral Blog Post Outline',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Title is required';
                          if (v.trim().length < 3) return 'At least 3 characters';
                          if (v.trim().length > 100) return 'Maximum 100 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Brief description of what this prompt does',
                          prefixIcon: Icon(Icons.description_rounded),
                        ),
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Description is required';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Prompt text area
                      TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Prompt Text *',
                          hintText:
                              'Write the full prompt here. Use [PLACEHOLDERS] for dynamic variables...',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 120),
                            child: Icon(Icons.edit_note_rounded),
                          ),
                        ),
                        maxLines: 10,
                        minLines: 6,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Prompt text is required';
                          if (v.trim().length < 20) return 'At least 20 characters';
                          if (v.trim().length > 3000) return 'Maximum 3000 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Character count
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _textController,
                        builder: (_, value, __) {
                          final count = value.text.length;
                          final isNearLimit = count > 2500;
                          return Text(
                            '${count}/3000 characters',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isNearLimit ? AppColors.warning : AppColors.textSecondary,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tip box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_rounded,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tip: Use [BRACKETS] for variables that users should fill in, e.g. [TOPIC], [AUDIENCE], [TONE].',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEdit ? 'Save Changes' : 'Add Prompt'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
