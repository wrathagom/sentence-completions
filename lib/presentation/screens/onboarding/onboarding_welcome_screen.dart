import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/responsive_scaffold.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

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
