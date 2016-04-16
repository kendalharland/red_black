///
/// Copyright (c) 2015 Kendal Harland
///
///
/// A Red-Black tree implementation that provides a List-like interface.
library red_black_tree;

part 'red_black_tree_impl.dart';

enum Color { RED, BLACK }

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
/// linked list, resetting next and prev pointers accordingly.
///
/// When ordering items in the tree, the item's < > and == operators are used.
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
  //[M`Á/ It is recommeneded to use [insert] as this function allows you to violate
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

