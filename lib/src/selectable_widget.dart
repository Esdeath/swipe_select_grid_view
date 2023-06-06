import 'package:flutter/material.dart';

typedef ElementUpdateCallback = void Function(SelectableElement);

/// Represents a selectable widget.
class SelectableWidget extends ProxyWidget {
  const SelectableWidget({
    Key? key,
    required this.index,
    required this.onMountElement,
    required this.onUnmountElement,
    required Widget child,
  }) : super(key: key, child: child);

  /// The index of the widget.
  final int index;

  /// Callback function called when the element is mounted.
  final ElementUpdateCallback onMountElement;

  /// Callback function called when the element is unmounted.
  final ElementUpdateCallback onUnmountElement;

  @override
  SelectableElement createElement() => SelectableElement(this);

  /// Creates an instance of the SelectableElement class.
}

/// Represents the element corresponding to the SelectableWidget.
class SelectableElement extends ProxyElement {
  SelectableElement(SelectableWidget widget) : super(widget);

  @override
  SelectableWidget get widget => super.widget as SelectableWidget;

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    widget.onMountElement.call(this);

    /// Calls the onMountElement callback function, passing this element as an argument.
  }

  @override
  void unmount() {
    widget.onUnmountElement.call(this);

    /// Calls the onUnmountElement callback function, passing this element as an argument.
    super.unmount();
  }

  /// Checks if the given offset is within the bounds of the element's render box.
  bool containsOffset(RenderObject? ancestor, Offset offset) {
    final box = renderObject as RenderBox;

    /// Retrieves the render box associated with the element.

    final rect = box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;

    /// Computes the global bounding box of the render box.

    return rect.contains(offset);

    /// Returns true if the rect contains the given offset, indicating the offset is within the element's bounds.
  }

  @override
  void notifyClients(ProxyWidget oldWidget) {
    /// Notifies clients of changes in the widget.
    /// This method is empty as it does not have any specific implementation.
    /// It can be overridden to provide custom behavior when notifying clients.
  }

}
