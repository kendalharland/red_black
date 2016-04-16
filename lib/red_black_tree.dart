///
/// Copyright (c) 2015 Kendal Harland
///
///
/// A Red-Black tree implementation that provides a List-like interface.
library red_black.tree;

enum Color { RED, BLACK }

// TODO(kharland): move this to another package
class Pair<T> {
  final T first;
  final T second;
  Pair(this.first, this.second);
}

/// A Red Black Tree Node.
class RedBlackNode<T> {
  Color color;
  T value;

  /// The next item in the linked list.
  RedBlackNode<T> next;

  /// The previous item in the linked list.
  RedBlackNode<T> prev;

  /// The parent of this node.
  RedBlackNode<T> parent;

  /// The left child of this node.
  RedBlackNode<T> left;

  /// The right child of this node.
  RedBlackNode<T> right;

  RedBlackNode(this.value);
}

/// A Linked-List Red-Black tree implementation.
///
/// Insert and delete operations automatically update a node's position in the
/// linked list, resetting next and previous pointers accordingly.
///
/// Because this is a red-black tree, it is not guaranteed to be completely
/// balanced after write operations.
abstract class RedBlackTree<T> implements Iterable<T> {
  factory RedBlackTree() => new _RedBlackTreeImpl<T>();

  RedBlackTreeIterator<T> get inorderIterator;

  RedBlackTreeIterator<T> get preorderIterator;

  RedBlackTreeIterator<T> get postorderIterator;

  /// The root node of the tree.
  RedBlackNode<T> get root;

  /// The first node in the tree or null if the tree is empty.
  RedBlackNode<T> get head;

  /// The last node in the tree or null if the tree is empty.
  RedBlackNode<T> get tail;

  /// The [Comparator] used to order elements in the tree.
  Comparator<T> get comparator;
  set comparator(Comparator<T> value);

  /// The number of nodes in the tree.
  int get size;

  /// Finds [value] in the tree.
  ///
  /// If there is no node containing [value], the returned [Pair]'s first and
  /// last properties will be null.
  ///
  /// If a node containing [value] is found, the returned [Pair]'s first
  /// property will contain the parent node, and the second property will
  /// contain the node itself.
  Pair<RedBlackNode<T>> find(T value);

  /// Finds the location where [value] would be inserted into the tree.
  ///
  /// The first node of the returned [Pair] will contain the would-be parent
  /// of node of [value]'s node.  The second will be null.
  Pair<RedBlackNode<T>> findInsertionPoint(T value);

  /// Inserts [node] into the tree as a leaf.
  ///
  /// Insertions order nodes so that every value in a node's left subtree
  /// is strictly less than its value and every value in a node's right subtree
  /// is greater than or equal to its value.
  Pair<RedBlackNode<T>> insertNode(RedBlackNode<T> node);

  /// Inserts [node] after [after].
  ///
  /// The first node of the returned [Pair] will be the parent of [node] and
  /// the second will be [node].
  ///
  /// If [after] is null or [head] then [node] will become the new head of the
  /// list. If [after] is [tail], [node] will become the new tail of the list.
  ///
  /// It is recommeneded to use [insert] as this function allows you to violate
  /// the sorted order of the linked-list.
  Pair<RedBlackNode<T>> insertAfter(
      RedBlackNode<T> after, RedBlackNode<T> node);

  /// Removes [node] from the tree.
  ///
  /// If the nod[M`Âe is in the tree, the first node of the returned [Pair] will
  /// be the removed node. Otherwise first will be null.  The second will always
  /// be null.
  Pair<RedBlackNode<T>> removeNode(RedBlackNode<T> node);
}

/// RedBlackTree default implementation.
class _RedBlackTreeImpl<T> implements RedBlackTree<T> {
  static int _DEFAULT_COMPARATOR(T lhs, T rhs) {
    if (lhs < rhs) return -1;
    if (lhs > rhs) return 1;
    if (lhs == rhs) return 0;
  }

  /// Sentinel node to represent leaves.
  static final _NULL = new RedBlackNode<T>(null)..color = Color.BLACK;

  /// Keeps track of what nodes are in the tree.
  final Map<int, bool> _nodeRegistry = <int, Null>{};
  RedBlackNode<T> _root = _NULL;
  RedBlackNode<T> _head;
  RedBlackNode<T> _tail;

  Comparator<T> comparator = _DEFAULT_COMPARATOR;

  RedBlackNode<T> get root => _root;

  RedBlackNode<T> get head => _head;

  RedBlackNode<T> get tail => _tail;

  Comparator<T> get comparator => _comparator;

  @override
  Pair<RedBlackNode<T>> find(T value) {
    RedBlackNode<T> node = root;

    while (node != _NULL) {
      int result = comparator(value, node.value);
      if (result < 0) {
        node = node.left;
      } else if (result > 0) {
        node = node.right;
      } else if (result == 0) {
        return new Pair<RedBlackNode<T>>(node.parent, node);
      }
    }

    return new Pair<RedBlackNode<T>>(null, null);
  }

  @override
  Pair<RedBlackNode<T>> findInsertionPoint(T value) {
    RedBlackNode<T> node = root;
    RedBlackNode<T> parent = root;

    while (node != _NULL) {
      parent = node;
      int result = comparator(value, node.value);
      if (result < 0) {
        node = node.left;
      } else {
        node = node.right;
      }
    }

    return new Pair<RedBlackNode<T>>(parent, null);
  }

  Pair<RedBlackNode<T>> insertAfter(
      RedBlackNode<T> after, RedBlackNode<T> node) {
    RedBlackNode<T> before;

    node.left = node.right = node.parent = _NULL;

    node.next = node.prev = null;

    if (_root == _NULL) {
      _root = node;
      _head = _tail = _root;
      _root.color = Color.BLACK;
      return new Pair<RedBlackNode<T>>(null, _root);
    }

    // If before is null then [after] must be tail and as such cannot have
    // any nodes in its right subtree and cannot be a left child. So we set
    // [node] as the new tail as [after]'s right child.
    //
    // If before is not null but as no left child, we insert [node] as before's
    // left child.
    //
    // If before is not null and has a left child, then after does not have a
    // right child (if after did have right child, before would be the leftmost
    // node in after's right subtree and would have no left child) so we set
    // node as after's right child.
    if (after == null) {
      before = _head;
      node.next = before;
      before.prev = node;
      before.left = node;
      node.parent = before;
    } else {
      before = after.next;
      after.next = node;
      node.next = before;
      node.prev = after;
      if (before == null) {
        // after is tail
        assert(after.right == _NULL);
        after.right = node;
        node.parent = after;
      } else if (before.left == _NULL) {
        // before is in after's right subtree
        before.left = node;
        node.parent = before;
        before.prev = node;
      } else {
        // after is in before's left subtree
        assert(after.right == _NULL);
        after.right = node;
        node.parent = after;
        before.prev = node;
      }
    }

    if (node.prev == null) _head = node;
    if (node.next == null) _tail = node;

    node.color = Color.RED;
    _nodeRegistry[node.hashCode] = null;
    _fixupAfterInsertion(node);
    return new Pair<RedBlackNode<T>>(node.parent, node);
  }

  Pair<RedBlackNode<T>> insertNode(RedBlackNode<T> newNode) {
    Pair<RedBlackNode<T>> searchResult = findInsertionPoint(newNode.value);
    RedBlackNode<T> parent = searchResult.first;

    assert(searchResult.second == null);
    newNode.parent = parent;

    if (parent == _NULL) {
      _root = newNode;
      _head = _tail = _root;
    } else if (comparator(newNode.value, parent.value) < 0) {
      parent.left = newNode;
      newNode.prev = parent.prev;
      if (newNode.prev == null) {
        _head = newNode;
      } else {
        newNode.prev.next = newNode;
      }
      parent.prev = newNode;
      newNode.next = parent;
    } else {
      parent.right = newNode;
      newNode.next = parent.next;
      if (newNode.next == null) {
        _tail = newNode;
      } else {
        newNode.next.prev = newNode;
      }
      parent.next = newNode;
      newNode.prev = parent;
    }

    newNode.left = newNode.right = _NULL;
    newNode.color = Color.RED;
    _nodeRegistry[newNode.hashCode] = null;
    _fixupAfterInsertion(newNode);
    return new Pair<RedBlackNode<T>>(newNode.parent, newNode);
  }

  Pair<RedBlackNode<T>> removeNode(RedBlackNode<T> node) {
    if (!_containsNode(node)) {
      return new Pair<RedBlackNode<T>>(null, null);
    }
    _nodeRegistry.remove(node.hashCode);

    RedBlackNode<T> child;
    RedBlackNode<T> after = node;
    Color originalColor = after.color;

    if (node.prev == null) {
      _head = node.next;
    } else {
      node.prev.next = node.next;
    }

    if (node.next == null) {
      _tail = node.prev;
    } else {
      node.next.prev = node.prev;
    }

    if (node.left == _NULL) {
      child = node.right;
      _transplant(node, child);
    } else if (node.right == _NULL) {
      child = node.left;
      _transplant(node, child);
    } else {
      after = node.next;
      originalColor = after.color;
      child = after.right;
      if (after.parent == node) {
        child.parent = after;
      } else {
        _transplant(after, after.right);
        after.right = node.right;
        after.right.parent = after;
      }
      _transplant(node, after);
      after.left = node.left;
      after.left.parent = after;
      after.color = node.color;
    }

    node.parent = node.left = node.right = node.prev = node.next = null;

    if (originalColor == Color.BLACK) {
      _fixupAfterRemove(child);
    }
    return new NodePair(node, null);
  }

  // Fix any violations of the red-black properties caused by node after an
  // insertion.
  void _fixupAfterInsertion(RedBlackNode<T> node) {
    var parent = node.parent, grandparent, uncle;

    while (parent.color == Color.RED) {
      grandparent = parent.parent;
      if (parent == grandparent.left) {
        uncle = grandparent.right;
        if (uncle.color == Color.RED) {
          parent.color = Color.BLACK;
          uncle.color = Color.BLACK;
          grandparent.color = Color.RED;
          node = grandparent;
          parent = node.parent;
        } else {
          if (node == parent.right) {
            node = parent;
            _leftRotate(node);
            parent = node.parent;
          }
          parent.color = Color.BLACK;
          grandparent.color = Color.RED;
          _rightRotate(grandparent);
        }
      } else {
        uncle = grandparent.left;
        if (uncle.color == Color.RED) {
          parent.color = Color.BLACK;
          uncle.color = Color.BLACK;
          grandparent.color = Color.RED;
          node = grandparent;
          parent = node.parent;
        } else {
          if (node == parent.left) {
            node = parent;
            _rightRotate(node);
            parent = node.parent;
          }
          parent.color = Color.BLACK;
          grandparent.color = Color.RED;
          _leftRotate(grandparent);
        }
      }
    }

    _root.color = Color.BLACK;
  }

  // Fixes up a node that may violate red-black properties after a deletion
  void _fixupAfterRemove(RedBlackNode<T> node) {
    var parent, uncle;

    while (node != _root && node.color == Color.BLACK) {
      parent = node.parent;
      if (node == parent.left) {
        uncle = parent.right;
        if (uncle.color == Color.RED) {
          uncle.color = Color.BLACK;
          parent.color = Color.RED;
          _leftRotate(parent);
          uncle = parent.right;
        }
        if (uncle.left.color == Color.BLACK &&
            uncle.right.color == Color.BLACK) {
          uncle.color = Color.RED;
          node = parent;
        } else {
          if (uncle.right.color == Color.BLACK) {
            uncle.left.color = Color.BLACK;
            uncle.color = Color.RED;
            _rightRotate(uncle);
            uncle = parent.right;
          }
          uncle.color = parent.color;
          uncle.right.color = Color.BLACK;
          parent.color = Color.BLACK;
          _leftRotate(parent);
          node = _root;
        }
      } else {
        uncle = parent.left;
        if (uncle.color == Color.RED) {
          uncle.color = Color.BLACK;
          parent.color = Color.RED;
          _rightRotate(parent);
          uncle = parent.left;
        }
        if (uncle.left.color == Color.BLACK &&
            uncle.right.color == Color.BLACK) {
          uncle.color = Color.RED;
          node = parent;
        } else {
          if (uncle.left.color == Color.BLACK) {
            uncle.right.color = Color.BLACK;
            uncle.color = Color.RED;
            _leftRotate(uncle);
            uncle = parent.left;
          }
          uncle.color = parent.color;
          uncle.left.color = Color.BLACK;
          parent.color = Color.BLACK;
          _rightRotate(parent);
          node = _root;
        }
      }
    }
    node.color = Color.BLACK;
  }

  // Rotate [node] left, making its right child the new parent of the subtree
  // rooted at [node]. [node] will become the left child of this new subtree.
  void _leftRotate(RedBlackNode node) {
    var child = node.right;

    node.right = child.left;
    if (child.left != _NULL) {
      child.left.parent = node;
    }
    child.parent = node.parent;
    if (node.parent == _NULL) {
      _root = child;
    } else if (node == node.parent.left) {
      node.parent.left = child;
    } else {
      node.parent.right = child;
    }
    child.left = node;
    node.parent = child;
  }

  // Rotate [node] right, making its left child the new parent of the subtree
  // rooted at [node]. [node] will become the right child of this new subtree.
  void _rightRotate(RedBlackNode node) {
    var child = node.left;

    node.left = child.right;
    if (child.right != _NULL) {
      child.right.parent = node;
    }
    child.parent = node.parent;

    if (node.parent == _NULL) {
      _root = child;
    } else if (node == node.parent.left) {
      node.parent.left = child;
    } else {
      node.parent.right = child;
    }

    child.right = node;
    node.parent = child;
  }

  // replaces the _RedBlackTreeImpl rooted at existing with the
  //  _RedBlackTreeImpl rooted at [replacement].
  void _transplant(RedBlackNode<T> existing, RedBlackNode<T> replacement) {
    if (existing.parent == _NULL) {
      _root = replacement;
    } else if (existing == existing.parent.left) {
      existing.parent.left = replacement;
    } else {
      existing.parent.right = replacement;
    }
    replacement.parent = existing.parent;
  }

  // Returns true if [node] is in this tree.
  bool _containsNode(RedBlackNode<T> node) =>
      _nodeRegistry.containsKey(node.hashCode);
}
