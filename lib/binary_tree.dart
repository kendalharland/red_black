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
  /// Returns the successor to [node] in this traversal.
  BinaryTreeNode<T> next(BinaryTreeNode<T> node);
}

/// An [Iterator] implementation that iterates over the nodes in a
/// [BinaryTree].
class BinaryTreeIterator<T> implements Iterator<BinaryTreeNode<T>> {
  BinaryTreeTraversal<T> _traversalStrategy;
  BinaryTreeNode<T> _currentNode;

  BinaryTreeIterator(BinaryTree<T> tree, this._traversalStrategy) {
    _currentNode = _tree.root;
    _currentNode = _traversalStrategy.next(_currentNode);
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

  BinaryTreeNode<T> next(BinaryTreeNode<T> node) {
    if (node.left != null && !_visited.containsKey(node.left)) {
      return _leftmostChild(node.left);
    } else if (!_visited.containsKey(node)) {
      _visited[node] = null;
      return node;
    } else if (node.right != null && !_visited.containsKey(node.right)) {
      return _leftmostChild(node.right);
    } else {
      return node.parent;
    }
  }
}
