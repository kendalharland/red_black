library red_black_tree;

part 'red_black_tree_impl.dart';

/// Possible tree node colors.
enum Color { RED, BLACK }

/// Comparator function for instances of T.  
/// - Returns a value < 0 when [lhs] precedes [rhs].
/// - Returns a value > 0 when [rhs] precedes [lhs].
/// - Returns 0 when lhs and rhs are ordered equally.
typedef int Comparator(T lhs, T rhs);

/// A pair of [RedBlackNode]s. Used as the result of read/write operations on a
/// [RedBlackTree].
class NodePair<T> {
  final RedBlackNode<T> first;
  final RedBlackNode<T> second;
  NodePair(this.first, this.second);
}

/// A Red Black Tree Node.  Each node also represents a chain in a linked list.
/// Operations that read/write this node from/to a tree automatically set and 
/// reset node pointers.
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
/// Insert and delete operations automatically update an item's position in the 
/// linked list, resetting next and prev pointers accordingly. When ordering 
/// items in the tree, the item's < > and == operators are used.
/// 
/// Because this is a red-black tree, it is not guaranteed to be completely 
/// balanced after write operations. 
abstract class RedBlackTree<T> {
  /// Returns the sentinel node for representing leaves in the tree.
  static final NULL = new RedBlackNode<T>(null)..color = Color.BLACK;

  /// Factory constructor to return an instance of the default implementation
  factory RedBlackTree([Comparator comparator]) => 
    new _RedBlackTreeImpl<T>(comparator);

  /// Returns the root node in the tree.
  RedBlackNode<T> get root;

  /// Returns the head of the linked list.  When the list only has one element,
  /// that element is returned.
  RedBlackNode<T> get head;

  /// Returns the tail of the linked list.  When the list only has one element,
  /// that element is returned.
  RedBlackNode<T> get tail;

  /// TODO(kjharland): implement
  /// 
  /// Returns a deep copy of [other].  [other]'s [comparator] is also copied.
  RedBlackNode<T> clone(RedBlackTree<T> other);

  /// Finds and returns the node containing [value] if it exists. Otherwise
  /// returns null.
  NodePair<T> find(T value);

  /// Returns a NodePair representing a location for [value] to be inserted into
  /// the tree as a leaf. 
  /// 
  /// NodePair.first will contain the would-be parent of [value]'s node if it 
  /// were inserted into the tree. NodePair.second will be null.
  NodePair<T> findInsertionPoint(T value);

  /// Inserts [node] into the tree as a leaf.
  /// 
  /// Insertions order nodes so that every value in a node's left subtree
  /// is strictly less than its value and every value in a node's right subtree
  /// is greater than or equal to its value.
  NodePair<T> insert(RedBlackNode<T> node);

  /// Inserts [node] after [after] and returns a [NodePair] where first = the
  /// parent of [node] and second = [node].  
  /// 
  /// If [after] is null or [head] then [node] will become the new head of the 
  /// list. If [after] is [tail], [node] will become the new tail of the list.
  ///
  /// It is recommeneded to use [insert] as this function allows you to violate
  /// the sorted order of the linked-list.
  NodePair<T> insertAfter(RedBlackNode<T> after, RedBlackNode<T> node);

  /// Removes [node] from the tree.
  void remove(RedBlacNode<T> node);
}
