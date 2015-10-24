part of red_black_tree;

/// RedBlackTree default implementation.
class RedBlackTreeImpl<T> implements RedBlackTree {
  /// Default comparator for instances of T.
  static final _DEFAULT_COMPARATOR = (T lhs, T rhs) {
    if (lhs < rhs) return -1;
    if (lhs > rhs) return 1;
    if (lhs == rhs) return 0;
  };

  /// Keeps track of what nodes are in the tree.  When removing a node, it is 
  /// useful to know if that node is actually in the tree.
  final Map<int, bool> _nodeRegistry = <int, Null>{};

  Comparator<T> _comparator;
  RedBlackNode<T> _root = RedBlackTree.NULL;
  RedBlackNode<T> _head;
  RedBlackNode<T> _tail;

  RedBlackTreeImpl(this._comparator) { 
    _comparator ??= _DEFAULT_COMPARATOR;
  }

  RedBlackNode<T> get root => _root;
  RedBlackNode<T> get head => _head;
  RedBlackNode<T> get tail => _tail;
  
  Comparator<T> get comparator => _comparator;

  bool contains(T value) => find(value).first != null;

  NodePair<T> find(T value) {
    RedBlackNode<T> node = root;

    //TODO(kharland): This could probably simpler
    while (node != RedBlackTree.NULL) {
      int result = comparator(value, node.value);
      if (result < 0) {
        node = node.left;
      } else if (result > 0) {
        node = node.right;
      } else if (result == 0) {
        return new NodePair<T>(node.parent, node);
      }
    }

    return new NodePair<T>(null, null);
  }

  NodePair<T> findInsertionPoint(T value) {
    RedBlackNode<T> node = root;
    RedBlackNode<T> parent = root;

    while (node != RedBlackTree.NULL) {
      parent = node;
      int result = comparator(value, node.value);
      if (result < 0) {
        node = node.left;
      } else {
        node = node.right;
      }
    }

    return new NodePair<T>(parent, null); 
  }

  NodePair<T> insertAfter(RedBlackNode<T> after, RedBlackNode<T> node) {
    RedBlackNode<T> before;

    node.left = 
    node.right = 
    node.parent = RedBlackTree.NULL;

    node.next = 
    node.prev = null;
    
    if (_root == RedBlackTree.NULL) {
      _root = node;
      _head = _tail = _root;
      _root.color = Color.BLACK;
      return new NodePair<T>(null, _root);
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
        assert(after.right == RedBlackTree.NULL);
        after.right = node;
        node.parent = after;
      } else if (before.left == RedBlackTree.NULL) {  
        // before is in after's right subtree
        before.left = node;
        node.parent = before;
        before.prev = node;
      } else { 
        // after is in before's left subtree
        assert(after.right == RedBlackTree.NULL);
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
    return new NodePair<T>(node.parent, node);
  }

  NodePair<T> insert(RedBlackNode<T> newNode) {
    NodePair<T> searchResult = findInsertionPoint(newNode.value);
    RedBlackNode<T> parent = searchResult.first;
    
    assert(searchResult.second == null);
    newNode.parent = parent;

    if (parent == RedBlackTree.NULL) {
      _root = newNode;
      _head = _tail = _root;
    } else if (comparator(newNode.value, parent.value) < 0) {
      parent.left = newNode;
      newNode.prev = parent.prev;
      if(newNode.prev == null) {
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

    newNode.left = newNode.right = RedBlackTree.NULL;
    newNode.color = Color.RED;
    _nodeRegistry[newNode.hashCode] = null;
    _fixupAfterInsertion(newNode);
    return new NodePair<T>(newNode.parent, newNode);
  }

  NodePair<T> remove(RedBlackNode<T> node) {
    if (!_containsNode(node)) {
      return new NodePair<T>(null, null);
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

    if (node.left == RedBlackTree.NULL) {
      child = node.right;
      _transplant(node, child);
    } else if (node.right == RedBlackTree.NULL) {
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

    node.parent = 
    node.left = 
    node.right =
    node.prev = 
    node.next = null;

    if (originalColor == Color.BLACK) {
      _fixupAfterRemove(child);
    }
    return new NodePair(node, null);
  }

  // Fix any violations of the red-black properties caused by node after an 
  // insertion.
  void _fixupAfterInsertion(RedBlackNode<T> node) {
    var parent = node.parent,
        grandparent,
        uncle;

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
    var parent,
        uncle;

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
    if (child.left != RedBlackTree.NULL) {
      child.left.parent = node; 
    }
    child.parent = node.parent;
    if (node.parent == RedBlackTree.NULL) {
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
    if (child.right != RedBlackTree.NULL) {
      child.right.parent = node;
    }
    child.parent = node.parent;

    if (node.parent == RedBlackTree.NULL) {
      _root = child;
    } else if (node == node.parent.left) {
      node.parent.left = child;
    } else {
      node.parent.right = child;
    }

    child.right = node;
    node.parent = child;
  }

  // replaces the _RedBlackTreeImpl rooted at existing with the _RedBlackTreeImpl rooted 
  // at replacement.
  void _transplant(RedBlackNode<T> existing, RedBlackNode<T> replacement) {
    if (existing.parent == RedBlackTree.NULL) {
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
