// Dependency injection registrations for core services
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_providers.dart';

export '../config/supabase_providers.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return ref.watch(supabaseProvider);
});
