import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/stem.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  final String? stemId;
  final String? categoryId;
  final String? stemText; // For AI-generated stems

  const CompletionScreen({
    super.key,
    this.stemId,
    this.categoryId,
    this.stemText,
  });

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  Stem? _stem;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRefreshing = false;
  final Set<String> _skippedStemIds = {};

  // Show refresh button only for "surprise me" mode (no specific stem/text)
  bool get _canRefresh => widget.stemId == null && widget.stemText == null;

  @override
  void initState() {
    super.initState();
    _loadStem();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadStem() async {
    Stem? stem;

    if (widget.stemText != null) {
      // Create a synthetic stem for AI-generated text
      stem = Stem(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: widget.stemText!,
        categoryId: 'ai_generated',
        keywords: const [],
        difficultyLevel: 1,
        isFoundational: false,
      );
    } else if (widget.stemId != null) {
      // Load specific stem by ID
      final stemRepository = ref.read(stemRepositoryProvider);
      stem = await stemRepository.getStemById(widget.stemId!);
    } else {
      // Get a random stem, optionally filtered by category
      final completionService = ref.read(completionServiceProvider);
      stem = await completionService.getStemForCompletion(
        categoryId: widget.categoryId,
      );
    }

    if (mounted) {
      setState(() {
        _stem = stem;
        _isLoading = false;
        _isRefreshing = false;
      });
      _focusNode.requestFocus();
    }
  }

  Future<void> _getAnotherStem() async {
    if (_stem != null) {
      _skippedStemIds.add(_stem!.id);
    }

    setState(() => _isRefreshing = true);

    final completionService = ref.read(completionServiceProvider);
    final stem = await completionService.getStemForCompletion(
      categoryId: widget.categoryId,
      excludeStemIds: _skippedStemIds,
    );

    if (mounted) {
      setState(() {
        _stem = stem;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _saveCompletion() async {
    if (_stem == null || _textController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final completionService = ref.read(completionServiceProvider);
      final entry = await completionService.saveCompletion(
        stem: _stem!,
        completion: _textController.text.trim(),
      );

      // If this stem was saved for later, remove it from saved stems
      final savedStemRepository = ref.read(savedStemRepositoryProvider);
      await savedStemRepository.deleteSavedStemByStemId(_stem!.id);

      // Invalidate providers to refresh data
      ref.invalidate(hasCompletedTodayProvider);
      ref.invalidate(todayEntryProvider);
      ref.invalidate(todayEntryCountProvider);
      ref.invalidate(entriesProvider);
      ref.invalidate(filteredEntriesProvider);
      ref.invalidate(savedStemsProvider);
      ref.invalidate(savedStemCountProvider);

      if (mounted) {
        final settings = ref.read(settingsProvider);
        if (settings.guidedModeEnabled) {
          context.go('/post-completion/${entry.id}');
        } else {
          context.go('/entry/${entry.id}');
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Complete'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stem == null
              ? const Center(child: Text('No stems available'))
              : SafeArea(
                  child: ResponsiveCenter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete this sentence:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _stem!.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                if (_canRefresh) ...[
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _isRefreshing ? null : _getAnotherStem,
                                      icon: _isRefreshing
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.refresh, size: 18),
                                      label: const Text("Not feeling it"),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Write your completion here...',
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveButton(
                          child: FilledButton(
                            onPressed:
                                _textController.text.trim().isEmpty || _isSaving
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
                                : const Text('Save Entry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
