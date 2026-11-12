import 'dart:collection';
import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/models/member_model.dart';
import '../../../../data/models/relationship_model.dart';
import '../../../../data/models/enums.dart';
import '../models/graph_node.dart';

part 'tree_layout_service.g.dart';

@riverpod
TreeLayoutService treeLayoutService(TreeLayoutServiceRef ref) {
  return TreeLayoutService();
}

class NodeLayoutInfo {
  final Offset position;
  final String branchSize; // 'large', 'medium', 'small'
  final bool isFlipped;

  const NodeLayoutInfo({
    required this.position,
    required this.branchSize,
    required this.isFlipped,
  });
}

class TreeLayoutService {
  static const double nodeWidth = 140.0;
  static const double nodeSpacing = 220.0;
  static const double spouseSpacing = 160.0;
  static const double levelSpacing = 280.0;

  Map<String, Offset> calculatePositions({
    required String ownerId,
    required List<MemberModel> members,
    required List<RelationshipModel> relationships,
  }) {
    return calculateLayout(
      ownerId: ownerId,
      members: members,
      relationships: relationships,
    ).map((key, info) => MapEntry(key, info.position));
  }

  Map<String, NodeLayoutInfo> calculateLayout({
    required String ownerId,
    required List<MemberModel> members,
    required List<RelationshipModel> relationships,
  }) {
    if (members.isEmpty) return {};

    final Map<String, GraphNode> nodes = {
      for (var m in members) m.id: GraphNode(m)
    };

    for (var rel in relationships) {
      final node1 = nodes[rel.member1Id];
      final node2 = nodes[rel.member2Id];
      if (node1 == null || node2 == null) continue;

      if (rel.relationshipType == RelationshipType.parent) {
        node1.children.add(node2);
        node2.parents.add(node1);
      } else if (rel.relationshipType == RelationshipType.spouse) {
        if (!node1.spouses.contains(node2)) node1.spouses.add(node2);
        if (!node2.spouses.contains(node1)) node2.spouses.add(node1);
      }
    }

    final ownerNode = nodes[ownerId] ?? nodes.values.first;

    _assignLevels(ownerNode, nodes);
    _assignTreeCoordinates(ownerNode, nodes);

    return nodes.map((key, node) {
      String size;
      if (node.level >= 1) {
        size = node.level >= 2 ? 'large' : 'medium';
      } else if (node.level == 0) {
        size = 'large';
      } else if (node.level == -1) {
        size = 'medium';
      } else {
        size = 'small';
      }

      return MapEntry(
        key,
        NodeLayoutInfo(
          position: node.position,
          branchSize: size,
          isFlipped: node.x < 0,
        ),
      );
    });
  }

  void _assignLevels(GraphNode root, Map<String, GraphNode> allNodes) {
    final Set<String> visited = {};
    final Queue<GraphNode> queue = Queue();

    root.level = 0;
    queue.add(root);
    visited.add(root.id);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      // Родители уходят вниз (к корням, положительный Y)
      for (var parent in current.parents) {
        if (!visited.contains(parent.id)) {
          parent.level = current.level + 1;
          visited.add(parent.id);
          queue.add(parent);
        }
      }

      // Потомки растут вверх (в крону, отрицательный Y)
      for (var child in current.children) {
        if (!visited.contains(child.id)) {
          child.level = current.level - 1;
          visited.add(child.id);
          queue.add(child);
        }
      }

      // Супруги остаются на том же уровне
      for (var spouse in current.spouses) {
        if (!visited.contains(spouse.id)) {
          spouse.level = current.level;
          visited.add(spouse.id);
          queue.add(spouse);
        }
      }
    }

    // Изолированные персоны (если есть)
    for (var node in allNodes.values) {
      if (!visited.contains(node.id)) {
        node.level = 0;
      }
    }
  }

  void _assignTreeCoordinates(GraphNode root, Map<String, GraphNode> allNodes) {
    // 1. Устанавливаем Y координаты: level * levelSpacing
    for (var node in allNodes.values) {
      node.y = node.level * levelSpacing;
      node.x = 0.0;
    }

    // 2. Размещение основания (Level 0) вокруг ствола
    final Set<String> placed = {};
    _placeFounderAndSpouse(root, placed);

    // Также размещаем других людей на 0 уровне, если они еще не размещены
    final level0Nodes = allNodes.values.where((n) => n.level == 0).toList();
    for (var n in level0Nodes) {
      if (!placed.contains(n.id)) {
        _placeFounderAndSpouse(n, placed);
      }
    }
    _resolveLevelCollisions(level0Nodes);

    // 3. Рост вверх в крону: уровень -1, -2, -3...
    final levelsUp = allNodes.values
        .map((n) => n.level)
        .where((l) => l < 0)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // -1, потом -2, потом -3...

    for (var lvl in levelsUp) {
      _layoutCanopyLevel(lvl, allNodes, placed);
    }

    // 4. Рост вниз к корням: уровень +1, +2, +3...
    final levelsDown = allNodes.values
        .map((n) => n.level)
        .where((l) => l > 0)
        .toSet()
        .toList()
      ..sort(); // 1, потом 2, потом 3...

    for (var lvl in levelsDown) {
      _layoutRootLevel(lvl, allNodes, placed);
    }

    // 5. Центрирование всего древа относительно основателя / корня (root)
    final rootCenterX =
        root.spouses.isNotEmpty ? (root.x + root.spouses.first.x) / 2 : root.x;
    for (var node in allNodes.values) {
      node.x -= rootCenterX;
    }
  }

  void _placeFounderAndSpouse(GraphNode node, Set<String> placed) {
    if (placed.contains(node.id)) return;

    if (node.spouses.isEmpty) {
      node.x = 0.0;
      placed.add(node.id);
    } else {
      final spouse = node.spouses.first;
      // Мужчина слева, женщина справа (традиция геральдических древ)
      if (node.member.gender == Gender.female) {
        spouse.x = -spouseSpacing / 2;
        node.x = spouseSpacing / 2;
      } else {
        node.x = -spouseSpacing / 2;
        spouse.x = spouseSpacing / 2;
      }
      placed.add(node.id);
      placed.add(spouse.id);

      // Дополнительные супруги (если есть) размещаются сбоку
      double nextRight = spouse.x + spouseSpacing;
      for (var s in node.spouses.skip(1)) {
        if (!placed.contains(s.id)) {
          s.x = nextRight;
          nextRight += spouseSpacing;
          placed.add(s.id);
        }
      }
    }
  }

  void _layoutCanopyLevel(
    int level,
    Map<String, GraphNode> allNodes,
    Set<String> placed,
  ) {
    final nodesAtLevel =
        allNodes.values.where((n) => n.level == level).toList();
    if (nodesAtLevel.isEmpty) return;

    // Группируем детей по их родительским парам / родителям
    final Map<String, List<GraphNode>> parentGroups = {};
    for (var child in nodesAtLevel) {
      if (child.parents.isNotEmpty) {
        final sortedParentIds = child.parents.map((p) => p.id).toList()..sort();
        final groupKey = sortedParentIds.join('_');
        parentGroups.putIfAbsent(groupKey, () => []).add(child);
      } else {
        parentGroups.putIfAbsent('orphan_${child.id}', () => []).add(child);
      }
    }

    for (var group in parentGroups.values) {
      double parentCenterX = 0.0;
      final parents = group.first.parents;
      if (parents.isNotEmpty) {
        parentCenterX =
            parents.map((p) => p.x).reduce((a, b) => a + b) / parents.length;
      }

      final count = group.length;
      const spread = nodeSpacing;
      for (int i = 0; i < count; i++) {
        final child = group[i];
        final offsetFromCenter = (i - (count - 1) / 2.0) * spread;
        child.x = parentCenterX + offsetFromCenter;
        placed.add(child.id);

        // Размещаем супруга ребенка, если он на том же уровне
        if (child.spouses.isNotEmpty) {
          for (var spouse in child.spouses) {
            if (spouse.level == level && !placed.contains(spouse.id)) {
              // Если ребенок слева от центра, супруг слева; если справа, супруг справа
              final dir = child.x < parentCenterX ? -1.0 : 1.0;
              spouse.x = child.x + dir * spouseSpacing;
              placed.add(spouse.id);
            }
          }
        }
      }
    }

    _resolveLevelCollisions(nodesAtLevel);
  }

  void _layoutRootLevel(
    int level,
    Map<String, GraphNode> allNodes,
    Set<String> placed,
  ) {
    final nodesAtLevel =
        allNodes.values.where((n) => n.level == level).toList();
    if (nodesAtLevel.isEmpty) return;

    // Группируем предков по их детям на предыдущем уровне
    final Map<String, List<GraphNode>> childrenGroups = {};
    for (var parent in nodesAtLevel) {
      if (parent.children.isNotEmpty) {
        for (var child in parent.children) {
          childrenGroups.putIfAbsent(child.id, () => []).add(parent);
        }
      } else {
        childrenGroups.putIfAbsent('single_${parent.id}', () => []).add(parent);
      }
    }

    for (var entry in childrenGroups.entries) {
      final childId = entry.key;
      final parents = entry.value.toSet().toList(); // Уникальные предки

      final childNode = allNodes[childId];
      final childX = childNode?.x ?? 0.0;

      if (parents.length == 1) {
        parents.first.x = childX;
        placed.add(parents.first.id);
      } else if (parents.length >= 2) {
        // Отец слева, мать справа
        parents.sort((a, b) {
          if (a.member.gender == Gender.male) return -1;
          if (b.member.gender == Gender.male) return 1;
          return 0;
        });

        parents[0].x = childX - spouseSpacing / 2;
        parents[1].x = childX + spouseSpacing / 2;
        placed.add(parents[0].id);
        placed.add(parents[1].id);

        for (int i = 2; i < parents.length; i++) {
          parents[i].x = parents[1].x + (i - 1) * spouseSpacing;
          placed.add(parents[i].id);
        }
      }
    }

    _resolveLevelCollisions(nodesAtLevel);
  }

  void _resolveLevelCollisions(List<GraphNode> nodes) {
    if (nodes.length <= 1) return;

    nodes.sort((a, b) => a.x.compareTo(b.x));

    for (int i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1];
      final curr = nodes[i];

      final double minDistance =
          (prev.spouses.contains(curr)) ? spouseSpacing : nodeSpacing;

      final double requiredX = prev.x + minDistance;
      if (curr.x < requiredX) {
        curr.x = requiredX;
      }
    }
  }
}
