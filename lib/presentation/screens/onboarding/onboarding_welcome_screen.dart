import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/services/import_service.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class OnboardingWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  ConsumerState<OnboardingWelcomeScreen> createState() => _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends ConsumerState<OnboardingWelcomeScreen> {
  bool _isImporting = false;

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
    });

    final importService = ref.read(importServiceProvider);
    final result = await importService.importFromFile();

    if (!mounted) return;

    setState(() {
      _isImporting = false;
    });

    if (result.success) {
      // Refresh providers
      ref.invalidate(entriesProvider);
      ref.invalidate(favoriteEntriesProvider);
      if (result.goalsImported > 0) {
        ref.invalidate(activeGoalsWithProgressProvider);
      }
      if (result.savedStemsImported > 0) {
        ref.invalidate(savedStemsProvider);
        ref.invalidate(savedStemCountProvider);
      }

      _showImportResultDialog(result);
    } else if (result.errorMessage != 'Import cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Import failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _showImportResultDialog(ImportResult result) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully imported ${result.entriesImported} '
              '${result.entriesImported == 1 ? 'entry' : 'entries'}.',
            ),
            if (result.goalsImported > 0) ...[
              const SizedBox(height: 8),
              Text('${result.goalsImported} ${result.goalsImported == 1 ? 'goal' : 'goals'} restored.'),
            ],
            if (result.savedStemsImported > 0) ...[
              const SizedBox(height: 8),
              Text('${result.savedStemsImported} saved ${result.savedStemsImported == 1 ? 'stem' : 'stems'} restored.'),
            ],
            if (result.settingsImported) ...[
              const SizedBox(height: 8),
              const Text('Your settings have been restored.'),
            ],
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${result.errors.length} entries could not be imported.',
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result.settingsImported) {
      // Settings were restored - mark onboarding complete and go to home
      await ref.read(settingsProvider.notifier).setOnboardingCompleted(true);
      ref.invalidate(settingsProvider);
      if (mounted) {
        context.go('/home');
      }
    } else {
      // No settings - continue with onboarding to set up mode
      context.go('/onboarding/mode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.edit_note,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to\nSentence Completion',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'A daily practice of self-reflection through completing meaningful sentences.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _FeatureItem(
                icon: Icons.today,
                title: 'Daily Practice',
                description: 'Complete one sentence stem each day',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.history,
                title: 'Resurfacing',
                description: 'Revisit your past answers after 3 and 6 months',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.lock_outline,
                title: 'Private & Secure',
                description: 'Your entries stay on your device',
              ),
              const Spacer(),
              ResponsiveButton(
                child: FilledButton(
                  onPressed: () {
                    context.go('/onboarding/mode');
                  },
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 12),
              ResponsiveButton(
                child: OutlinedButton.icon(
                  onPressed: _isImporting ? null : _importData,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(
                    _isImporting ? 'Importing...' : 'Import Existing Data',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
