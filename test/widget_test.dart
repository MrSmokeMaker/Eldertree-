import 'package:flutter_test/flutter_test.dart';
import 'package:family_tree_app/data/models/member_model.dart';
import 'package:family_tree_app/data/models/enums.dart';

void main() {
  test('MemberModel serialization and deserialization smoke test', () {
    final now = DateTime.now();
    final member = MemberModel(
      id: 'test-id-1',
      treeId: 'tree-1',
      firstName: 'John',
      lastName: 'Doe',
      gender: Gender.male,
      createdAt: now,
    );

    expect(member.firstName, equals('John'));
    expect(member.lastName, equals('Doe'));
    expect(member.gender, equals(Gender.male));

    final json = member.toJson();
    final fromJson = MemberModel.fromJson(json);

    expect(fromJson.id, equals(member.id));
    expect(fromJson.firstName, equals(member.firstName));
    expect(fromJson.lastName, equals(member.lastName));
  });
}
