import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/mood.dart';
import '../../providers/providers.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/responsive_scaffold.dart';

class MoodCheckScreen extends ConsumerStatefulWidget {
  final String entryId;

  const MoodCheckScreen({
    super.key,
    required this.entryId,
  });

  @override
  ConsumerState<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends ConsumerState<MoodCheckScreen> {
  Mood? _postMood;
  bool _isSaving = false;

  Future<void> _save() async {
    if (_postMood == null) return;

    setState(() => _isSaving = true);

    try {
      final entryRepository = ref.read(entryRepositoryProvider);
      final entry = await entryRepository.getEntryById(widget.entryId);

      if (entry != null) {
        final updatedEntry = entry.copyWith(postMoodValue: _postMood!.value);
        await entryRepository.updateEntry(updatedEntry);
        ref.invalidate(entriesProvider);
        ref.invalidate(entryByIdProvider(widget.entryId));
      }

      if (mounted) {
        final settings = ref.read(settingsProvider);
        if (settings.guidedModeEnabled) {
          context.go('/post-completion/${widget.entryId}');
        } else {
          context.go('/entry/${widget.entryId}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  void _skip() {
    final settings = ref.read(settingsProvider);
    if (settings.guidedModeEnabled) {
      context.go('/post-completion/${widget.entryId}');
    } else {
      context.go('/entry/${widget.entryId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(entryByIdProvider(widget.entryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: entryAsync.when(
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Entry not found'));
          }

          return SafeArea(
            child: ResponsiveCenter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      'How do you feel after reflecting?',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your emotional journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    MoodSelector(
                      selectedMood: _postMood,
                      onMoodSelected: (mood) {
                        setState(() => _postMood = mood);
                      },
                    ),
                    const Spacer(),
                    ResponsiveButton(
                      child: FilledButton(
                        onPressed: _postMood == null || _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
