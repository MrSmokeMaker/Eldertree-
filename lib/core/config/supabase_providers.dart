import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}
