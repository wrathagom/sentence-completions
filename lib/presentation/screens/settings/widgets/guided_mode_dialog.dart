import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/user_settings.dart';
import '../../../providers/providers.dart';

class GuidedModeDialog extends ConsumerStatefulWidget {
  final GuidedModeType currentMode;

  const GuidedModeDialog({
    super.key,
    required this.currentMode,
  });

  @override
  ConsumerState<GuidedModeDialog> createState() => _GuidedModeDialogState();
}

class _GuidedModeDialogState extends ConsumerState<GuidedModeDialog> {
  late GuidedModeType _selectedMode;
  final _apiKeyController = TextEditingController();
  bool _isTestingConnection = false;
  bool _hasExistingKey = false;
  String? _testResult;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
    _loadExistingKeyStatus();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingKeyStatus() async {
    final secureStorage = ref.read(secureStorageDatasourceProvider);
    final hasKey = await secureStorage.hasAnthropicApiKey();
    if (mounted) {
      setState(() {
        _hasExistingKey = hasKey;
      });
    }
  }

  Future<void> _testConnection() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty && !_hasExistingKey) {
      setState(() {
        _testResult = 'Please enter an API key';
      });
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _testResult = null;
    });

    try {
      final anthropicService = ref.read(anthropicServiceProvider);
      final keyToTest = apiKey.isNotEmpty
          ? apiKey
          : await ref.read(secureStorageDatasourceProvider).getAnthropicApiKey();

      if (keyToTest == null || keyToTest.isEmpty) {
        setState(() {
          _isTestingConnection = false;
          _testResult = 'No API key to test';
        });
        return;
      }

      final result = await anthropicService.validateApiKey(keyToTest);

      if (mounted) {
        setState(() {
          _isTestingConnection = false;
          _testResult = result.valid
              ? 'Connection successful!'
              : result.error ?? 'Invalid API key';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
          _testResult = 'Connection failed: $e';
        });
      }
    }
  }

  Future<void> _saveAndClose() async {
    // Save API key if entered and intelligent mode selected
    if (_selectedMode == GuidedModeType.intelligent) {
      final apiKey = _apiKeyController.text.trim();
      if (apiKey.isNotEmpty) {
        final secureStorage = ref.read(secureStorageDatasourceProvider);
        await secureStorage.setAnthropicApiKey(apiKey);
        ref.invalidate(hasApiKeyProvider);
      }
    }

    // Update guided mode type
    await ref.read(settingsProvider.notifier).setGuidedModeType(_selectedMode);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key'),
        content: const Text('Are you sure you want to delete the stored API key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final secureStorage = ref.read(secureStorageDatasourceProvider);
      await secureStorage.deleteAnthropicApiKey();
      ref.invalidate(hasApiKeyProvider);
      if (mounted) {
        setState(() {
          _hasExistingKey = false;
          _testResult = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guided Mode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Mode selection
              RadioGroup<GuidedModeType>(
                groupValue: _selectedMode,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMode = value;
                      _testResult = null;
                    });
                  }
                },
                child: Column(
                  children: GuidedModeType.values.map((mode) => RadioListTile<GuidedModeType>(
                    title: Text(mode.displayName),
                    subtitle: Text(mode.description),
                    value: mode,
                    contentPadding: EdgeInsets.zero,
                  )).toList(),
                ),
              ),

              // API key section for intelligent mode
              if (_selectedMode == GuidedModeType.intelligent) ...[
                const Divider(height: 32),
                Text(
                  'Anthropic API Key',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (_hasExistingKey) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('API key is configured')),
                      TextButton(
                        onPressed: _deleteApiKey,
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter a new key to replace it:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    hintText: 'sk-ant-...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _isTestingConnection ? null : _testConnection,
                      child: _isTestingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test Connection'),
                    ),
                    const SizedBox(width: 12),
                    if (_testResult != null)
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            color: _testResult!.contains('successful')
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your completion text will be sent to Anthropic\'s API to generate personalized suggestions. Your API key is stored securely on your device.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _selectedMode == GuidedModeType.intelligent &&
                            !_hasExistingKey &&
                            _apiKeyController.text.trim().isEmpty
                        ? null
                        : _saveAndClose,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
