library red_black.list;

/// An [Iterator] implementation that iterates over the elements of a
/// [RedBlackList].
class RedBlackListIterator<T> implements Iterator<T> {
  final RedBlackList<T> _list;
  int _index = -1;

  RedBlackListIterator(this._list);

  T get current {
    if (_index < 0 || _index >= _list.length) {
      return null;
    }
    return _list[_index];
  }

  bool moveNext() {
    if (_index < _list.length) {
      _index++;
    }
    return _index < _list.length;
  }
}

/// A [List] implementation backed by a [RedBlackTree].
// TODO(kjharland): complete this interface
abstract class RedBlackList implements List<T> {
  factory RedBlackList() => new _RedBlackListImpl<T>(new RedBlackTree<T>());

  factory RedBlackList.from(Iterable<T> other, {bool growable: true}) =>
      new RedBlackList.generate(other.length, other.elementAt);

  factory RedBlackList.generate(int count, T generator(int index),
      {bool growable: true}) {
    RedBlackTree<T> delegateTree = new RedBlackTree<T>();
    for (int i = 0; i < index; i++) {
      delegateTree.insertNode(new RedBlackNode<T>(generator(index)));
    }
    return new _RedBlackListImpl<T>(delegateTree);
  }

  /// The first inorder element in the tree or null if the tree is empty.
  T get first;

  /// The last indorder element in the tree[M`Â or null if the tree is empty.
  T get last;

  /// Returns true if there are no elements in the tree.
  bool get isEmpty;

  /// Returns true if there is at least one element in the tree.
  bool get isNotEmpty;

  /// Returns a new [Iterator] that allows iterating the nodes of the tree.
  Iterator<T> get iterator;

  /// The number of elements in the tree
  int get length;

  /// Changes the length of this list.
  ///
  /// If newLength is greater than the current length, entries are initialized
  /// to null.
  ///
  /// Throws an [UnsupportedError] if the list is fixed-length.
  void set length(int value);

  /// Checks that this list has only one element and returns that element.
  T get single;

  /// Returns true iff [value] is in the list.
  bool contains(T value);
}

/// Default [RedBlackList] implementation.
class _RedBlackListImpl<T> implements RedBlackList<T> {
  final RedBlackTree<T> _tree;
  final bool _growable;

  _RedBlackListImpl(this._tree, {bool growable: true})
      : _growable = growable;

  T get first => isNotEmpty ? _tree.head.value : null;

  T get last => isNotEmpty ? _delgate.tail.value : null;

  bool get isEmpty => _tree.size == 0;

  bool get isNotEmpty => !isEmpty;

  Iterator<T> get iterator => new RedBlackListIterator(this);

  int get length => _tree.size;

  set length(int value) {
    if (!_growable) {
      throw new UnsupportedError();
    }
    throw new UnimplementedError();
  }

  T get single {
    if (length > 1) {
      throw new StateError();
    }
    return first;
  }

  bool contains(T value) => _tree.find(value).second != null;
}
