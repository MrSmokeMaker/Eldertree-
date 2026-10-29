import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider глобального поискового запроса на холсте дерева.
final searchQueryProvider = StateProvider<String>((ref) => '');
