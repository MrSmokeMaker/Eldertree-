
# Family Tree Application — Complete Project Codebase

---

**Файл:** `pubspec.yaml`
```yaml
name: family_tree_app
description: "Premium Interactive Family Tree App"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  supabase_flutter: ^2.6.0
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0

  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  cached_network_image: ^3.3.1
  audioplayers: ^6.1.0
  record: ^5.1.2
  flutter_svg: ^2.0.10
  google_fonts: ^6.2.1

  flutter_local_notifications: ^17.1.2
  timezone: ^0.9.4
  share_plus: ^10.0.0
  intl: any
  path_provider: ^2.1.3
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10

flutter:
  uses-material-design: true
  assets:
    - assets/textures/branch/
    - assets/particles/
    - assets/foliage/
    - assets/background/
    - assets/sounds/
```

---

**Файл:** `supabase/migrations/20231001000000_initial_schema.sql`
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE trees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tree_id UUID NOT NULL REFERENCES trees(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT,
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    birth_date DATE,
    death_date DATE,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member1_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    member2_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    relationship_type TEXT NOT NULL CHECK (relationship_type IN ('parent', 'spouse')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    end_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (member1_id, member2_id, relationship_type)
);

CREATE TABLE facts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK (category IN ('birthplace', 'occupation', 'trait', 'phrase', 'story', 'custom')),
    value TEXT NOT NULL,
    fact_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE timeline_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    event_date DATE,
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    audio_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tier_level TEXT NOT NULL CHECK (tier_level IN ('free', 'standard', 'pro')) DEFAULT 'free',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id)
);

ALTER TABLE trees ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE facts ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own trees" 
ON trees FOR ALL USING (auth.uid() = owner_id);

CREATE POLICY "Users can manage members of their trees" 
ON members FOR ALL USING (
    EXISTS (SELECT 1 FROM trees WHERE trees.id = members.tree_id AND trees.owner_id = auth.uid())
);

CREATE POLICY "Users can manage relationships" 
ON relationships FOR ALL USING (
    EXISTS (
        SELECT 1 FROM members 
        JOIN trees ON trees.id = members.tree_id 
        WHERE members.id = relationships.member1_id AND trees.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can manage facts" 
ON facts FOR ALL USING (
    EXISTS (
        SELECT 1 FROM members 
        JOIN trees ON trees.id = members.tree_id 
        WHERE members.id = facts.member_id AND trees.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can manage timeline events" 
ON timeline_events FOR ALL USING (
    EXISTS (
        SELECT 1 FROM members 
        JOIN trees ON trees.id = members.tree_id 
        WHERE members.id = timeline_events.member_id AND trees.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can manage own subscription" 
ON subscriptions FOR ALL USING (auth.uid() = user_id);

INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('media', 'media', true) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('audio', 'audio', false) ON CONFLICT DO NOTHING;

CREATE POLICY "Avatar images are publicly accessible." ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Users can upload avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update their avatars" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');
CREATE POLICY "Users can delete their avatars" ON storage.objects FOR DELETE USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Media images are publicly accessible." ON storage.objects FOR SELECT USING (bucket_id = 'media');
CREATE POLICY "Users can upload media" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'media' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update their media" ON storage.objects FOR UPDATE USING (bucket_id = 'media' AND auth.role() = 'authenticated');
CREATE POLICY "Users can delete their media" ON storage.objects FOR DELETE USING (bucket_id = 'media' AND auth.role() = 'authenticated');

CREATE POLICY "Users can manage audio" ON storage.objects FOR ALL USING (bucket_id = 'audio' AND auth.role() = 'authenticated');
```

---

**Файл:** `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/utils/notification_service.dart';

const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FamilyTreeApp(),
    ),
  );
}

class FamilyTreeApp extends ConsumerWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Family Tree',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4A3E),
          surface: const Color(0xFFF9F8F6),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFD4AF37),
          surface: const Color(0xFF0F1115),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
```

---

**Файл:** `lib/core/config/supabase_providers.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}
```

---

**Файл:** `lib/core/router/app_router.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/supabase_providers.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/tree_list/presentation/tree_list_screen.dart';
import '../../features/tree_canvas/presentation/tree_canvas_screen.dart';

part 'app_router.g.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final supabase = ref.watch(supabaseProvider);

  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.uri.path == '/auth';

      if (!isLoggedIn && !isAuthRoute) return '/auth';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const TreeListScreen(),
      ),
      GoRoute(
        path: '/canvas',
        builder: (context, state) => const TreeCanvasScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}
```

---

**Файл:** `lib/core/utils/export_service.dart`
```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportJsonToDevice(Map<String, dynamic> data, String treeName) async {
    final String jsonString = const JsonEncoder.withIndent('  ').convert(data);
    
    final Directory tempDir = await getTemporaryDirectory();
    final String sanitizedName = treeName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final String filePath = '${tempDir.path}/${sanitizedName}_backup.json';
    
    final File file = File(filePath);
    await file.writeAsString(jsonString);
    
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Family Tree Backup: $treeName',
    );
  }
}
```

---

**Файл:** `lib/core/utils/notification_service.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/member_model.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  final StreamController<String> _onNotificationTap = StreamController<String>.broadcast();
  Stream<String> get onNotificationTap => _onNotificationTap.stream;

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _onNotificationTap.add(response.payload!);
        }
      },
    );
  }

  Future<void> requestPermissionGently(BuildContext context) async {
    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Never miss a memory'),
        content: const Text(
          'Allow notifications so we can gently remind you about birthdays and important family anniversaries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> scheduleBirthdayNotification(MemberModel member) async {
    if (member.birthDate == null || member.deathDate != null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      member.birthDate!.month,
      member.birthDate!.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, now.year + 1, member.birthDate!.month, member.birthDate!.day, 9, 0);
    }

    final notificationId = member.id.hashCode;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'family_events',
      'Family Events',
      channelDescription: 'Reminders for birthdays and anniversaries',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      notificationId,
      'Birthday Today! 🎉',
      "It's ${member.firstName}'s birthday. Tap to listen to their voice capsules or record a new memory.",
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: member.id,
    );
  }
}
```

---

**Файл:** `lib/data/models/enums.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

enum Gender { male, female, other }

enum RelationshipType { parent, spouse }

enum FactCategory { birthplace, occupation, trait, phrase, story, custom }

enum TierLevel { free, standard, pro }
```

---

**Файл:** `lib/data/models/tree_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tree_model.freezed.dart';
part 'tree_model.g.dart';

@freezed
class TreeModel with _$TreeModel {
  const factory TreeModel({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TreeModel;

  factory TreeModel.fromJson(Map<String, dynamic> json) => _$TreeModelFromJson(json);
}
```

---

**Файл:** `lib/data/models/member_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'member_model.freezed.dart';
part 'member_model.g.dart';

@freezed
class MemberModel with _$MemberModel {
  const factory MemberModel({
    required String id,
    @JsonKey(name: 'tree_id') required String treeId,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') String? lastName,
    required Gender gender,
    @JsonKey(name: 'birth_date') DateTime? birthDate,
    @JsonKey(name: 'death_date') DateTime? deathDate,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) => _$MemberModelFromJson(json);
}
```

---

**Файл:** `lib/data/models/relationship_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'relationship_model.freezed.dart';
part 'relationship_model.g.dart';

@freezed
class RelationshipModel with _$RelationshipModel {
  const factory RelationshipModel({
    required String id,
    @JsonKey(name: 'member1_id') required String member1Id,
    @JsonKey(name: 'member2_id') required String member2Id,
    @JsonKey(name: 'relationship_type') required RelationshipType relationshipType,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RelationshipModel;

  factory RelationshipModel.fromJson(Map<String, dynamic> json) => _$RelationshipModelFromJson(json);
}
```

---

**Файл:** `lib/data/models/fact_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'fact_model.freezed.dart';
part 'fact_model.g.dart';

@freezed
class FactModel with _$FactModel {
  const factory FactModel({
    required String id,
    @JsonKey(name: 'member_id') required String memberId,
    required FactCategory category,
    required String value,
    @JsonKey(name: 'fact_date') DateTime? factDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FactModel;

  factory FactModel.fromJson(Map<String, dynamic> json) => _$FactModelFromJson(json);
}
```

---

**Файл:** `lib/data/models/timeline_event_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event_model.freezed.dart';
part 'timeline_event_model.g.dart';

@freezed
class TimelineEventModel with _$TimelineEventModel {
  const factory TimelineEventModel({
    required String id,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'event_date') DateTime? eventDate,
    required String title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'audio_url') String? audioUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TimelineEventModel;

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) => _$TimelineEventModelFromJson(json);
}
```

---

**Файл:** `lib/data/models/subscription_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'tier_level') @Default(TierLevel.free) TierLevel tierLevel,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => _$SubscriptionModelFromJson(json);
}
```

---

**Файл:** `lib/data/repositories/tree_repository.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_providers.dart';
import '../models/tree_model.dart';

part 'tree_repository.g.dart';

@riverpod
TreeRepository treeRepository(TreeRepositoryRef ref) {
  return TreeRepository(ref.watch(supabaseProvider));
}

class TreeRepository {
  final SupabaseClient _client;
  TreeRepository(this._client);

  Future<List<TreeModel>> getTrees() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client.from('trees').select().eq('owner_id', userId).order('created_at');
    return response.map((json) => TreeModel.fromJson(json)).toList();
  }

  Future<TreeModel> createTree(String name) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client.from('trees').insert({
      'owner_id': userId,
      'name': name,
    }).select().single();
    return TreeModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getTreeExportData(String treeId) async {
    final tree = await _client.from('trees').select().eq('id', treeId).single();
    final members = await _client.from('members').select().eq('tree_id', treeId);
    final memberIds = members.map((m) => m['id'] as String).toList();
    
    List<dynamic> relationships = [];
    List<dynamic> facts = [];
    List<dynamic> events = [];

    if (memberIds.isNotEmpty) {
      relationships = await _client.from('relationships').select().inFilter('member1_id', memberIds);
      facts = await _client.from('facts').select().inFilter('member_id', memberIds);
      events = await _client.from('timeline_events').select().inFilter('member_id', memberIds);
    }

    return {
      'export_date': DateTime.now().toIso8601String(),
      'tree': tree,
      'members': members,
      'relationships': relationships,
      'facts': facts,
      'timeline_events': events,
    };
  }
}
```

---

**Файл:** `lib/data/repositories/member_repository.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_providers.dart';

part 'member_repository.g.dart';

@riverpod
MemberRepository memberRepository(MemberRepositoryRef ref) {
  return MemberRepository(ref.watch(supabaseProvider));
}

class MemberRepository {
  final SupabaseClient _client;
  MemberRepository(this._client);

  Future<void> deleteMember(String memberId) async {
    final member = await _client.from('members').select('avatar_url').eq('id', memberId).single();
    
    final avatarUrl = member['avatar_url'] as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        final path = avatarUrl.split('avatars/').last;
        await _client.storage.from('avatars').remove([path]);
      } catch (_) {}
    }

    await _client.from('members').delete().eq('id', memberId);
  }
}
```

---

**Файл:** `lib/features/auth/auth_controller.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/supabase_providers.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseProvider).auth.signInWithPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseProvider).auth.signUp(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseProvider).auth.signOut();
    });
  }
}
```

---

**Файл:** `lib/features/auth/presentation/auth_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    if (_isLogin) {
      ref.read(authControllerProvider.notifier).signIn(email, password);
    } else {
      ref.read(authControllerProvider.notifier).signUp(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          },
        );
      },
    );

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isLogin ? 'Welcome Back' : 'Create Archive',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isLogin ? 'Sign In' : 'Sign Up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
                    ? 'Need an account? Sign Up'
                    : 'Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

**Файл:** `lib/features/tree_list/current_tree_controller.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/tree_model.dart';

part 'current_tree_controller.g.dart';

@Riverpod(keepAlive: true)
class CurrentTreeController extends _$CurrentTreeController {
  @override
  TreeModel? build() {
    return null;
  }

  void setTree(TreeModel tree) {
    state = tree;
  }
}
```

---

**Файл:** `lib/features/tree_list/tree_list_controller.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/tree_model.dart';
import '../../data/repositories/tree_repository.dart';

part 'tree_list_controller.g.dart';

@riverpod
class TreeListController extends _$TreeListController {
  @override
  FutureOr<List<TreeModel>> build() async {
    return ref.watch(treeRepositoryProvider).getTrees();
  }

  Future<void> createTree(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(treeRepositoryProvider).createTree(name);
      return ref.read(treeRepositoryProvider).getTrees();
    });
  }
}
```

---

**Файл:** `lib/features/tree_list/presentation/tree_list_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_controller.dart';
import '../../../core/utils/export_service.dart';
import '../../../data/repositories/tree_repository.dart';
import '../tree_list_controller.dart';
import '../current_tree_controller.dart';

class TreeListScreen extends ConsumerWidget {
  const TreeListScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Tree'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g., The Smiths Family'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(treeListControllerProvider.notifier).createTree(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTree(BuildContext context, WidgetRef ref, String treeId, String treeName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing export...')));
      final data = await ref.read(treeRepositoryProvider).getTreeExportData(treeId);
      await ExportService.exportJsonToDevice(data, treeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treesState = ref.watch(treeListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Family Trees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: treesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (trees) {
          if (trees.isEmpty) {
            return const Center(
              child: Text('No trees yet. Tap + to create one!', style: TextStyle(fontSize: 16)),
            );
          }
          
          return ListView.builder(
            itemCount: trees.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final tree = trees[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(tree.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('Created: ${tree.createdAt.toLocal().toString().split(' ')[0]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Export as JSON',
                    onPressed: () => _exportTree(context, ref, tree.id, tree.name),
                  ),
                  onTap: () {
                    ref.read(currentTreeControllerProvider.notifier).setTree(tree);
                    context.push('/canvas');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

**Файл:** `lib/features/tree_canvas/domain/models/graph_node.dart`
```dart
import 'dart:ui';
import '../../../../data/models/member_model.dart';

class GraphNode {
  final MemberModel member;
  int level = 0;
  double x = 0.0;
  double y = 0.0;
  
  final List<GraphNode> spouses = [];
  final List<GraphNode> parents = [];
  final List<GraphNode> children = [];

  GraphNode(this.member);

  String get id => member.id;

  Offset get position => Offset(x, y);
}
```

---

**Файл:** `lib/features/tree_canvas/domain/services/tree_layout_service.dart`
```dart
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
```

---

**Файл:** `lib/features/tree_canvas/domain/services/audio_service.dart`
```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

@riverpod
AudioService audioService(AudioServiceRef ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
}

class AudioService {
  final AudioPlayer _scrollPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  AudioService() {
    _scrollPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void dispose() {
    _scrollPlayer.dispose();
    _sfxPlayer.dispose();
  }

  void toggleSound(bool enable) {
    _isSoundEnabled = enable;
    if (!enable) {
      _scrollPlayer.stop();
    }
  }

  Future<void> playScrollLeaves() async {
    if (!_isSoundEnabled) return;
    if (_scrollPlayer.state != PlayerState.playing) {
      try {
        await _scrollPlayer.play(AssetSource('sounds/leaves_scroll.mp3'), volume: 0.2);
      } catch (_) {}
    }
  }

  Future<void> stopScrollLeaves() async {
    await _scrollPlayer.pause();
  }

  Future<void> playAddMemberChime() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/chime_add_member.mp3'), volume: 0.6);
    } catch (_) {}
  }
}
```

---

**Файл:** `lib/features/tree_canvas/tree_graph_controller.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_providers.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/member_model.dart';
import '../../data/models/relationship_model.dart';
import '../../data/models/enums.dart';
import '../tree_list/current_tree_controller.dart';

part 'tree_graph_controller.g.dart';

class TreeGraphState {
  final List<MemberModel> members;
  final List<RelationshipModel> relationships;
  TreeGraphState(this.members, this.relationships);
}

@riverpod
class TreeGraphController extends _$TreeGraphController {
  @override
  FutureOr<TreeGraphState> build() async {
    final currentTree = ref.watch(currentTreeControllerProvider);
    if (currentTree == null) return TreeGraphState([], []);

    final client = ref.watch(supabaseProvider);
    
    final membersRes = await client.from('members').select().eq('tree_id', currentTree.id);
    final members = membersRes.map((j) => MemberModel.fromJson(j)).toList();

    List<RelationshipModel> relationships = [];
    if (members.isNotEmpty) {
      final relsRes = await client.from('relationships').select().inFilter(
          'member1_id', members.map((m) => m.id).toList());
      relationships = relsRes.map((j) => RelationshipModel.fromJson(j)).toList();
    }

    final notifService = ref.read(notificationServiceProvider);
    for (var m in members) {
      notifService.scheduleBirthdayNotification(m);
    }

    return TreeGraphState(members, relationships);
  }

  Future<void> addRelative({
    required String targetMemberId,
    required String firstName,
    required Gender gender,
    required String relationType,
  }) async {
    final currentTree = ref.watch(currentTreeControllerProvider);
    if (currentTree == null) return;

    final client = ref.watch(supabaseProvider);
    
    final newMemberRes = await client.from('members').insert({
      'tree_id': currentTree.id,
      'first_name': firstName,
      'gender': gender.name,
    }).select().single();
    
    final newMember = MemberModel.fromJson(newMemberRes);

    if (relationType != 'self') {
      Map<String, dynamic> relData;
      if (relationType == 'parent') {
        relData = {
          'member1_id': newMember.id,
          'member2_id': targetMemberId,
          'relationship_type': RelationshipType.parent.name,
        };
      } else if (relationType == 'child') {
        relData = {
          'member1_id': targetMemberId,
          'member2_id': newMember.id,
          'relationship_type': RelationshipType.parent.name,
        };
      } else {
        relData = {
          'member1_id': targetMemberId,
          'member2_id': newMember.id,
          'relationship_type': RelationshipType.spouse.name,
        };
      }
      await client.from('relationships').insert(relData);
    }

    ref.invalidateSelf();
  }
}
```

---

**Файл:** `lib/features/tree_canvas/lens_controller.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lens_controller.g.dart';

class LensState {
  final bool isActive;
  final int year;

  LensState({required this.isActive, required this.year});
}

@riverpod
class LensController extends _$LensController {
  @override
  LensState build() {
    return LensState(isActive: false, year: DateTime.now().year);
  }

  void toggle(bool active) {
    state = LensState(isActive: active, year: state.year);
  }

  void setYear(int year) {
    state = LensState(isActive: state.isActive, year: year);
  }
}
```

---

**Файл:** `lib/features/tree_canvas/presentation/widgets/parallax_background.dart`
```dart
import 'package:flutter/material.dart';

class ParallaxBackground extends StatelessWidget {
  final TransformationController controller;
  final bool isDark;

  const ParallaxBackground({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final matrix = controller.value;
        final dx = matrix.getTranslation().x;
        final dy = matrix.getTranslation().y;
        final scale = matrix.getMaxScaleOnAxis();

        final bgOffset = Offset(dx * 0.1, dy * 0.1);
        final patternOffset = Offset(dx * 0.3, dy * 0.3);

        return Stack(
          children: [
            Container(
              color: isDark ? const Color(0xFF0F1115) : const Color(0xFFF9F8F6),
            ),
            Positioned(
              left: bgOffset.dx,
              top: bgOffset.dy,
              child: Opacity(
                opacity: 0.04,
                child: Image.asset(
                  'assets/background/bg_stylized_tree.png',
                  width: 2048,
                  height: 2048,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox(width: 2048, height: 2048),
                ),
              ),
            ),
            Positioned(
              left: patternOffset.dx - 1000,
              top: patternOffset.dy - 1000,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  isDark ? 'assets/background/bg_grain_dark.png' : 'assets/background/bg_grain_light.png',
                  repeat: ImageRepeat.repeat,
                  width: 4000,
                  height: 4000,
                  errorBuilder: (c, e, s) => const SizedBox(width: 4000, height: 4000),
                ),
              ),
            ),
            if (scale < 0.4)
              Container(
                color: (isDark ? Colors.black : Colors.white).withOpacity(
                  (0.4 - scale).clamp(0.0, 0.7),
                ),
              ),
          ],
        );
      },
    );
  }
}
```

---

**Файл:** `lib/features/tree_canvas/presentation/widgets/branch_painter.dart`
```dart
import 'package:flutter/material.dart';
import '../../domain/models/graph_node.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/relationship_model.dart';

class BranchPainter extends CustomPainter {
  final Map<String, GraphNode> nodes;
  final List<RelationshipModel> relationships;
  final bool isDark;
  final Set<String> hiddenNodeIds;

  BranchPainter({
    required this.nodes,
    required this.relationships,
    required this.isDark,
    required this.hiddenNodeIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goldBase = const Color(0xFFD4AF37);
    final greenBase = const Color(0xFF2D4A3E);
    final accentColor = isDark ? goldBase : greenBase;

    final parentPaint = Paint()
      ..color = accentColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final spousePaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const cardRadius = 60.0;

    for (var rel in relationships) {
      if (hiddenNodeIds.contains(rel.member1Id) || hiddenNodeIds.contains(rel.member2Id)) {
        continue;
      }

      final node1 = nodes[rel.member1Id];
      final node2 = nodes[rel.member2Id];
      if (node1 == null || node2 == null) continue;

      final p1 = node1.position;
      final p2 = node2.position;

      final path = Path();

      if (rel.relationshipType == RelationshipType.parent) {
        final startY = p1.dy + cardRadius;
        final endY = p2.dy - cardRadius;
        
        path.moveTo(p1.dx, startY);
        path.cubicTo(
          p1.dx, startY + 100,
          p2.dx, endY - 100,
          p2.dx, endY,
        );
        canvas.drawPath(path, parentPaint);
      } else if (rel.relationshipType == RelationshipType.spouse) {
        final startX = p1.dx < p2.dx ? p1.dx + cardRadius : p1.dx - cardRadius;
        final endX = p2.dx > p1.dx ? p2.dx - cardRadius : p2.dx + cardRadius;
        
        path.moveTo(startX, p1.dy);
        path.quadraticBezierTo(
          (startX + endX) / 2, p1.dy + 30,
          endX, p2.dy,
        );
        canvas.drawPath(path, spousePaint);
        
        canvas.drawCircle(
          Offset((startX + endX) / 2, p1.dy + 15),
          6.0,
          Paint()..color = accentColor..style = PaintingStyle.stroke..strokeWidth = 2.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BranchPainter oldDelegate) {
    return oldDelegate.nodes != nodes || 
           oldDelegate.isDark != isDark || 
           oldDelegate.hiddenNodeIds != hiddenNodeIds;
  }
}
```

---

**Файл:** `lib/features/tree_canvas/presentation/widgets/member_node_widget.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/member_model.dart';
import '../../../profile/presentation/profile_screen.dart';

class MemberNodeWidget extends StatefulWidget {
  final MemberModel member;
  final bool isSelected;
  final bool isVisible;
  final VoidCallback onTap;
  final Function(String relationType) onAddTap;

  const MemberNodeWidget({
    super.key,
    required this.member,
    required this.isSelected,
    required this.isVisible,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  State<MemberNodeWidget> createState() => _MemberNodeWidgetState();
}

class _MemberNodeWidgetState extends State<MemberNodeWidget> {
  bool _isPressed = false;

  bool get _isDeceased => widget.member.deathDate != null;
  
  bool get _isBirthday {
    if (widget.member.birthDate == null) return false;
    final now = DateTime.now();
    return widget.member.birthDate!.day == now.day && widget.member.birthDate!.month == now.month;
  }

  String get _yearsText {
    final b = widget.member.birthDate?.year;
    final d = widget.member.deathDate?.year;
    if (b == null) return '';
    if (d != null) return '$b – $d';
    return '$b';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final surfaceColor = isDark ? const Color(0xFF1A1D24) : const Color(0xFFFFFFFF);
    final accentColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2D4A3E);
    final glowColor = _isDeceased 
        ? Colors.grey.withOpacity(0.4)
        : (_isBirthday ? accentColor.withOpacity(0.8) : accentColor.withOpacity(0.1));

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.isVisible ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (widget.isSelected) ...[
              _buildAddBtn(const Offset(0, -90), 'parent', Icons.keyboard_arrow_up),
              _buildAddBtn(const Offset(0, 90), 'child', Icons.keyboard_arrow_down),
              _buildAddBtn(const Offset(-90, 0), 'spouse', Icons.favorite_border),
              
              Positioned(
                left: 60 - 16 + 90,
                top: 60 - 16,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ProfileScreen.show(context, widget.member);
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Icon(Icons.person, size: 18, color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ),
            ],

            GestureDetector(
              onTapDown: (_) {
                HapticFeedback.selectionClick();
                setState(() => _isPressed = true);
              },
              onTapUp: (_) {
                HapticFeedback.lightImpact();
                setState(() => _isPressed = false);
                widget.onTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: surfaceColor,
                    boxShadow: [
                      BoxShadow(color: glowColor, blurRadius: _isBirthday ? 20 : 10, spreadRadius: _isBirthday ? 5 : 0),
                    ],
                    border: Border.all(
                      color: _isDeceased ? Colors.grey.withOpacity(0.3) : accentColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: accentColor.withOpacity(0.1),
                        backgroundImage: widget.member.avatarUrl != null ? NetworkImage(widget.member.avatarUrl!) : null,
                        child: widget.member.avatarUrl == null 
                            ? Text(widget.member.firstName[0], style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 20))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.member.firstName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!_isDeceased && _yearsText.isNotEmpty)
                        Text(
                          _yearsText,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBtn(Offset offset, String type, IconData icon) {
    return Positioned(
      left: 60 - 16 + offset.dx,
      top: 60 - 16 + offset.dy,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onAddTap(type);
        },
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
```

---

**Файл:** `lib/features/tree_canvas/presentation/widgets/add_relative_sheet.dart`
```dart
import 'package:flutter/material.dart';
import '../../../../data/models/enums.dart';

class AddRelativeSheet extends StatefulWidget {
  final String relationType;
  final Function(String name, Gender gender) onAdd;

  const AddRelativeSheet({super.key, required this.relationType, required this.onAdd});

  static void show(BuildContext context, String relationType, Function(String, Gender) onAdd) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => AddRelativeSheet(relationType: relationType, onAdd: onAdd),
    );
  }

  @override
  State<AddRelativeSheet> createState() => _AddRelativeSheetState();
}

class _AddRelativeSheetState extends State<AddRelativeSheet> {
  final _nameController = TextEditingController();
  Gender _gender = Gender.female;

  @override
  Widget build(BuildContext context) {
    String title = 'Add Relative';
    if (widget.relationType == 'parent') title = 'Add Parent';
    if (widget.relationType == 'child') title = 'Add Child';
    if (widget.relationType == 'spouse') title = 'Add Spouse';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          SegmentedButton<Gender>(
            segments: const [
              ButtonSegment(value: Gender.female, label: Text('Female')),
              ButtonSegment(value: Gender.male, label: Text('Male')),
            ],
            selected: {_gender},
            onSelectionChanged: (set) => setState(() => _gender = set.first),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                widget.onAdd(_nameController.text.trim(), _gender);
                Navigator.pop(context);
              }
            },
            child: const Text('Add to Tree'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
```

---

**Файл:** `lib/features/tree_canvas/presentation/widgets/lens_overlay_widget.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../lens_controller.dart';

class LensOverlayWidget extends ConsumerWidget {
  final int minYear;
  final int maxYear;

  const LensOverlayWidget({
    super.key,
    required this.minYear,
    required this.maxYear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lensState = ref.watch(lensControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeMin = minYear < maxYear ? minYear : maxYear - 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1A1D24) : Colors.white).withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          const Text('Линза времени', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Switch(
            value: lensState.isActive,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              ref.read(lensControllerProvider.notifier).toggle(val);
            },
          ),
          if (lensState.isActive) ...[
            Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 8)),
            SizedBox(
              width: 150,
              child: Slider(
                value: lensState.year.toDouble().clamp(safeMin.toDouble(), maxYear.toDouble()),
                min: safeMin.toDouble(),
                max: maxYear.toDouble(),
                divisions: maxYear - safeMin,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) {
                  ref.read(lensControllerProvider.notifier).setYear(val.toInt());
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lensState.year.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

**Файл:** `lib/features/tree_canvas/presentation/tree_canvas_screen.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../tree_list/current_tree_controller.dart';
import '../domain/services/tree_layout_service.dart';
import '../domain/services/audio_service.dart';
import '../tree_graph_controller.dart';
import '../lens_controller.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/enums.dart';
import '../domain/models/graph_node.dart';
import '../../profile/presentation/profile_screen.dart';

import 'widgets/parallax_background.dart';
import 'widgets/branch_painter.dart';
import 'widgets/member_node_widget.dart';
import 'widgets/add_relative_sheet.dart';
import 'widgets/lens_overlay_widget.dart';

class TreeCanvasScreen extends ConsumerStatefulWidget {
  const TreeCanvasScreen({super.key});

  @override
  ConsumerState<TreeCanvasScreen> createState() => _TreeCanvasScreenState();
}

class _TreeCanvasScreenState extends ConsumerState<TreeCanvasScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _isScrolling = false;
  String? _selectedMemberId;
  StreamSubscription? _notifSubscription;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onCanvasTransformed);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerCamera());

    _notifSubscription = ref.read(notificationServiceProvider).onNotificationTap.listen((memberId) {
      final state = ref.read(treeGraphControllerProvider).value;
      if (state != null) {
        try {
          final member = state.members.firstWhere((m) => m.id == memberId);
          ProfileScreen.show(context, member);
        } catch (_) {}
      }
    });
  }

  void _onCanvasTransformed() {
    if (!_isScrolling) {
      _isScrolling = true;
      ref.read(audioServiceProvider).playScrollLeaves();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _isScrolling = false;
          ref.read(audioServiceProvider).stopScrollLeaves();
        }
      });
    }
  }

  void _centerCamera() {
    final size = MediaQuery.of(context).size;
    _transformationController.value = Matrix4.identity()..translate(size.width / 2, size.height / 2);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _notifSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTree = ref.watch(currentTreeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentTree == null) return const Scaffold(body: Center(child: Text('No tree selected')));
    final graphStateAsync = ref.watch(treeGraphControllerProvider);

    return Scaffold(
      body: graphStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (graph) {
          final members = graph.members;
          final rels = graph.relationships;
          final rootId = currentTree.ownerId;

          if (members.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: () => ref.read(treeGraphControllerProvider.notifier)
                    .addRelative(targetMemberId: '', firstName: 'Me', gender: Gender.male, relationType: 'self'),
                child: const Text('Initialize Tree (Add Me)'),
              ),
            );
          }

          final lensState = ref.watch(lensControllerProvider);
          int minYear = DateTime.now().year;
          for (var m in members) {
            if (m.birthDate != null && m.birthDate!.year < minYear) minYear = m.birthDate!.year;
          }
          if (minYear == DateTime.now().year) minYear = 1900;
          
          final Set<String> hiddenNodeIds = {};
          if (lensState.isActive) {
            for (var m in members) {
              if (m.birthDate != null && m.birthDate!.year > lensState.year) hiddenNodeIds.add(m.id);
            }
          }

          final positions = ref.watch(treeLayoutServiceProvider).calculatePositions(
            ownerId: rootId, members: members, relationships: rels,
          );
          
          final dummyNodes = { 
            for (var m in members) 
              m.id: GraphNode(m)
                ..x = (positions[m.id]?.dx ?? 0)
                ..y = (positions[m.id]?.dy ?? 0) 
          };

          return Stack(
            children: [
              ParallaxBackground(controller: _transformationController, isDark: isDark),
              GestureDetector(
                onTap: () => setState(() => _selectedMemberId = null),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1, maxScale: 2.5, constrained: false, boundaryMargin: const EdgeInsets.all(5000),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        painter: BranchPainter(
                          nodes: dummyNodes, 
                          relationships: rels, 
                          isDark: isDark, 
                          hiddenNodeIds: hiddenNodeIds,
                        ),
                      ),
                      ...members.map((m) {
                        final pos = positions[m.id] ?? Offset.zero;
                        final isVisible = !hiddenNodeIds.contains(m.id);
                        
                        return Positioned(
                          left: pos.dx - 60, top: pos.dy - 60,
                          child: IgnorePointer(
                            ignoring: !isVisible,
                            child: MemberNodeWidget(
                              member: m,
                              isSelected: _selectedMemberId == m.id,
                              isVisible: isVisible,
                              onTap: () => setState(() => _selectedMemberId = m.id),
                              onAddTap: (relationType) async {
                                AddRelativeSheet.show(context, relationType, (name, gender) async {
                                  await ref.read(treeGraphControllerProvider.notifier).addRelative(
                                    targetMemberId: m.id, 
                                    firstName: name, 
                                    gender: gender, 
                                    relationType: relationType,
                                  );
                                  ref.read(audioServiceProvider).playAddMemberChime();
                                  final state = ref.read(treeGraphControllerProvider).value;
                                  if (state != null && state.members.length == 2) {
                                    await ref.read(notificationServiceProvider).requestPermissionGently(context);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 40, left: 0, right: 0,
                child: Center(
                  child: LensOverlayWidget(
                    minYear: minYear, 
                    maxYear: DateTime.now().year,
                  ),
                ),
              ),
              Positioned(
                bottom: 100, right: 24,
                child: FloatingActionButton(
                  onPressed: _centerCamera,
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  child: const Icon(Icons.my_location),
                ),
              ),
              Positioned(
                top: 50, left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

**Файл:** `lib/features/profile/profile_controller.dart`
```dart
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/supabase_providers.dart';
import '../../data/models/fact_model.dart';
import '../../data/models/timeline_event_model.dart';

part 'profile_controller.g.dart';

class UnifiedEvent {
  final String id;
  final DateTime date;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? audioUrl;
  final bool isFact;

  UnifiedEvent({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    this.imageUrl,
    this.audioUrl,
    this.isFact = false,
  });
}

class ProfileState {
  final List<FactModel> allFacts;
  final List<UnifiedEvent> timeline;
  ProfileState(this.allFacts, this.timeline);
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<ProfileState> build(String memberId) async {
    final client = ref.watch(supabaseProvider);
    final factsRes = await client.from('facts').select().eq('member_id', memberId);
    final facts = factsRes.map((j) => FactModel.fromJson(j)).toList();

    final eventsRes = await client.from('timeline_events').select().eq('member_id', memberId);
    final events = eventsRes.map((j) => TimelineEventModel.fromJson(j)).toList();

    final List<UnifiedEvent> timeline = [];
    
    for (var event in events) {
      timeline.add(UnifiedEvent(
        id: event.id,
        date: event.eventDate ?? event.createdAt,
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
      ));
    }
    for (var fact in facts) {
      if (fact.factDate != null) {
        timeline.add(UnifiedEvent(
          id: fact.id,
          date: fact.factDate!,
          title: 'Fact: ${fact.category.name}',
          description: fact.value,
          isFact: true,
        ));
      }
    }
    timeline.sort((a, b) => a.date.compareTo(b.date));

    return ProfileState(facts, timeline);
  }

  Future<void> addVoiceCapsule(String localPath) async {
    final client = ref.watch(supabaseProvider);
    final file = File(localPath);
    final fileName = '${memberId}_${const Uuid().v4()}.m4a';
    final storagePath = '${client.auth.currentUser!.id}/$fileName';

    try {
      await client.storage.from('audio').upload(storagePath, file);
      final audioUrl = client.storage.from('audio').getPublicUrl(storagePath);
      await client.from('timeline_events').insert({
        'member_id': memberId,
        'title': 'Voice Memory',
        'event_date': DateTime.now().toIso8601String(),
        'audio_url': audioUrl,
      });
      ref.invalidateSelf();
    } catch (e) {
      print('Audio upload failed: $e');
    }
  }
}
```

---

**Файл:** `lib/features/profile/presentation/widgets/voice_capsule_widgets.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderButton extends StatefulWidget {
  final Function(String path) onRecordComplete;
  const VoiceRecorderButton({super.key, required this.onRecordComplete});

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> with SingleTickerProviderStateMixin {
  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  late AnimationController _pulseController;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _record.dispose();
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _record.hasPermission()) {
      HapticFeedback.heavyImpact();
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/temp_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _record.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => setState(() => _recordDuration++));
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    HapticFeedback.lightImpact();
    _timer?.cancel();
    final path = await _record.stop();
    setState(() => _isRecording = false);
    if (path != null && _recordDuration > 1) {
      widget.onRecordComplete(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      onLongPressUp: _stopRecording,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _isRecording ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: _isRecording ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _isRecording ? 'Recording 00:${_recordDuration.toString().padLeft(2, '0')}' : 'Hold to record',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class VoicePlayerWidget extends StatefulWidget {
  final String audioUrl;
  const VoicePlayerWidget({super.key, required this.audioUrl});

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
    _player.setSourceUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
            color: Theme.of(context).colorScheme.primary,
            iconSize: 36,
            onPressed: () {
              _isPlaying ? _player.pause() : _player.play(UrlSource(widget.audioUrl));
            },
          ),
          Expanded(
            child: Slider(
              value: _position.inSeconds.toDouble(),
              min: 0.0,
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (val) {
                _player.seek(Duration(seconds: val.toInt()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

**Файл:** `lib/features/profile/presentation/profile_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member_model.dart';
import '../../../data/models/enums.dart';
import '../profile_controller.dart';
import 'widgets/voice_capsule_widgets.dart';
import '../../interview/presentation/interview_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final MemberModel member;
  const ProfileScreen({super.key, required this.member});

  static void show(BuildContext context, MemberModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ProfileScreen(member: member),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStateAsync = ref.watch(profileControllerProvider(member.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1A1D24) : const Color(0xFFFFFFFF);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: profileStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                        child: member.avatarUrl == null ? Text(member.firstName[0], style: const TextStyle(fontSize: 40)) : null,
                      ),
                      const SizedBox(height: 16),
                      Text(member.firstName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      if (member.birthDate != null)
                        Text('${member.birthDate!.year} – ${member.deathDate?.year ?? 'Present'}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit')),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InterviewScreen(member: member)),
                            ),
                            icon: const Icon(Icons.forum, size: 16),
                            label: const Text('Interview'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildGhostFacts(context, state.allFacts),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTimelineEvent(
                      context,
                      state.timeline[index],
                      isLast: index == state.timeline.length - 1,
                    ),
                    childCount: state.timeline.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: VoiceRecorderButton(
                      onRecordComplete: (path) => ref.read(profileControllerProvider(member.id).notifier).addVoiceCapsule(path),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGhostFacts(BuildContext context, List<FactModel> facts) {
    if (!facts.any((f) => f.category == FactCategory.birthplace)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InterviewScreen(member: member)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tell us where ${member.firstName} was born \u2192',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTimelineEvent(BuildContext context, UnifiedEvent event, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
              if (!isLast) Expanded(child: Container(width: 2, color: Theme.of(context).colorScheme.primary.withOpacity(0.3))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.date.year.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (event.description != null) ...[const SizedBox(height: 8), Text(event.description!)],
                  if (event.imageUrl != null) ...[const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(event.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover))],
                  if (event.audioUrl != null) ...[VoicePlayerWidget(audioUrl: event.audioUrl!)],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

**Файл:** `lib/features/interview/domain/interview_question.dart`
```dart
import '../../../data/models/enums.dart';

class InterviewQuestion {
  final String id;
  final String text;
  final FactCategory targetCategory;
  final bool isMultipleAllowed;
  final bool asksForDate;

  const InterviewQuestion({
    required this.id,
    required this.text,
    required this.targetCategory,
    this.isMultipleAllowed = false,
    this.asksForDate = false,
  });
}

const List<InterviewQuestion> defaultInterviewQuestions = [
  InterviewQuestion(
    id: 'q_birth',
    text: 'Когда и где он/она родился(лась)?',
    targetCategory: FactCategory.birthplace,
    asksForDate: true,
  ),
  InterviewQuestion(
    id: 'q_childhood',
    text: 'Где он вырос и каким был ребёнком?',
    targetCategory: FactCategory.trait,
  ),
  InterviewQuestion(
    id: 'q_education_job',
    text: 'Где учился? Какая была первая работа?',
    targetCategory: FactCategory.occupation,
  ),
  InterviewQuestion(
    id: 'q_love',
    text: 'Как познакомился со своей второй половиной? Расскажите о свадьбе.',
    targetCategory: FactCategory.story,
    isMultipleAllowed: true,
    asksForDate: true,
  ),
  InterviewQuestion(
    id: 'q_phrase',
    text: 'Какая у него/неё была любимая фраза или присловье?',
    targetCategory: FactCategory.phrase,
  ),
  InterviewQuestion(
    id: 'q_memory',
    text: 'Каким моментом из его жизни вы дорожите больше всего?',
    targetCategory: FactCategory.story,
    isMultipleAllowed: true,
  ),
];
```

---

**Файл:** `lib/features/interview/interview_controller.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/supabase_providers.dart';
import '../../data/models/fact_model.dart';
import '../../data/models/enums.dart';
import 'domain/interview_question.dart';

part 'interview_controller.g.dart';

class InterviewState {
  final List<InterviewQuestion> pendingQuestions;
  final int currentIndex;
  final bool isSaving;

  InterviewState({
    required this.pendingQuestions,
    required this.currentIndex,
    this.isSaving = false,
  });

  InterviewQuestion? get currentQuestion => 
      pendingQuestions.isNotEmpty && currentIndex < pendingQuestions.length 
          ? pendingQuestions[currentIndex] 
          : null;
          
  double get progress => pendingQuestions.isEmpty 
      ? 1.0 
      : currentIndex / pendingQuestions.length;
}

@riverpod
class InterviewController extends _$InterviewController {
  @override
  FutureOr<InterviewState> build(String memberId) async {
    final client = ref.watch(supabaseProvider);
    final factsRes = await client.from('facts').select('category').eq('member_id', memberId);
    final existingCategories = factsRes.map((f) => f['category'] as String).toSet();

    final pending = defaultInterviewQuestions.where((q) {
      if (q.isMultipleAllowed) return true;
      return !existingCategories.contains(q.targetCategory.name);
    }).toList();

    return InterviewState(pendingQuestions: pending, currentIndex: 0);
  }

  Future<void> saveAnswer(String answerText, DateTime? factDate) async {
    if (state.value == null || answerText.trim().isEmpty) return;
    final currentState = state.value!;
    final question = currentState.currentQuestion;
    if (question == null) return;

    state = AsyncValue.data(InterviewState(
      pendingQuestions: currentState.pendingQuestions,
      currentIndex: currentState.currentIndex,
      isSaving: true,
    ));
    final client = ref.watch(supabaseProvider);

    try {
      await client.from('facts').insert({
        'member_id': memberId,
        'category': question.targetCategory.name,
        'value': answerText.trim(),
        'fact_date': factDate?.toIso8601String(),
      });
      state = AsyncValue.data(InterviewState(
        pendingQuestions: currentState.pendingQuestions,
        currentIndex: currentState.currentIndex + 1,
        isSaving: false,
      ));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void skipQuestion() {
    if (state.value == null) return;
    final currentState = state.value!;
    state = AsyncValue.data(InterviewState(
      pendingQuestions: currentState.pendingQuestions,
      currentIndex: currentState.currentIndex + 1,
    ));
  }
}
```

---

**Файл:** `lib/features/interview/presentation/interview_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interview_controller.dart';
import '../../../data/models/member_model.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  final MemberModel member;
  const InterviewScreen({super.key, required this.member});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _textController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitAnswer(WidgetRef ref) {
    if (_textController.text.trim().isEmpty) return;
    ref.read(interviewControllerProvider(widget.member.id).notifier)
        .saveAnswer(_textController.text, _selectedDate);
    _textController.clear();
    setState(() => _selectedDate = null);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(interviewControllerProvider(widget.member.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text('Interview: ${widget.member.firstName}', style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (state) {
          final question = state.currentQuestion;
          if (question == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text('Интервью завершено!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Вернуться в профиль'))
                ],
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      question.text,
                      key: ValueKey(question.id),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Ваш ответ...',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2D35) : const Color(0xFFF0F0F0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ActionChip(
                        label: Text(_selectedDate != null 
                            ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}' 
                            : 'Указать дату события'),
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        onPressed: _pickDate,
                        backgroundColor: _selectedDate != null ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: state.isSaving ? null : () {
                          _textController.clear();
                          ref.read(interviewControllerProvider(widget.member.id).notifier).skipQuestion();
                        },
                        child: const Text('Пропустить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state.isSaving ? null : () => _submitAnswer(ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: state.isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('Сохранить и продолжить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

**Файл:** `lib/features/premium/subscription_controller.dart`
```dart
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
```

---

**Файл:** `lib/features/premium/presentation/subscription_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../subscription_controller.dart';
import '../../../data/models/enums.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionControllerProvider);
    final currentTier = subState.value?.tierLevel ?? TierLevel.free;

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Archive')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Preserve your family legacy\nfor generations to come.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildTierCard(
            context,
            title: 'Free',
            price: '\$0',
            features: ['Up to 15 family members', 'Basic text facts', 'Standard tree export'],
            isCurrent: currentTier == TierLevel.free,
          ),
          const SizedBox(height: 16),
          _buildTierCard(
            context,
            title: 'Standard',
            price: '\$4.99/mo',
            features: ['Up to 100 family members', 'Full text interview', 'Photo uploads'],
            isCurrent: currentTier == TierLevel.standard,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFE5C158)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 20)],
            ),
            padding: const EdgeInsets.all(3),
            child: _buildTierCard(
              context,
              title: 'Pro',
              price: '\$9.99/mo',
              features: ['Unlimited members', 'Voice capsules & Reminders', 'Print-ready PDF Export', 'Seasonal Themes'],
              isCurrent: currentTier == TierLevel.pro,
              isPro: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool isCurrent,
    bool isPro = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D24) : Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isPro ? const Color(0xFFD4AF37) : null)),
              if (isPro) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.workspace_premium, color: Color(0xFFD4AF37))),
              const Spacer(),
              if (isCurrent) 
                Chip(label: const Text('Current', style: TextStyle(fontSize: 12)), backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(Icons.check_circle, size: 16, color: isPro ? const Color(0xFFD4AF37) : Colors.grey),
              const SizedBox(width: 12),
              Expanded(child: Text(f)),
            ]),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPro ? const Color(0xFFD4AF37) : null,
                foregroundColor: isPro ? Colors.black : null,
              ),
              child: Text(isCurrent ? 'Active' : 'Upgrade to $title'),
            ),
          )
        ],
      ),
    );
  }
}
```

---

**Файл:** `lib/features/premium/presentation/pdf_stub_screen.dart`
```dart
import 'package:flutter/material.dart';

class PdfStubScreen extends StatelessWidget {
  const PdfStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poster Export')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200, height: 280,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
                ),
                child: Center(child: Icon(Icons.account_tree, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5))),
              ),
              const SizedBox(height: 40),
              const Text('Heirloom Quality Poster', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'Generate a high-resolution, print-ready PDF of your entire family tree. Perfect for framing or family reunions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.hourglass_bottom),
                label: const Text('Coming in next update'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

**Файл:** `lib/features/premium/presentation/premium_modal.dart`
```dart
import 'package:flutter/material.dart';
import 'subscription_screen.dart';

class PremiumModal {
  static void show(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 64, color: Color(0xFFD4AF37)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('View Premium Plans'),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe later'))
          ],
        ),
      ),
    );
  }
}
```