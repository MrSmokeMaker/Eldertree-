import 'package:flutter_test/flutter_test.dart';
import 'package:family_tree_app/data/models/member_model.dart';
import 'package:family_tree_app/data/models/relationship_model.dart';
import 'package:family_tree_app/data/models/enums.dart';
import 'package:family_tree_app/features/tree_canvas/domain/services/tree_layout_service.dart';

void main() {
  group('TreeLayoutService', () {
    test('fans out children upward into canopy and parents downward into roots',
        () {
      final layoutService = TreeLayoutService();

      final founder = MemberModel(
        id: 'founder',
        treeId: 'tree-1',
        firstName: 'Иван',
        gender: Gender.male,
        createdAt: DateTime.now(),
      );

      final spouse = MemberModel(
        id: 'spouse',
        treeId: 'tree-1',
        firstName: 'Анна',
        gender: Gender.female,
        createdAt: DateTime.now(),
      );

      final child1 = MemberModel(
        id: 'child1',
        treeId: 'tree-1',
        firstName: 'Алексей',
        gender: Gender.male,
        createdAt: DateTime.now(),
      );

      final child2 = MemberModel(
        id: 'child2',
        treeId: 'tree-1',
        firstName: 'Мария',
        gender: Gender.female,
        createdAt: DateTime.now(),
      );

      final father = MemberModel(
        id: 'father',
        treeId: 'tree-1',
        firstName: 'Петр',
        gender: Gender.male,
        createdAt: DateTime.now(),
      );

      final mother = MemberModel(
        id: 'mother',
        treeId: 'tree-1',
        firstName: 'Ольга',
        gender: Gender.female,
        createdAt: DateTime.now(),
      );

      final members = [founder, spouse, child1, child2, father, mother];
      final rels = [
        RelationshipModel(
          id: 'r-spouse',
          member1Id: founder.id,
          member2Id: spouse.id,
          relationshipType: RelationshipType.spouse,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        RelationshipModel(
          id: 'r-child1',
          member1Id: founder.id,
          member2Id: child1.id,
          relationshipType: RelationshipType.parent,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        RelationshipModel(
          id: 'r-child2',
          member1Id: founder.id,
          member2Id: child2.id,
          relationshipType: RelationshipType.parent,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        RelationshipModel(
          id: 'r-father',
          member1Id: father.id,
          member2Id: founder.id,
          relationshipType: RelationshipType.parent,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        RelationshipModel(
          id: 'r-mother',
          member1Id: mother.id,
          member2Id: founder.id,
          relationshipType: RelationshipType.parent,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      final positions = layoutService.calculatePositions(
        ownerId: founder.id,
        members: members,
        relationships: rels,
      );

      // Founder at level 0: Y = 0
      expect(positions[founder.id]!.dy, 0.0);
      expect(positions[spouse.id]!.dy, 0.0);

      // Children grow upward into canopy (negative Y)
      expect(positions[child1.id]!.dy, lessThan(0.0));
      expect(positions[child2.id]!.dy, lessThan(0.0));
      // Children fan out horizontally (different X coordinates)
      expect(positions[child1.id]!.dx, isNot(equals(positions[child2.id]!.dx)));

      // Parents grow downward into roots (positive Y)
      expect(positions[father.id]!.dy, greaterThan(0.0));
      expect(positions[mother.id]!.dy, greaterThan(0.0));
      // Father and mother are separated horizontally
      expect(positions[father.id]!.dx, isNot(equals(positions[mother.id]!.dx)));
    });
  });
}
