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

class TreeLayoutService {
  static const double nodeWidth = 140.0;
  static const double nodeSpacing = 200.0;
  static const double levelSpacing = 280.0;

  Map<String, Offset> calculatePositions({
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
        node1.spouses.add(node2);
        node2.spouses.add(node1);
      }
    }

    final ownerNode = nodes[ownerId] ?? nodes.values.first;

    _assignLevels(ownerNode, nodes);
    _assignXCoordinates(nodes);

    return nodes.map((key, node) => MapEntry(key, node.position));
  }

  void _assignLevels(GraphNode root, Map<String, GraphNode> allNodes) {
    final Set<String> visited = {};
    final Queue<GraphNode> queue = Queue();

    root.level = 0;
    queue.add(root);
    visited.add(root.id);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      for (var parent in current.parents) {
        if (!visited.contains(parent.id)) {
          parent.level = current.level + 1;
          visited.add(parent.id);
          queue.add(parent);
        }
      }

      for (var child in current.children) {
        if (!visited.contains(child.id)) {
          child.level = current.level - 1;
          visited.add(child.id);
          queue.add(child);
        }
      }

      for (var spouse in current.spouses) {
        if (!visited.contains(spouse.id)) {
          spouse.level = current.level;
          visited.add(spouse.id);
          queue.add(spouse);
        }
      }
    }

    for (var node in allNodes.values) {
      if (!visited.contains(node.id)) {
        node.level = 0;
        node.x = 9999.0;
      }
    }
  }

  void _assignXCoordinates(Map<String, GraphNode> allNodes) {
    final Map<int, List<GraphNode>> levelGroups = {};
    for (var node in allNodes.values) {
      node.y = node.level * levelSpacing;
      levelGroups.putIfAbsent(node.level, () => []).add(node);
    }

    final sortedLevels = levelGroups.keys.toList()..sort();
    
    for (var level in sortedLevels) {
      final nodesInLevel = levelGroups[level]!;
      
      nodesInLevel.sort((a, b) {
        if (a.spouses.contains(b)) return -1;
        return a.id.compareTo(b.id);
      });

      for (var node in nodesInLevel) {
        if (node.level == 0 && node.parents.isEmpty && node.children.isEmpty) {
          node.x = 0;
        } else if (node.level > 0 && node.children.isNotEmpty) {
          final avgX = node.children.map((c) => c.x).reduce((a, b) => a + b) / node.children.length;
          node.x = avgX;
        } else if (node.level < 0 && node.parents.isNotEmpty) {
          final avgX = node.parents.map((p) => p.x).reduce((a, b) => a + b) / node.parents.length;
          node.x = avgX;
        } else if (node.spouses.isNotEmpty) {
          final placedSpouse = node.spouses.firstWhere((s) => s.x != 0.0, orElse: () => node.spouses.first);
          node.x = placedSpouse.x + nodeSpacing;
        }
      }

      nodesInLevel.sort((a, b) => a.x.compareTo(b.x));
      
      for (int i = 1; i < nodesInLevel.length; i++) {
        final prev = nodesInLevel[i - 1];
        final curr = nodesInLevel[i];
        
        final double requiredX = prev.x + nodeSpacing;
        if (curr.x < requiredX) {
          curr.x = requiredX;
        }
      }
      
      if (nodesInLevel.isNotEmpty) {
        final minX = nodesInLevel.first.x;
        final maxX = nodesInLevel.last.x;
        final shiftX = -(minX + maxX) / 2;
        for (var node in nodesInLevel) {
          node.x += shiftX;
        }
      }
    }
  }
}
