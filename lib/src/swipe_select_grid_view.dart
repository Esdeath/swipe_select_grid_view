import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'selectable_widget.dart';
import 'selection_manager.dart';

/// Signature for a function that builds a widget given a context, index, and selection state.
typedef WidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  bool selected,
);

/// A widget that provides swipe-to-select functionality for a grid view.
class SwipeSelectGridView extends StatefulWidget {
  /// The default scroll trigger height.
  static const double defaultScrollTriggerHeight = 100;

  /// Creates a [SwipeSelectGridView].
  ///
  /// The [scrollTriggerHeight], [scrollController], [triggerSelectionOnTap],
  /// [reverse], [primary], [physics],[shrinkWrap], [padding],
  /// [gridDelegate], and [itemBuilder] parameters must not be null.
  SwipeSelectGridView({
    Key? key,
    double? scrollTriggerHeight,
    ScrollController? scrollController,
    this.triggerSelectionOnTap = false,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  })  : scrollTriggerHeight = scrollTriggerHeight ?? defaultScrollTriggerHeight,
        scrollController = scrollController ?? ScrollController(),
        super(key: key);

  /// The height at which scrolling triggers selection.
  final double scrollTriggerHeight;

  /// The scroll controller for the grid view.
  final ScrollController scrollController;

  /// Determines whether tapping an item triggers selection.
  final bool triggerSelectionOnTap;

  /// Determines the order in which the items are traversed.
  final bool reverse;

  /// Whether this is the primary scroll view associated with the parent widget.
  final bool? primary;

  /// The physics of the scroll view.
  final ScrollPhysics? physics;

  /// Whether the scroll view should shrink-wrap its contents.
  final bool shrinkWrap;

  /// The padding around the grid view.
  final EdgeInsetsGeometry? padding;

  /// The delegate that controls the layout of the grid items.
  final SliverGridDelegate gridDelegate;

  /// The builder for constructing the grid items.
  final WidgetBuilder itemBuilder;

  /// The total number of grid items.
  final int? itemCount;

  /// Whether to automatically keep alive items that are off-screen.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each item with a repaint boundary.
  final bool addRepaintBoundaries;

  /// Whether to add semantic indexes to the grid items.
  final bool addSemanticIndexes;

  /// The maximum extent of the cache.
  final double? cacheExtent;

  /// The number of semantic children.
  final int? semanticChildCount;

  /// Determines the way drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  /// Determines how the scroll view dismisses the keyboard.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// The restoration ID to save and restore the scroll position.
  final String? restorationId;

  /// The clip behavior of the grid view.
  final Clip clipBehavior;

  @override
  State createState() => _SwipeSelectGridViewState();
}

/// The state for the [SwipeSelectGridView] widget.
class _SwipeSelectGridViewState extends State<SwipeSelectGridView> {
  /// The scroll
  /// The scroll controller associated with the grid view.
  ScrollController get _scrollController => widget.scrollController;

  /// Manages the selection state for the grid view.
  final _selectManager = SelectionManager();

  /// Stores the selectable elements in the grid view.
  final _elements = <SelectableElement?>{};

  /// Stores the details of the last drag update.
  LongPressMoveUpdateDetails? _lastDragUpdateDetails;

  @override
  void initState() {
    _selectManager.init(count: widget.itemCount ?? 0);

    // Add a listener to the scroll position after the frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (_scrollController.hasClients) {
        _scrollController.position.addListener(_handleScroll);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      _scrollController.position.removeListener(_handleScroll);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _handleSelectionStart,
      onLongPressMoveUpdate: _handleSelectionUpdate,
      onLongPressEnd: _handleSelectionEnd,
      child: GridView.builder(
        controller: _scrollController,
        itemCount: widget.itemCount,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        gridDelegate: widget.gridDelegate,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _handleOnTap(index),
            child: SelectableWidget(
              index: index,
              onMountElement: _elements.add,
              onUnmountElement: _elements.remove,
              child: widget.itemBuilder(
                context,
                index,
                _selectManager.isItemSelected(index),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Handles the start of a selection gesture.
  void _handleSelectionStart(LongPressStartDetails details) {
    int index = _findIndexOfSelectable(details.localPosition);
    if (index != -1) {
      setState(() => _selectManager.start(index));
    }
  }

  /// Handles the update of a selection gesture.
  void _handleSelectionUpdate(LongPressMoveUpdateDetails details) {
    if (!_isDragging) {
      return;
    }

    _lastDragUpdateDetails = details;
    int index = _findIndexOfSelectable(details.localPosition);
    if (index != -1) {
      setState(() => _selectManager.update(index));
    }

    _autoScroll(details);
  }

  /// Handles the end of a selection gesture.
  void _handleSelectionEnd(LongPressEndDetails details) {
    if (!_isDragging) {
      return;
    }

    _selectManager.end();
    _autoScrollStop();
  }

  /// Handles the tap on a grid item.
  void _handleOnTap(int index) {
    if (_isDragging) {
      return;
    }

    setState(() => _selectManager.single(index));
  }

  /// Finds the index of the selectable element at the given offset.
  int _findIndexOfSelectable(Offset offset) {
    final ancestor = context.findRenderObject();
    final element = _elements.firstWhere(
      (element) => element!.containsOffset(ancestor, offset),
      orElse: () => null,
    );
    return (element == null) ? -1 : element.widget.index;
  }

  /// Handles the scroll event of the grid view.
  void _handleScroll() {
    if (_lastDragUpdateDetails != null) {
      _handleSelectionUpdate(_lastDragUpdateDetails!);
    }
  }

  /// Automatically scrolls the grid view based on the gesture details.
  void _autoScroll(LongPressMoveUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    if (details.localPosition.dy < 100) {
      _autoScrollForward();
    } else if (details.localPosition.dy > box.size.height - 100) {
      _autoScrollBackward();
    } else {
      _autoScrollStop();
    }
  }

  /// Automatically scrolls the grid view forward.
  void _autoScrollForward() {
    final duration = _calculateScrollSpeed(0);
    _scrollController.animateTo(0, duration: duration, curve: Curves.linear);
  }

  /// Automatically scrolls the grid view backward.
  void _autoScrollBackward() {
    final duration =
        _calculateScrollSpeed(_scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: duration,
      curve: Curves.linear,
    );
  }

  /// Stops the auto-scrolling of the grid view.
  void _autoScrollStop() {
    _scrollController.animateTo(
      _currentPosition!,
      duration: Duration.zero,
      curve: Curves.linear,
    );
  }

  /// Calculates the scroll speed based on the target position.
  Duration _calculateScrollSpeed(double targetPosition) {
    final distance = (targetPosition - _currentPosition!).abs();
    final scrollDuration = (distance * 2).toInt();
    return Duration(milliseconds: scrollDuration);
  }

  /// Returns the current scroll position of the grid view.
  double? get _currentPosition =>
      _scrollController.hasClients ? _scrollController.offset : null;

  /// Returns whether a selection drag is in progress.
  bool get _isDragging => _selectManager.isDraggingSelect;
}
