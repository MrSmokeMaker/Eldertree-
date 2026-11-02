// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$interviewControllerHash() =>
    r'7a143db47705e39cd3b2333d6d9fcd4c4c7181f2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$InterviewController
    extends BuildlessAutoDisposeAsyncNotifier<InterviewState> {
  late final String memberId;

  FutureOr<InterviewState> build(
    String memberId,
  );
}

/// See also [InterviewController].
@ProviderFor(InterviewController)
const interviewControllerProvider = InterviewControllerFamily();

/// See also [InterviewController].
class InterviewControllerFamily extends Family<AsyncValue<InterviewState>> {
  /// See also [InterviewController].
  const InterviewControllerFamily();

  /// See also [InterviewController].
  InterviewControllerProvider call(
    String memberId,
  ) {
    return InterviewControllerProvider(
      memberId,
    );
  }

  @override
  InterviewControllerProvider getProviderOverride(
    covariant InterviewControllerProvider provider,
  ) {
    return call(
      provider.memberId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'interviewControllerProvider';
}

/// See also [InterviewController].
class InterviewControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    InterviewController, InterviewState> {
  /// See also [InterviewController].
  InterviewControllerProvider(
    String memberId,
  ) : this._internal(
          () => InterviewController()..memberId = memberId,
          from: interviewControllerProvider,
          name: r'interviewControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$interviewControllerHash,
          dependencies: InterviewControllerFamily._dependencies,
          allTransitiveDependencies:
              InterviewControllerFamily._allTransitiveDependencies,
          memberId: memberId,
        );

  InterviewControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  FutureOr<InterviewState> runNotifierBuild(
    covariant InterviewController notifier,
  ) {
    return notifier.build(
      memberId,
    );
  }

  @override
  Override overrideWith(InterviewController Function() create) {
    return ProviderOverride(
      origin: this,
      override: InterviewControllerProvider._internal(
        () => create()..memberId = memberId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<InterviewController, InterviewState>
      createElement() {
    return _InterviewControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InterviewControllerProvider && other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InterviewControllerRef
    on AutoDisposeAsyncNotifierProviderRef<InterviewState> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _InterviewControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<InterviewController,
        InterviewState> with InterviewControllerRef {
  _InterviewControllerProviderElement(super.provider);

  @override
  String get memberId => (origin as InterviewControllerProvider).memberId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
