library red_black_tree_test;

import 'dart:math' show Random, max;
import 'package:test/test.dart';
import 'package:red_black_tree/red_black_tree.dart';

main () {
  redBlackTreeTest();
}

void redBlackTreeTest() {
  const int ITEM_COUNT = 10000;
  const int MAX_VALUE = 1000000;
  final redBlackTree = new RedBlackTree<int>();
  final random = new Random();
  List<RedBlackNode<int>> nodes;

  // TODO(kharland): Does this really verify all of the properties of a 
  // Red-Black tree's structure and color pattern?
  void verifyRedBlackPropertiesHold() {
    expect(redBlackTree.root.parent, equals(RedBlackTree.NULL));
    expect(redBlackTree.root.color, equals(Color.BLACK));
    verifyNodeColors();
  }

  void verifyNodeColors() {
    RedBlackNode<int> node = redBlackTree.head;
    while (node != null) {
      if (node.color == Color.RED) {
        expect(node.parent.color, equals(Color.BLACK));
      }
      node = node.next;
    }
  }

  group("RedBlackTree", () {
    setUp(() {
      nodes = new List<RedBlackNode<int>>.generate(ITEM_COUNT, (i) =>
        new RedBlackNode<int>(random.nextInt(MAX_VALUE)));
    });

    tearDown(() {
      verifyRedBlackPropertiesHold();
    });

    test(
        "find should return a NodePair where first -> the parent of the node "
        "containing the value, if the node exists and second -> the node itself"
        , () {
      RedBlackNode<int> node;
      NodePair<int> pair;
      int value;

      nodes.forEach(redBlackTree.insert);
      for (int i=0; i < ITEM_COUNT; i++) {
        value = nodes[random.nextInt(nodes.length)].value;
        pair = redBlackTree.find(value);
        expect(pair.second.parent, pair.first);
        expect(pair.second.value, equals(value));
      }
    });

    test(
        "find should return a NodePair where first = the last node visited and "
        "second = null if the given value is not in the tree", () {
      RedBlackNode<int> node;
      NodePair<int> pair;

      nodes.forEach(redBlackTree.insert);
      pair = redBlackTree.find(MAX_VALUE + 1);
      expect(pair.first, new isInstanceOf<RedBlackNode>());
      expect(pair.second, isNull);
    });

    test(
        "find insertion point should return NodePair where first = a node with"
        "at most one child and second = null", () {
      int item;
      nodes.forEach(redBlackTree.insert);

      for (int i=0; i < ITEM_COUNT/3; i++) {
        item = nodes[random.nextInt(nodes.length)].value;
        NodePair<int> pair = redBlackTree.findInsertionPoint(item);
        if (pair.first.left != RedBlackTree.NULL) {
          expect(pair.first.right, equals(RedBlackTree.NULL));
        } else if (pair.first.right != RedBlackTree.NULL) {
          expect(pair.first.left, equals(RedBlackTree.NULL));
        }
      }
    });

    test("insert should preserve ascending order of linked-list pointers", () {
      RedBlackNode<int> node = redBlackTree.head.next;

      nodes.forEach(redBlackTree.insert);
      while (node != null) {
        expect(node.prev.value, lessThanOrEqualTo(node.value));
        node = node.next;
      }
    });

    test("remove should preserve ascending order of linked-list pointers", () {
      RedBlackNode<int> node;
      int item;

      nodes.forEach(redBlackTree.insert);
      for (int i=0; i < ITEM_COUNT/3; i++) {
        item = nodes.removeAt(random.nextInt(nodes.length)).value;
        redBlackTree.remove(redBlackTree.find(item).second);
      }

      node = redBlackTree.head.next;
      while (node != null) {
        expect(node.prev.value, lessThanOrEqualTo(node.value));
        node = node.next;
      }
    });

    test("insertAfter should insert a node as the predecessor to another node."
      , () {
      RedBlackNode<int> after;
      RedBlackNode<int> prev;
      RedBlackNode<int> node;
      int value;

      redBlackTree.insert(nodes[0]);
      for (int i=1; i < ITEM_COUNT; i++) {
        node = nodes[i];
        redBlackTree.insertAfter(prev, node);
        prev = node;
      }
    });
  });
}
