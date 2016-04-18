library red_black.binary_tree;

import 'package:red_black/binary_tree_iterator';
export 'package:red_black/binary_tree_iterator';

// TODO(kjharland): move this to another package

/// Interface for a binary tree.
abstract class BinaryTree<T> {}

/// Interface for a [BinaryTree] node.
abstract class BinaryTreeNode<T> {}

/// Defines a strategy for traversing a [BinaryTree].
abstract class BinaryTreeTraversal<T> {
  /// Returns the successor to [node] in this traversal or null if
  /// no such node exists.
  BinaryTreeNode<T> next(BinaryTreeNode<T> node);
}

/// An [Iterator] implementation that iterates over the nodes in a
/// [BinaryTree].
class BinaryTreeIterator<T> implements Iterator<BinaryTreeNode<T>> {
  BinaryTreeTraversal<T> _traversalStrategy;
  BinaryTreeNode<T> _currentNode;

  BinaryTreeIterator(BinaryTree<T> tree, this._traversalStrategy) {
    _currentNode = _traversalStrategy.next(_tree.root);
  }

  bool moveNext() {
    _currentNode = _traversalStrategy.next(_currentNode);
    return _currentNode != null;
  }

  BinaryTreeNode<T> get current => _currentNode;
}

/// A [BinaryTreeTraversal] that computes the inorder successor of a
/// [BinaryTreeNode].
class InorderTraversalStrategy<T> implements BinaryTreeTraversal<T> {
  final _visited = <BinaryTreeNode<T>, Null>{};

  static BinaryTreeNode<T> _leftmostChild(BinaryTreeNode<T> node) {
    while (node.left != null) {
      node = node.left;
    }
    return node;
  }

  // TODO(kharland): this won't work on trees that use sentinel values for
  // "null" nodes because `node == null` will never return true.
  BinaryTreeNode<T> next(BinaryTreeNode<T> node) {
    var next;
    if (node.left != null && !_visited.containsKey(node.left)) {
      next = _leftmostChild(node.left);
    } else if (!_visited.containsKey(node)) {
      next = node;
    } else if (node.right != null && !_visited.containsKey(node.right)) {
      next = _leftmostChild(node.right);
    } else {
      // Right child and leaf node - successor is first ancestor whose left
      // subtree contains [node].
      var parent = node.parent;
      var grandparent = parent.parent;
      while (parent != null && grandparent != null && parent != grandparent.left) {
        parent = grandparent;
        grandparent = parent.parent;
      } 
      next = parent;
    }

    if (next != null) {
     _visited[next] = null;
    }
    return next;
  }
}
