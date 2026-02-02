import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/share_card_options.dart';

/// A visually styled card widget for sharing stem text as an image
class ShareCardPreview extends StatelessWidget {
  final String stemText;
  final String? categoryName;
  final DateTime createdAt;
  final ShareCardOptions options;

  const ShareCardPreview({
    super.key,
    required this.stemText,
    this.categoryName,
    required this.createdAt,
    this.options = const ShareCardOptions(),
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: _buildDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (options.showCategory && categoryName != null) ...[
              _buildCategoryBadge(),
              const SizedBox(height: 16),
            ],
            _buildStemText(),
            if (options.showDate) ...[
              const SizedBox(height: 24),
              _buildDateText(),
            ],
            if (options.showAppBranding) ...[
              const SizedBox(height: 24),
              _buildBranding(),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final style = options.style;

    if (style.hasGradient) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.backgroundColor, style.gradientEndColor!],
        ),
        borderRadius: BorderRadius.circular(16),
      );
    }

    return BoxDecoration(
      color: style.backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: style == ShareCardStyle.minimal
          ? Border.all(color: Colors.grey.shade300)
          : null,
    );
  }

  Widget _buildCategoryBadge() {
    final style = options.style;
    final badgeColor = style == ShareCardStyle.minimal
        ? Colors.grey.shade200
        : style.textColor.withAlpha(51);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        categoryName!,
        style: TextStyle(
          color: style.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStemText() {
    final style = options.style;

    return Text(
      '$stemText...',
      style: TextStyle(
        color: style.textColor,
        fontSize: options.fontSize,
        fontWeight: FontWeight.w500,
        height: 1.4,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildDateText() {
    final style = options.style;
    final formattedDate = DateFormat.yMMMd().format(createdAt);

    return Text(
      formattedDate,
      style: TextStyle(
        color: style.textColor.withAlpha(179),
        fontSize: 14,
      ),
    );
  }

  Widget _buildBranding() {
    final style = options.style;

    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          color: style.textColor.withAlpha(153),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'Sentence Completion',
          style: TextStyle(
            color: style.textColor.withAlpha(153),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Widget for selecting share card style
class ShareCardStyleSelector extends StatelessWidget {
  final ShareCardStyle selectedStyle;
  final ValueChanged<ShareCardStyle> onStyleChanged;

  const ShareCardStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ShareCardStyle.values.length,
        itemBuilder: (context, index) {
          final style = ShareCardStyle.values[index];
          final isSelected = style == selectedStyle;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == ShareCardStyle.values.length - 1 ? 16 : 0,
            ),
            child: _StyleOption(
              style: style,
              isSelected: isSelected,
              onTap: () => onStyleChanged(style),
            ),
          );
        },
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final ShareCardStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleOption({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: style.hasGradient
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [style.backgroundColor, style.gradientEndColor!],
                    )
                  : null,
              color: style.hasGradient ? null : style.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : style == ShareCardStyle.minimal
                        ? Colors.grey.shade300
                        : Colors.transparent,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: style.textColor,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
