import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation.dart';
import '../../../data/models/share_card_options.dart';
import '../../providers/providers.dart';
import '../../widgets/share_card_preview.dart';

class ShareCardScreen extends ConsumerStatefulWidget {
  final String entryId;

  const ShareCardScreen({
    super.key,
    required this.entryId,
  });

  @override
  ConsumerState<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends ConsumerState<ShareCardScreen> {
  ShareCardOptions _options = const ShareCardOptions();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(entryByIdProvider(widget.entryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Card'),
      ),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Entry not found'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview
                      Center(
                        child: ShareCardPreview(
                          stemText: entry.stemText,
                          categoryName: entry.categoryId,
                          createdAt: entry.createdAt,
                          options: _options,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Style selector
                      Text(
                        'Style',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ShareCardStyleSelector(
                        selectedStyle: _options.style,
                        onStyleChanged: (style) {
                          setState(() {
                            _options = _options.copyWith(style: style);
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Options
                      Text(
                        'Options',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildOptionSwitch(
                        'Show category',
                        _options.showCategory,
                        (value) {
                          setState(() {
                            _options = _options.copyWith(showCategory: value);
                          });
                        },
                      ),
                      _buildOptionSwitch(
                        'Show date',
                        _options.showDate,
                        (value) {
                          setState(() {
                            _options = _options.copyWith(showDate: value);
                          });
                        },
                      ),
                      _buildOptionSwitch(
                        'Show app branding',
                        _options.showAppBranding,
                        (value) {
                          setState(() {
                            _options = _options.copyWith(showAppBranding: value);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Font size slider
                      Text(
                        'Font Size',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Slider(
                        value: _options.fontSize,
                        min: 18,
                        max: 32,
                        divisions: 7,
                        label: _options.fontSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _options = _options.copyWith(fontSize: value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Share button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSharing ? null : () => _shareCard(entry.stemText),
                      icon: _isSharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.share),
                      label: Text(_isSharing ? 'Generating...' : 'Share'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _shareCard(String stemText) async {
    setState(() => _isSharing = true);

    try {
      final shareCardService = ref.read(shareCardServiceProvider);
      final entryAsync = ref.read(entryByIdProvider(widget.entryId));
      final entry = entryAsync.valueOrNull;

      if (entry == null) {
        _showError('Entry not found');
        return;
      }

      final cardWidget = ShareCardPreview(
        stemText: entry.stemText,
        categoryName: entry.categoryId,
        createdAt: entry.createdAt,
        options: _options,
      );

      final result = await shareCardService.captureAndShare(
        widget: MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: cardWidget),
            ),
          ),
        ),
        entryId: widget.entryId,
        shareText: '"$stemText..."',
      );

      if (!result.success && mounted) {
        _showError(result.error ?? 'Failed to generate image');
      } else if (mounted) {
        context.safePop();
      }
    } catch (e) {
      _showError('Error sharing: $e');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
