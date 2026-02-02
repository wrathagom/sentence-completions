import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class OnboardingModeScreen extends ConsumerWidget {
  const OnboardingModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/welcome'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Mode',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'How would you like to use the app?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              _ModeCard(
                icon: Icons.book,
                title: 'Journal Mode',
                description:
                    'Your entries are stored locally and can be reviewed anytime. Great for tracking your personal growth over time.',
                recommended: true,
                onTap: () async {
                  await ref.read(settingsProvider.notifier).setPrivacyMode(false);
                  if (context.mounted) {
                    context.go('/onboarding/analytics');
                  }
                },
              ),
              const SizedBox(height: 16),
              _ModeCard(
                icon: Icons.lock,
                title: 'Private Mode',
                description:
                    'Entries are deleted after viewing. The resurfacing feature is disabled. Best for one-time reflections.',
                recommended: false,
                onTap: () async {
                  await ref.read(settingsProvider.notifier).setPrivacyMode(true);
                  if (context.mounted) {
                    context.go('/onboarding/analytics');
                  }
                },
              ),
              const Spacer(),
              Text(
                'You can change this later in Settings.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool recommended;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.recommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (recommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Recommended',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
