import 'dart:html';
import 'dart:math';

///The SelectionManager class is responsible for managing the selection state
///of items. It keeps track of the start and end indices of the selection
/// process, as well as whether the selection is in progress or not.
class SelectionManager {
  int _startIndex = -1;
  int _endIndex = -1;
  bool _isSelecting = true;

  List<bool> _selectedItems = [];

  /// Manages the selection state of items.
  SelectionManager();

  /// Initializes the selection manager with the specified count of items.
  void init({int count = 0}) {
    _selectedItems = List.generate(count, (index) => false);
  }

  /// Starts the selection process with the given index.
  void start(int index) {
    _startIndex = _endIndex = index;
    _isSelecting = !_selectedItems[index];
  }

  /// Updates the selection process with the given index.
  void update(int index) {
    _endIndex = index;
  }

  /// Ends the selection process and updates the selected items accordingly.
  void end() {
    for (int i = _minIndex; i <= _maxIndex; i++) {
      _selectedItems[i] = _isSelecting;
    }
    _startIndex = -1;
    _endIndex = -1;
  }

  /// Toggles the selection state of the item at the given index.
  void single(int index) {
    _selectedItems[index] = !_selectedItems[index];
  }

  /// Returns whether the item at the given index is selected.
  bool isItemSelected(int index) => (index >= _minIndex && index <= _maxIndex)
      ? _isSelecting
      : _selectedItems[index];

  /// Returns whether the selection process is in progress.
  bool get isDraggingSelect => _startIndex != -1 && _endIndex != -1;

  /// Returns the minimum index between the start and end indices.
  int get _minIndex => min(_startIndex, _endIndex);

  /// Returns the maximum index between the start and end indices.
  int get _maxIndex => max(_startIndex, _endIndex);
}
