import 'package:flutter/material.dart';

import '../../core/responsive.dart';

/// A widget that centers and constrains content on larger screens.
///
/// On mobile screens (< 600px), this widget applies standard padding.
/// On tablet/desktop screens, it centers the content and applies a max-width.
class ResponsiveCenter extends StatelessWidget {
  /// The child widget to wrap
  final Widget child;

  /// Padding to apply around the content. Defaults to EdgeInsets.all(16.0)
  final EdgeInsetsGeometry padding;

  /// Whether to use a scrollable SingleChildScrollView
  final bool scrollable;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.maxContentWidth;

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    // On larger screens, constrain and center content
    if (maxWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    if (scrollable) {
      return SingleChildScrollView(child: content);
    }

    return content;
  }
}

/// A widget that constrains button width on larger screens.
///
/// On mobile screens, the button takes full width (like SizedBox with double.infinity).
/// On tablet/desktop screens, the button is constrained to [ButtonWidth.maxWidth]
/// and centered.
class ResponsiveButton extends StatelessWidget {
  /// The button widget to wrap
  final Widget child;

  const ResponsiveButton({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      // On mobile, full width
      return SizedBox(
        width: double.infinity,
        child: child,
      );
    }

    // On larger screens, constrain width and center
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ButtonWidth.maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}

/// A widget for creating responsive list views.
///
/// Centers the list content on larger screens while maintaining scroll behavior.
class ResponsiveListView extends StatelessWidget {
  /// Padding around the list
  final EdgeInsetsGeometry? padding;

  /// Number of items in the list
  final int itemCount;

  /// Builder for each item
  final Widget Function(BuildContext, int) itemBuilder;

  /// Optional separator builder
  final Widget Function(BuildContext, int)? separatorBuilder;

  const ResponsiveListView({
    super.key,
    this.padding,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.maxContentWidth;

    Widget listView;
    if (separatorBuilder != null) {
      listView = ListView.separated(
        padding: padding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder!,
      );
    } else {
      listView = ListView.builder(
        padding: padding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: listView,
        ),
      );
    }

    return listView;
  }
}
