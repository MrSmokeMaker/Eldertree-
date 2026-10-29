import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/supabase_providers.dart';
import '../../data/models/subscription_model.dart';
import '../../data/models/enums.dart';

part 'subscription_controller.g.dart';

@Riverpod(keepAlive: true)
class SubscriptionController extends _$SubscriptionController {
  @override
  FutureOr<SubscriptionModel> build() async {
    final client = ref.watch(supabaseProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    try {
      final res = await client.from('subscriptions').select().eq('user_id', userId).single();
      return SubscriptionModel.fromJson(res);
    } catch (e) {
      return SubscriptionModel(id: 'temp', userId: userId, createdAt: DateTime.now(), tierLevel: TierLevel.free);
    }
  }

  bool canAddMember(int currentCount) {
    final tier = state.value?.tierLevel ?? TierLevel.free;
    if (tier == TierLevel.pro) return true;
    if (tier == TierLevel.standard) return currentCount < 100;
    return currentCount < 15;
  }

  bool get canUseAudio => (state.value?.tierLevel ?? TierLevel.free) == TierLevel.pro;
  bool get canExportPdf => (state.value?.tierLevel ?? TierLevel.free) == TierLevel.pro;
}
