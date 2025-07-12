import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableWidget extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext) builder;
  final RefreshController? refreshController;
  final Widget? header;
  final Widget? footer;
  final bool enablePullUp;
  final bool enablePullDown;

  const RefreshableWidget({
    super.key,
    required this.onRefresh,
    required this.builder,
    this.refreshController,
    this.header,
    this.footer,
    this.enablePullUp = false,
    this.enablePullDown = true,
  });

  @override
  State<RefreshableWidget> createState() => _RefreshableWidgetState();
}

class _RefreshableWidgetState extends State<RefreshableWidget> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = widget.refreshController ?? 
        RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    // Only dispose if we created the controller
    if (widget.refreshController == null) {
      _refreshController.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    try {
      await widget.onRefresh();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _handleRefresh,
      header: widget.header ?? const ClassicHeader(
        completeText: 'Refresh completed',
        refreshingText: 'Refreshing...',
        releaseText: 'Release to refresh',
        idleText: 'Pull down to refresh',
      ),
      footer: widget.footer,
      enablePullUp: widget.enablePullUp,
      enablePullDown: widget.enablePullDown,
      child: widget.builder(context),
    );
  }
}