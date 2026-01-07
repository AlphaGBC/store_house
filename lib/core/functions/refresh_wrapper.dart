import 'dart:async';
import 'package:flutter/material.dart';

/// A reusable wrapper widget that adds pull-to-refresh capability
/// around any scrollable child, with optional auto-refresh.
class RefreshWrapper extends StatefulWidget {
  /// Callback that will be invoked when the user performs a pull-to-refresh
  /// or when auto-refresh triggers.
  final Future<void> Function() onRefresh;

  /// The scrollable content (e.g., ListView, GridView, CustomScrollView).
  final Widget child;

  /// Optional: customize the color of the refresh indicator (default uses theme).
  final Color? color;

  /// If true, automatically invokes [onRefresh] every [refreshInterval].
  final bool autoRefresh;

  /// Interval duration for auto-refresh (defaults to 30 seconds).
  final Duration refreshInterval;

  const RefreshWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.autoRefresh = false,
    this.refreshInterval = const Duration(seconds: 30),
  });

  @override
  State<RefreshWrapper> createState() => _RefreshWrapperState();
}

class _RefreshWrapperState extends State<RefreshWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoRefresh) {
      // Schedule periodic auto-refresh
      _timer = Timer.periodic(widget.refreshInterval, (timer) {
        widget.onRefresh();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: widget.color,
      onRefresh: widget.onRefresh,
      child: widget.child,
    );
  }
}
