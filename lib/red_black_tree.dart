library segment_intersection.red_black_tree;

enum Color { RED, BLACK }

/// A Red Black Tree Node.
class RedBlackNode<T> {
  Color color;
  RedBlackNode<T> next;
  RedBlackNode<T> prev;
  RedBlackNode<T> parent;
  RedBlackNode<T> left;
  RedBlackNode<T> right;
  T value;

  RedBlackNode(this.value) 
    : color = Color.RED,
      next = null,
      prev = null,
      parent = null,
      left = null,
      right = null {}
}

/// A Linked-List Red-Black tree implementation.  
/// 
/// Insert and delete operations automatically update an item's position in the 
/// linked list. When ordering items in the tree, the item's < > and == 
/// operators are used instead of a comparator function.
/// 
/// Because this is a red-black tree, it is not guaranteed to be completely 
/// balanced after write operations.
class RedBlackTree<T> {
  /// Sentinel value used to represent null nodes
  static final NULL = new RedBlackNode(null)..color = Color.BLACK;

  RedBlackNode<T> _root = NULL;
  RedBlackNode<T> _head;
  RedBlackNode<T> _tail;

  /// Get the root node in the tree.
  RedBlackNode<T> get root => _root;

  /// Get the head of the linked list.
  RedBlackNode<T> get head => _head;

  /// Get the tail of the linked list.
  RedBlackNode<T> get tail => _tail;

  /// Inserts [node] into the tree after [after], updating list positions 
  /// accordingly. 
  /// 
  /// If after is null, [node] will be inserted at the head of the linked-list.
  /// If [after] is [tail], [node] becomes the new tail. 
  void insertAfter(RedBlackNode<T> after, RedBlackNode<T> node) {
    RedBlackNode<T> before;

    node.left = 
    node.right = 
    node.parent = NULL;

    node.next = 
    node.prev = null;

    /// There is no root node, set this new node as root, head and tail and 
    /// color it black.
    if (_root == NULL) {
      _root = node;
      _head = _tail = _root;
      _root.color = Color.BLACK;
      return;
    }

    /// If this node preceeds every node in the list, set it as head.
    /// 
    /// If [before] is null then [after] must be tail and as such cannot have
    /// any nodes in its right subtree. So we set [node] as the new tail as 
    /// [after]'s right child.
    /// 
    /// If [before] is not null but as no left child,we hOtherwise insert [node] between [after] and [before] resetting 
    /// parent pointers where necessary.
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
      if (before == null) { // after is tail
        assert(after.right == NULL);
        after.right = node;
        node.parent = after;
      } else if (before.left == NULL) {  // before is in after's right subtree
        before.left = node;
        node.parent = before;
        before.prev = node;
      } else { // after is in before's left subtree
        assert(after.right == NULL);
        after.right = node;
        node.parent = after;
        before.prev = node;
      }
    }
    
    if (node.prev == null) _head = node;
    if (node.next == null) _tail = node;
    node.color = Color.RED;
    _fixupAfterInsertion(node);
  }

  /// Inserts [item] into the tree.
  void insert(RedBlackNode<T> newNode) {
    var node = _root,
        parent = NULL;

    while (node != NULL) {
      parent = node;
      node = newNode.value < node.value
          ? node.left
          : node.right;
    }

    newNode.parent = parent;
    if (parent == NULL) {
      _root = newNode;
      _head = _tail = _root;
    } else if (newNode.value < parent.value) {
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

    newNode.left = newNode.right = NULL;
    newNode.color = Color.RED;
    _fixupAfterInsertion(newNode);
  }

  /// Removes the subtree rooted at [node]
  void delete(RedBlackNode<T> node) {
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

    if (node.left == NULL) {
      child = node.right;
      _transplant(node, child);
    } else if (node.right == NULL) {
      child = node.left;
      _transplant(node, child);
    } else {
      after = node.next; // inorder successor
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
      _fixupAfterDelete(child);
    }
  }

  // Fix any violations of the red-black properties caused by node after an insertion
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
  void _fixupAfterDelete(RedBlackNode<T> node) {
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
    if (child.left != NULL) {
      child.left.parent = node; 
    }
    child.parent = node.parent;
    if (node.parent == NULL) {
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
    if (child.right != NULL) {
      child.right.parent = node;
    }
    child.parent = node.parent;

    if (node.parent == NULL) {
      _root = child;
    } else if (node == node.parent.left) {
      node.parent.left = child;
    } else {
      node.parent.right = child;
    }

    child.right = node;
    node.parent = child;
  }

  // replaces the RedBlackTree rooted at existing with the RedBlackTree rooted 
  // at replacement.
  void _transplant(RedBlackNode<T> existing, RedBlackNode<T> replacement) {
    if (existing.parent == NULL) {
      _root = replacement;
    } else if (existing == existing.parent.left) {
      existing.parent.left = replacement;
    } else {
      existing.parent.right = replacement; 
    }
    replacement.parent = existing.parent;
  }
}
