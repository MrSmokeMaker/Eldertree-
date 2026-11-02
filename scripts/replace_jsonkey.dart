// Temporary script to replace 'JsonKey.new' with 'JsonKey' in model files
import 'dart:io';

void main() async {
  final dir = Directory('lib/data/models');
  if (!await dir.exists()) {
    print('Models directory not found');
    return;
  }
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final original = await entity.readAsString();
      final updated = original.replaceAll('JsonKey.new', 'JsonKey');
      if (original != updated) {
        await entity.writeAsString(updated);
        print('Updated ${entity.path}');
      }
    }
  }
}
