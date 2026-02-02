import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../providers/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Sync stems if needed
      final stemRepository = ref.read(stemRepositoryProvider);
      final hasStems = await stemRepository.hasStems();
      if (!hasStems) {
        await stemRepository.syncStems();
      }

      // Check onboarding status
      final settings = ref.read(settingsProvider);

      if (!mounted) return;

      if (settings.onboardingCompleted) {
        // Check for pending resurfacing
        final resurfacing = await ref.read(pendingResurfacingProvider.future);
        if (!mounted) return;
        if (resurfacing.isNotEmpty) {
          context.go('/resurfacing', extra: {
            'resurfacingEntry': resurfacing.first,
          });
        } else {
          context.go('/home');
        }
      } else {
        if (!mounted) return;
        context.go('/onboarding/welcome');
      }
    } catch (e, stackTrace) {
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            if (_error != null) ...[
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Error: $_error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _initialize();
                },
                child: const Text('Retry'),
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
