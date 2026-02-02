import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/entry_reaction.dart';
import '../../providers/providers.dart';
import '../../widgets/reaction_button.dart';

class AddReactionSheet extends ConsumerStatefulWidget {
  final String entryId;
  final List<EntryReaction> existingReactions;

  const AddReactionSheet({
    super.key,
    required this.entryId,
    required this.existingReactions,
  });

  static Future<void> show(
    BuildContext context,
    String entryId,
    List<EntryReaction> existingReactions,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddReactionSheet(
        entryId: entryId,
        existingReactions: existingReactions,
      ),
    );
  }

  @override
  ConsumerState<AddReactionSheet> createState() => _AddReactionSheetState();
}

class _AddReactionSheetState extends ConsumerState<AddReactionSheet> {
  late Set<ReactionType> _selectedReactions;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedReactions = widget.existingReactions
        .map((r) => r.reactionType)
        .toSet();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _toggleReaction(ReactionType type) async {
    final repository = ref.read(reactionRepositoryProvider);

    setState(() {
      if (_selectedReactions.contains(type)) {
        _selectedReactions.remove(type);
      } else {
        _selectedReactions.add(type);
      }
    });

    await repository.toggleReaction(
      entryId: widget.entryId,
      reactionType: type,
    );

    ref.invalidate(entryReactionsProvider(widget.entryId));
  }

  Future<void> _addNoteReaction() async {
    if (_noteController.text.trim().isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    final repository = ref.read(reactionRepositoryProvider);
    await repository.addReaction(
      entryId: widget.entryId,
      reactionType: ReactionType.insightful,
      note: _noteController.text.trim(),
    );

    ref.invalidate(entryReactionsProvider(widget.entryId));

    if (mounted) {
      _noteController.clear();
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'React to this entry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'How does this reflection make you feel now?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ReactionPicker(
              selectedReactions: _selectedReactions,
              onReactionToggle: _toggleReaction,
            ),
            const SizedBox(height: 24),
            Text(
              'Add a note (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Write a reflection on this entry...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSaving ? null : _addNoteReaction,
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
