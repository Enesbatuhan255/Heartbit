// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DraftSession _$DraftSessionFromJson(Map<String, dynamic> json) {
  return _DraftSession.fromJson(json);
}

/// @nodoc
mixin _$DraftSession {
  List<String> get selectedCategories => throw _privateConstructorUsedError;
  List<int> get budgetLevels => throw _privateConstructorUsedError;
  List<String> get durationTiers => throw _privateConstructorUsedError;
  List<String> get customActivities =>
      throw _privateConstructorUsedError; // List of titles
  List<String> get readyUsers =>
      throw _privateConstructorUsedError; // List of user IDs who clicked "Start"
  List<String> get lobbyUsers =>
      throw _privateConstructorUsedError; // List of user IDs currently in lobby
  String? get activeSessionId =>
      throw _privateConstructorUsedError; // Shared session ID for both partners
  @TimeStampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this DraftSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DraftSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DraftSessionCopyWith<DraftSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DraftSessionCopyWith<$Res> {
  factory $DraftSessionCopyWith(
          DraftSession value, $Res Function(DraftSession) then) =
      _$DraftSessionCopyWithImpl<$Res, DraftSession>;
  @useResult
  $Res call(
      {List<String> selectedCategories,
      List<int> budgetLevels,
      List<String> durationTiers,
      List<String> customActivities,
      List<String> readyUsers,
      List<String> lobbyUsers,
      String? activeSessionId,
      @TimeStampConverter() DateTime? lastUpdated});
}

/// @nodoc
class _$DraftSessionCopyWithImpl<$Res, $Val extends DraftSession>
    implements $DraftSessionCopyWith<$Res> {
  _$DraftSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DraftSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedCategories = null,
    Object? budgetLevels = null,
    Object? durationTiers = null,
    Object? customActivities = null,
    Object? readyUsers = null,
    Object? lobbyUsers = null,
    Object? activeSessionId = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      selectedCategories: null == selectedCategories
          ? _value.selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      budgetLevels: null == budgetLevels
          ? _value.budgetLevels
          : budgetLevels // ignore: cast_nullable_to_non_nullable
              as List<int>,
      durationTiers: null == durationTiers
          ? _value.durationTiers
          : durationTiers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customActivities: null == customActivities
          ? _value.customActivities
          : customActivities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      readyUsers: null == readyUsers
          ? _value.readyUsers
          : readyUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lobbyUsers: null == lobbyUsers
          ? _value.lobbyUsers
          : lobbyUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeSessionId: freezed == activeSessionId
          ? _value.activeSessionId
          : activeSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DraftSessionImplCopyWith<$Res>
    implements $DraftSessionCopyWith<$Res> {
  factory _$$DraftSessionImplCopyWith(
          _$DraftSessionImpl value, $Res Function(_$DraftSessionImpl) then) =
      __$$DraftSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> selectedCategories,
      List<int> budgetLevels,
      List<String> durationTiers,
      List<String> customActivities,
      List<String> readyUsers,
      List<String> lobbyUsers,
      String? activeSessionId,
      @TimeStampConverter() DateTime? lastUpdated});
}

/// @nodoc
class __$$DraftSessionImplCopyWithImpl<$Res>
    extends _$DraftSessionCopyWithImpl<$Res, _$DraftSessionImpl>
    implements _$$DraftSessionImplCopyWith<$Res> {
  __$$DraftSessionImplCopyWithImpl(
      _$DraftSessionImpl _value, $Res Function(_$DraftSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of DraftSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedCategories = null,
    Object? budgetLevels = null,
    Object? durationTiers = null,
    Object? customActivities = null,
    Object? readyUsers = null,
    Object? lobbyUsers = null,
    Object? activeSessionId = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$DraftSessionImpl(
      selectedCategories: null == selectedCategories
          ? _value._selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      budgetLevels: null == budgetLevels
          ? _value._budgetLevels
          : budgetLevels // ignore: cast_nullable_to_non_nullable
              as List<int>,
      durationTiers: null == durationTiers
          ? _value._durationTiers
          : durationTiers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customActivities: null == customActivities
          ? _value._customActivities
          : customActivities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      readyUsers: null == readyUsers
          ? _value._readyUsers
          : readyUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lobbyUsers: null == lobbyUsers
          ? _value._lobbyUsers
          : lobbyUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeSessionId: freezed == activeSessionId
          ? _value.activeSessionId
          : activeSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DraftSessionImpl implements _DraftSession {
  const _$DraftSessionImpl(
      {final List<String> selectedCategories = const [],
      final List<int> budgetLevels = const [],
      final List<String> durationTiers = const [],
      final List<String> customActivities = const [],
      final List<String> readyUsers = const [],
      final List<String> lobbyUsers = const [],
      this.activeSessionId,
      @TimeStampConverter() this.lastUpdated})
      : _selectedCategories = selectedCategories,
        _budgetLevels = budgetLevels,
        _durationTiers = durationTiers,
        _customActivities = customActivities,
        _readyUsers = readyUsers,
        _lobbyUsers = lobbyUsers;

  factory _$DraftSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DraftSessionImplFromJson(json);

  final List<String> _selectedCategories;
  @override
  @JsonKey()
  List<String> get selectedCategories {
    if (_selectedCategories is EqualUnmodifiableListView)
      return _selectedCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedCategories);
  }

  final List<int> _budgetLevels;
  @override
  @JsonKey()
  List<int> get budgetLevels {
    if (_budgetLevels is EqualUnmodifiableListView) return _budgetLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_budgetLevels);
  }

  final List<String> _durationTiers;
  @override
  @JsonKey()
  List<String> get durationTiers {
    if (_durationTiers is EqualUnmodifiableListView) return _durationTiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_durationTiers);
  }

  final List<String> _customActivities;
  @override
  @JsonKey()
  List<String> get customActivities {
    if (_customActivities is EqualUnmodifiableListView)
      return _customActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customActivities);
  }

// List of titles
  final List<String> _readyUsers;
// List of titles
  @override
  @JsonKey()
  List<String> get readyUsers {
    if (_readyUsers is EqualUnmodifiableListView) return _readyUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_readyUsers);
  }

// List of user IDs who clicked "Start"
  final List<String> _lobbyUsers;
// List of user IDs who clicked "Start"
  @override
  @JsonKey()
  List<String> get lobbyUsers {
    if (_lobbyUsers is EqualUnmodifiableListView) return _lobbyUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lobbyUsers);
  }

// List of user IDs currently in lobby
  @override
  final String? activeSessionId;
// Shared session ID for both partners
  @override
  @TimeStampConverter()
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'DraftSession(selectedCategories: $selectedCategories, budgetLevels: $budgetLevels, durationTiers: $durationTiers, customActivities: $customActivities, readyUsers: $readyUsers, lobbyUsers: $lobbyUsers, activeSessionId: $activeSessionId, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DraftSessionImpl &&
            const DeepCollectionEquality()
                .equals(other._selectedCategories, _selectedCategories) &&
            const DeepCollectionEquality()
                .equals(other._budgetLevels, _budgetLevels) &&
            const DeepCollectionEquality()
                .equals(other._durationTiers, _durationTiers) &&
            const DeepCollectionEquality()
                .equals(other._customActivities, _customActivities) &&
            const DeepCollectionEquality()
                .equals(other._readyUsers, _readyUsers) &&
            const DeepCollectionEquality()
                .equals(other._lobbyUsers, _lobbyUsers) &&
            (identical(other.activeSessionId, activeSessionId) ||
                other.activeSessionId == activeSessionId) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_selectedCategories),
      const DeepCollectionEquality().hash(_budgetLevels),
      const DeepCollectionEquality().hash(_durationTiers),
      const DeepCollectionEquality().hash(_customActivities),
      const DeepCollectionEquality().hash(_readyUsers),
      const DeepCollectionEquality().hash(_lobbyUsers),
      activeSessionId,
      lastUpdated);

  /// Create a copy of DraftSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DraftSessionImplCopyWith<_$DraftSessionImpl> get copyWith =>
      __$$DraftSessionImplCopyWithImpl<_$DraftSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DraftSessionImplToJson(
      this,
    );
  }
}

abstract class _DraftSession implements DraftSession {
  const factory _DraftSession(
      {final List<String> selectedCategories,
      final List<int> budgetLevels,
      final List<String> durationTiers,
      final List<String> customActivities,
      final List<String> readyUsers,
      final List<String> lobbyUsers,
      final String? activeSessionId,
      @TimeStampConverter() final DateTime? lastUpdated}) = _$DraftSessionImpl;

  factory _DraftSession.fromJson(Map<String, dynamic> json) =
      _$DraftSessionImpl.fromJson;

  @override
  List<String> get selectedCategories;
  @override
  List<int> get budgetLevels;
  @override
  List<String> get durationTiers;
  @override
  List<String> get customActivities; // List of titles
  @override
  List<String> get readyUsers; // List of user IDs who clicked "Start"
  @override
  List<String> get lobbyUsers; // List of user IDs currently in lobby
  @override
  String? get activeSessionId; // Shared session ID for both partners
  @override
  @TimeStampConverter()
  DateTime? get lastUpdated;

  /// Create a copy of DraftSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DraftSessionImplCopyWith<_$DraftSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
