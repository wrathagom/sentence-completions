import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';

/// A scaffold that makes the app bar and bottom bar transparent when at top,
/// and opaque when scrolled.
class ScrollAwareScaffold extends ConsumerStatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;

  const ScrollAwareScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
  });

  @override
  ConsumerState<ScrollAwareScaffold> createState() => _ScrollAwareScaffoldState();
}

class _ScrollAwareScaffoldState extends ConsumerState<ScrollAwareScaffold> {
  bool _isScrolled = false;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final scrolled = notification.metrics.pixels > 0;
      if (scrolled != _isScrolled) {
        setState(() {
          _isScrolled = scrolled;
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context).extension<AppThemeExtension>();
    final backgroundColor = themeExtension?.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Scaffold(
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        appBar: AppBar(
          leading: widget.leading,
          title: widget.titleWidget ?? (widget.title != null ? Text(widget.title!) : null),
          actions: widget.actions,
          backgroundColor: _isScrolled ? backgroundColor : Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: widget.body,
        bottomNavigationBar: widget.bottomNavigationBar != null
            ? Container(
                color: _isScrolled ? backgroundColor : Colors.transparent,
                child: widget.bottomNavigationBar,
              )
            : null,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
      ),
    );
  }
}
