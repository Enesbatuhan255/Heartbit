// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRemoteDataSourceHash() =>
    r'45124f1578cb446981f2200e1ab279320929c7ab';

/// See also [userRemoteDataSource].
@ProviderFor(userRemoteDataSource)
final userRemoteDataSourceProvider =
    AutoDisposeProvider<UserRemoteDataSource>.internal(
  userRemoteDataSource,
  name: r'userRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRemoteDataSourceRef = AutoDisposeProviderRef<UserRemoteDataSource>;
String _$storageRemoteDataSourceHash() =>
    r'7b1be95fa64f13135b284047af0d4124a62ebb20';

/// See also [storageRemoteDataSource].
@ProviderFor(storageRemoteDataSource)
final storageRemoteDataSourceProvider =
    AutoDisposeProvider<StorageRemoteDataSource>.internal(
  storageRemoteDataSource,
  name: r'storageRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageRemoteDataSourceRef
    = AutoDisposeProviderRef<StorageRemoteDataSource>;
String _$userRepositoryHash() => r'2f9c1dbc2956e7f602fea04dff4f499d116d292e';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$userProfileStreamHash() => r'925562180bd8d3a50ad0b38b6917c8a46cd9fe03';

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

/// See also [userProfileStream].
@ProviderFor(userProfileStream)
const userProfileStreamProvider = UserProfileStreamFamily();

/// See also [userProfileStream].
class UserProfileStreamFamily extends Family<AsyncValue<UserProfile?>> {
  /// See also [userProfileStream].
  const UserProfileStreamFamily();

  /// See also [userProfileStream].
  UserProfileStreamProvider call(
    String uid,
  ) {
    return UserProfileStreamProvider(
      uid,
    );
  }

  @override
  UserProfileStreamProvider getProviderOverride(
    covariant UserProfileStreamProvider provider,
  ) {
    return call(
      provider.uid,
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
  String? get name => r'userProfileStreamProvider';
}

/// See also [userProfileStream].
class UserProfileStreamProvider
    extends AutoDisposeStreamProvider<UserProfile?> {
  /// See also [userProfileStream].
  UserProfileStreamProvider(
    String uid,
  ) : this._internal(
          (ref) => userProfileStream(
            ref as UserProfileStreamRef,
            uid,
          ),
          from: userProfileStreamProvider,
          name: r'userProfileStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userProfileStreamHash,
          dependencies: UserProfileStreamFamily._dependencies,
          allTransitiveDependencies:
              UserProfileStreamFamily._allTransitiveDependencies,
          uid: uid,
        );

  UserProfileStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    Stream<UserProfile?> Function(UserProfileStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProfileStreamProvider._internal(
        (ref) => create(ref as UserProfileStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<UserProfile?> createElement() {
    return _UserProfileStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileStreamProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProfileStreamRef on AutoDisposeStreamProviderRef<UserProfile?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _UserProfileStreamProviderElement
    extends AutoDisposeStreamProviderElement<UserProfile?>
    with UserProfileStreamRef {
  _UserProfileStreamProviderElement(super.provider);

  @override
  String get uid => (origin as UserProfileStreamProvider).uid;
}

String _$userProfileControllerHash() =>
    r'1fa5f9952a5f94712428e95ce95e0c43e616daa2';

/// See also [UserProfileController].
@ProviderFor(UserProfileController)
final userProfileControllerProvider =
    AutoDisposeAsyncNotifierProvider<UserProfileController, void>.internal(
  UserProfileController.new,
  name: r'userProfileControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userProfileControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserProfileController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
