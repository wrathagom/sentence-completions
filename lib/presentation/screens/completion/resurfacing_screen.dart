import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/services/resurfacing_service.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class ResurfacingScreen extends ConsumerStatefulWidget {
  final ResurfacingEntry resurfacingEntry;

  const ResurfacingScreen({
    super.key,
    required this.resurfacingEntry,
  });

  @override
  ConsumerState<ResurfacingScreen> createState() => _ResurfacingScreenState();
}

class _ResurfacingScreenState extends ConsumerState<ResurfacingScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSaving = false;
  bool _showPreviousAnswer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveCompletion() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final resurfacingService = ref.read(resurfacingServiceProvider);
      final entry = await resurfacingService.completeResurfacing(
        resurfacing: widget.resurfacingEntry,
        completion: _textController.text.trim(),
      );

      // Invalidate providers to refresh data
      ref.invalidate(pendingResurfacingProvider);
      ref.invalidate(entriesProvider);
      ref.invalidate(filteredEntriesProvider);

      if (mounted) {
        // Show comparison view
        context.go('/comparison/${entry.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  void _skipResurfacing() {
    // Just go home, the resurfacing will still be pending
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.resurfacingEntry.originalEntry;
    final monthsAgo = widget.resurfacingEntry.monthsAgo;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _skipResurfacing,
        ),
        title: const Text('Resurfacing'),
        actions: [
          TextButton(
            onPressed: _textController.text.trim().isEmpty || _isSaving
                ? null
                : _saveCompletion,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.replay,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You answered this $monthsAgo months ago. How would you answer today?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete this sentence:',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.stemText,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Write your new answer...',
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),
              if (!_showPreviousAnswer)
                TextButton.icon(
                  onPressed: () => setState(() => _showPreviousAnswer = true),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Peek at previous answer'),
                )
              else
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Your answer $monthsAgo months ago:',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.visibility_off, size: 20),
                              onPressed: () =>
                                  setState(() => _showPreviousAnswer = false),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.completion,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ResponsiveButton(
                child: FilledButton(
                  onPressed: _textController.text.trim().isEmpty || _isSaving
                      ? null
                      : _saveCompletion,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save & Compare'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
