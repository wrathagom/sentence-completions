import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class OnboardingAnalyticsScreen extends ConsumerWidget {
  const OnboardingAnalyticsScreen({super.key});

  Future<void> _completeOnboarding(
    BuildContext context,
    WidgetRef ref,
    bool analyticsEnabled,
  ) async {
    await ref.read(settingsProvider.notifier).setAnalyticsEnabled(analyticsEnabled);
    await ref.read(settingsProvider.notifier).setOnboardingCompleted(true);
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/mode'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help Improve the App',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Would you like to share anonymous usage data?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Anonymous Analytics',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _AnalyticsItem(
                        icon: Icons.check_circle_outline,
                        text: 'App usage patterns',
                        included: true,
                      ),
                      const SizedBox(height: 8),
                      _AnalyticsItem(
                        icon: Icons.check_circle_outline,
                        text: 'Feature popularity',
                        included: true,
                      ),
                      const SizedBox(height: 8),
                      _AnalyticsItem(
                        icon: Icons.check_circle_outline,
                        text: 'Crash reports',
                        included: true,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _AnalyticsItem(
                        icon: Icons.cancel_outlined,
                        text: 'Your written entries',
                        included: false,
                      ),
                      const SizedBox(height: 8),
                      _AnalyticsItem(
                        icon: Icons.cancel_outlined,
                        text: 'Personal information',
                        included: false,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ResponsiveButton(
                child: FilledButton(
                  onPressed: () => _completeOnboarding(context, ref, true),
                  child: const Text('Enable Analytics'),
                ),
              ),
              const SizedBox(height: 12),
              ResponsiveButton(
                child: OutlinedButton(
                  onPressed: () => _completeOnboarding(context, ref, false),
                  child: const Text('No Thanks'),
                ),
              ),
              const SizedBox(height: 8),
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

class _AnalyticsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool included;

  const _AnalyticsItem({
    required this.icon,
    required this.text,
    required this.included,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: included
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 12),
        Text(
          included ? 'Collected: $text' : 'Never collected: $text',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
