library geometry.test.structure.red_black_tree_test.dart;

import 'dart:math' show Random, max;
import 'package:test/test.dart';
import 'package:geometry/structure/red_black_tree.dart';

main () {
  redBlackTreeTest();
}

void redBlackTreeTest() {
  const int ITEM_COUNT = 100000;
  const int VALUE_MAX = 1000000;
  final redBlackTree = new RedBlackTree<int>();
  final random = new Random();
  List<RedBlackNode<int>> items;

  void verifyNodeColors() {
    var node = redBlackTree.head;
    while (node != null) {
      if (node.color == Color.RED) {
        expect(node.parent.color, equals(Color.BLACK));
      }
      node = node.next;
    }
  }

  void verifyRedBlackPropertiesHold() {
    expect(redBlackTree.root.parent, equals(RedBlackTree.NULL));
    expect(redBlackTree.root.color, equals(Color.BLACK));
    verifyNodeColors();
  }

  group("RedBlackTree", () {
    setUp(() {
      items = new List<RedBlackNode<int>>.generate(ITEM_COUNT, (i) =>
        new RedBlackNode<int>(random.nextInt(VALUE_MAX)));
    });

    tearDown(() {
      verifyRedBlackPropertiesHold();
      items = null;
    });

    test("find should return the node containing a value if one exists", () {
      var value,
          node;
      items.forEach(redBlackTree.insert);
      for (int i=0; i < ITEM_COUNT; i++) {
        value = items[random.nextInt(items.length)].value;
        node = redBlackTree.find(value);
        expect(node, isNotNull);
        expect(node.value, equals(value));
      }
    });

    test("find should return null if the given value is not in the tree", () {
      var value,
          node;
      
      items.forEach(redBlackTree.insert);
      for (int i=0; i < ITEM_COUNT; i++) {
        value = random.nextInt(VALUE_MAX) + VALUE_MAX;
        node = redBlackTree.find(value);
        expect(node, isNull);
      }
    });

    test("remove should preserve ascending order of next pointers", () {
      var prev = redBlackTree.head,
          node = prev.next;

      items.forEach(redBlackTree.insert);
      for (int i=1; i < ITEM_COUNT; i++) {
        expect(prev.value, lessThanOrEqualTo(node.value));
        prev = node;
        node = node.next;
      }
    });

    test("remove should preserve ascending order of next pointers", () {
      items.forEach(redBlackTree.insert);
      for (int i=1; i < ITEM_COUNT/3; i++) {
        redBlackTree.delete(
          redBlackTree.find(
            items.removeAt(random.nextInt(items.length)).value));
      }

      var prev = redBlackTree.head,
          node = prev.next;

      for (int i=1; i < ITEM_COUNT; i++) {
        expect(prev.value, lessThanOrEqualTo(node.value));
        prev = node;
        node = node.next;
      }
    });

    test("insertAfter should insert a node after another node.", () {
      var after,
          prev,
          node,
          value;

      redBlackTree.insert(items[0]);
      for (int i=1; i < ITEM_COUNT; i++) {
        node = items[i];
        redBlackTree.insertAfter(prev, node);
        prev = node;
      }
    });
  });
}