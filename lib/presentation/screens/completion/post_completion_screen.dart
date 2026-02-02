import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/ai_suggestion.dart';
import '../../../data/models/stem.dart';
import '../../../domain/services/intelligent_suggestion_service.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class PostCompletionScreen extends ConsumerStatefulWidget {
  final String entryId;

  const PostCompletionScreen({
    super.key,
    required this.entryId,
  });

  @override
  ConsumerState<PostCompletionScreen> createState() =>
      _PostCompletionScreenState();
}

class _PostCompletionScreenState extends ConsumerState<PostCompletionScreen> {
  SuggestionResult? _suggestionResult;
  bool _isLoading = true;
  final Set<String> _savedIds = {}; // Can be stem IDs or AI suggestion tempIds

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final entryRepository = ref.read(entryRepositoryProvider);
    final entry = await entryRepository.getEntryById(widget.entryId);

    if (entry == null) {
      if (mounted) {
        context.go('/home');
      }
      return;
    }

    final settings = ref.read(settingsProvider);
    final intelligentSuggestionService = ref.read(intelligentSuggestionServiceProvider);

    final result = await intelligentSuggestionService.getSuggestions(
      completion: entry.completion,
      stemText: entry.stemText,
      modeType: settings.guidedModeType,
      excludeStemId: entry.stemId,
    );

    // Save suggestions to the entry for later viewing
    if (result.suggestions.isNotEmpty) {
      final suggestionTexts = result.isAiGenerated
          ? result.aiSuggestions.map((s) => s.text).toList()
          : result.stems.map((s) => s.text).toList();
      await entryRepository.updateEntrySuggestions(widget.entryId, suggestionTexts);
      // Invalidate the entry provider so it picks up the new suggestions
      ref.invalidate(entryByIdProvider(widget.entryId));
    }

    if (mounted) {
      setState(() {
        _suggestionResult = result;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveStemForLater(Stem stem) async {
    final repository = ref.read(savedStemRepositoryProvider);
    await repository.saveStem(
      stem: stem,
      sourceEntryId: widget.entryId,
    );

    setState(() {
      _savedIds.add(stem.id);
    });

    ref.invalidate(savedStemsProvider);
    ref.invalidate(savedStemCountProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved for later'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveAiSuggestionForLater(AISuggestion suggestion) async {
    final repository = ref.read(savedStemRepositoryProvider);
    await repository.saveAiSuggestion(
      suggestion: suggestion,
      sourceEntryId: widget.entryId,
    );

    setState(() {
      _savedIds.add(suggestion.tempId);
    });

    ref.invalidate(savedStemsProvider);
    ref.invalidate(savedStemCountProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved for later'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _answerNow(Stem stem) {
    context.go('/completion', extra: {'stemId': stem.id});
  }

  void _answerAiSuggestionNow(AISuggestion suggestion) {
    context.go('/completion', extra: {'stemText': suggestion.text});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Entry Saved'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Generating personalized suggestions...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final result = _suggestionResult;
    final hasSuggestions = result != null && result.suggestions.isNotEmpty;
    final keywords = result?.keywords ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Entry Saved'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success message
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Entry saved!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            Text(
                              'Your reflection has been recorded.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Error/fallback notice
              if (result?.errorMessage != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result!.errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Extracted keywords (only for keyword-based mode)
              if (keywords.isNotEmpty && result?.isAiGenerated != true) ...[
                Text(
                  'Keywords from your reflection:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: keywords.take(10).map((keyword) {
                    return Chip(
                      label: Text(keyword),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Suggestions section
              if (hasSuggestions) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Continue reflecting?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (result.isAiGenerated)
                      Chip(
                        avatar: const Icon(Icons.auto_awesome, size: 14),
                        label: const Text('AI'),
                        labelStyle: Theme.of(context).textTheme.labelSmall,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  result.isAiGenerated
                      ? 'Here are personalized prompts based on your reflection:'
                      : 'Here are some related prompts you might find meaningful:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: result.isAiGenerated
                      ? _buildAiSuggestionsList(result.aiSuggestions)
                      : _buildStemSuggestionsList(result.stems),
                ),
              ] else
                const Expanded(
                  child: Center(
                    child: Text('No suggestions available'),
                  ),
                ),

              const SizedBox(height: 16),

              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/entry/${widget.entryId}'),
                      child: const Text('View Entry'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStemSuggestionsList(List<Stem> stems) {
    return ListView.separated(
      itemCount: stems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stem = stems[index];
        final isSaved = _savedIds.contains(stem.id);
        return _SuggestionCard(
          stemText: stem.text,
          isSaved: isSaved,
          onAnswerNow: () => _answerNow(stem),
          onSaveForLater: isSaved ? null : () => _saveStemForLater(stem),
        );
      },
    );
  }

  Widget _buildAiSuggestionsList(List<AISuggestion> suggestions) {
    return ListView.separated(
      itemCount: suggestions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final isSaved = _savedIds.contains(suggestion.tempId);
        return _SuggestionCard(
          stemText: suggestion.text,
          isSaved: isSaved,
          isAiGenerated: true,
          onAnswerNow: () => _answerAiSuggestionNow(suggestion),
          onSaveForLater: isSaved ? null : () => _saveAiSuggestionForLater(suggestion),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String stemText;
  final bool isSaved;
  final bool isAiGenerated;
  final VoidCallback onAnswerNow;
  final VoidCallback? onSaveForLater;

  const _SuggestionCard({
    required this.stemText,
    required this.isSaved,
    required this.onAnswerNow,
    this.onSaveForLater,
    this.isAiGenerated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stemText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAnswerNow,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Answer Now'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: isSaved
                      ? TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Saved'),
                        )
                      : TextButton.icon(
                          onPressed: onSaveForLater,
                          icon: const Icon(Icons.bookmark_border, size: 18),
                          label: const Text('Save Later'),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
