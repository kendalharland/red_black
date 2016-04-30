library red_black_tree_test;

/// !!! Tests are incomplete, use at your own risk !!!

import 'dart:math' show Random, max;
import 'package:test/test.dart';
import 'package:red_black/red_black_tree.dart';

main () {
  redBlackTreeTest();
}

void redBlackTreeTest() {
  const int ITEM_COUNT = 10000;
  const int MAX_VALUE = 1000000;
  final tree = new RedBlackTree<int>();
  final random = new Random();
  List<RedBlackNode<int>> nodes;

  void verifyNodeColors() {
    RedBlackNode<int> node = tree.head;
    while (node != null) {
      if (node.color == Color.RED) {
        expect(node.parent.color, equals(Color.BLACK));
      }
      node = node.next;
    }
  }

  // TODO(kharland): Does this really verify all of the properties of a 
  // Red-Black tree's structure and color pattern?
  void verifyRedBlackPropertiesHold() {
    expect(tree.isNullNode(tree.root.parent), isTrue); 
    expect(tree.root.color, equals(Color.BLACK));
    verifyNodeColors();
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
        "find should return a Pair where first is the parent of the node "
        "containing the search key and second is the node itself, if the node "
        "exists", () {
      RedBlackNode<int> node;
      Pair<int> pair;
      int value;

      nodes.forEach(tree.insertNode);
      for (int i=0; i < ITEM_COUNT; i++) {
        value = nodes[random.nextInt(nodes.length)].value;
        pair = tree.find(value);
        expect(pair.second.parent, pair.first);
        expect(pair.second.value, equals(value));
      }
    });

    test(
        "find should return a Pair where first and second are null if the "
        "given value is not in the tree", () {
      RedBlackNode<int> node;
      Pair<int> pair;

      nodes.forEach(tree.insertNode);
      pair = tree.find(MAX_VALUE + 1);
      expect(pair.first, isNull);
      expect(pair.second, isNull);
    });

    test(
        "findInsertionPoint should return a Pair where first is a node with"
        " at most one child and second is null", () {
      int item;
      nodes.forEach(tree.insertNode);

      for (int i=0; i < ITEM_COUNT/2; i++) {
        item = nodes[random.nextInt(nodes.length)].value;
        Pair<int> pair = tree.findInsertionPoint(item);
        if (!tree.isNullNode(pair.first.left)) {
          expect(tree.isNullNode(pair.first.right), isTrue);
        } else if (!tree.isNullNode(pair.first.right)) {
          expect(tree.isNullNode(pair.first.left), isTrue);
        }
      }
    });

    test("insert should preserve ascending order of linked-list pointers", () {
      RedBlackNode<int> node = tree.head.next;

      nodes.forEach(tree.insertNode);
      while (node != null) {
        expect(node.prev.value, lessThanOrEqualTo(node.value));
        node = node.next;
      }
    });

    test(
      "remove should return a Pair where first and second are null if the "
      "node is not in the tree.", () {
        RedBlackNode<int> node;

        nodes.forEach(tree.insertNode);
        node = new RedBlackNode<int>(MAX_VALUE + 1);
        var pair = tree.removeNode(node);
        expect(pair.first, isNull);
        expect(pair.second, isNull);
    });

    test("remove should preserve ascending order of linked-list pointers", () {
      RedBlackNode<int> node;
      int item;

      nodes.forEach(tree.insertNode);
      for (int i=0; i < ITEM_COUNT/2; i++) {
        item = nodes.removeAt(random.nextInt(nodes.length)).value;
        tree.removeNode(tree.find(item).second);
      }

      node = tree.head.next;
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

      tree.insertNode(nodes[0]);
      for (int i=1; i < ITEM_COUNT; i++) {
        node = nodes[i];
        tree.insertAfter(prev, node);
        prev = node;
      }
    });
  });
}
