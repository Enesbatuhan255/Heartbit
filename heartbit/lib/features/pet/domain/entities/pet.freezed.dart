// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Pet _$PetFromJson(Map<String, dynamic> json) {
  return _Pet.fromJson(json);
}

/// @nodoc
mixin _$Pet {
  String get id => throw _privateConstructorUsedError;
  String get coupleId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  double get experience =>
      throw _privateConstructorUsedError; // XP within current level
  double get totalXp =>
      throw _privateConstructorUsedError; // Total accumulated XP
  double get hunger => throw _privateConstructorUsedError; // 100 = full
  double get happiness => throw _privateConstructorUsedError; // 100 = max happy
  DateTime? get lastFed => throw _privateConstructorUsedError;
  DateTime? get lastInteracted => throw _privateConstructorUsedError;
  PetInteraction? get lastInteraction => throw _privateConstructorUsedError;

  /// Serializes this Pet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PetCopyWith<Pet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PetCopyWith<$Res> {
  factory $PetCopyWith(Pet value, $Res Function(Pet) then) =
      _$PetCopyWithImpl<$Res, Pet>;
  @useResult
  $Res call(
      {String id,
      String coupleId,
      String name,
      int level,
      double experience,
      double totalXp,
      double hunger,
      double happiness,
      DateTime? lastFed,
      DateTime? lastInteracted,
      PetInteraction? lastInteraction});

  $PetInteractionCopyWith<$Res>? get lastInteraction;
}

/// @nodoc
class _$PetCopyWithImpl<$Res, $Val extends Pet> implements $PetCopyWith<$Res> {
  _$PetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? name = null,
    Object? level = null,
    Object? experience = null,
    Object? totalXp = null,
    Object? hunger = null,
    Object? happiness = null,
    Object? lastFed = freezed,
    Object? lastInteracted = freezed,
    Object? lastInteraction = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coupleId: null == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as double,
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as double,
      hunger: null == hunger
          ? _value.hunger
          : hunger // ignore: cast_nullable_to_non_nullable
              as double,
      happiness: null == happiness
          ? _value.happiness
          : happiness // ignore: cast_nullable_to_non_nullable
              as double,
      lastFed: freezed == lastFed
          ? _value.lastFed
          : lastFed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastInteracted: freezed == lastInteracted
          ? _value.lastInteracted
          : lastInteracted // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastInteraction: freezed == lastInteraction
          ? _value.lastInteraction
          : lastInteraction // ignore: cast_nullable_to_non_nullable
              as PetInteraction?,
    ) as $Val);
  }

  /// Create a copy of Pet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PetInteractionCopyWith<$Res>? get lastInteraction {
    if (_value.lastInteraction == null) {
      return null;
    }

    return $PetInteractionCopyWith<$Res>(_value.lastInteraction!, (value) {
      return _then(_value.copyWith(lastInteraction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PetImplCopyWith<$Res> implements $PetCopyWith<$Res> {
  factory _$$PetImplCopyWith(_$PetImpl value, $Res Function(_$PetImpl) then) =
      __$$PetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String coupleId,
      String name,
      int level,
      double experience,
      double totalXp,
      double hunger,
      double happiness,
      DateTime? lastFed,
      DateTime? lastInteracted,
      PetInteraction? lastInteraction});

  @override
  $PetInteractionCopyWith<$Res>? get lastInteraction;
}

/// @nodoc
class __$$PetImplCopyWithImpl<$Res> extends _$PetCopyWithImpl<$Res, _$PetImpl>
    implements _$$PetImplCopyWith<$Res> {
  __$$PetImplCopyWithImpl(_$PetImpl _value, $Res Function(_$PetImpl) _then)
      : super(_value, _then);

  /// Create a copy of Pet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? name = null,
    Object? level = null,
    Object? experience = null,
    Object? totalXp = null,
    Object? hunger = null,
    Object? happiness = null,
    Object? lastFed = freezed,
    Object? lastInteracted = freezed,
    Object? lastInteraction = freezed,
  }) {
    return _then(_$PetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coupleId: null == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as double,
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as double,
      hunger: null == hunger
          ? _value.hunger
          : hunger // ignore: cast_nullable_to_non_nullable
              as double,
      happiness: null == happiness
          ? _value.happiness
          : happiness // ignore: cast_nullable_to_non_nullable
              as double,
      lastFed: freezed == lastFed
          ? _value.lastFed
          : lastFed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastInteracted: freezed == lastInteracted
          ? _value.lastInteracted
          : lastInteracted // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastInteraction: freezed == lastInteraction
          ? _value.lastInteraction
          : lastInteraction // ignore: cast_nullable_to_non_nullable
              as PetInteraction?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PetImpl extends _Pet {
  const _$PetImpl(
      {required this.id,
      required this.coupleId,
      this.name = 'Baby Egg',
      this.level = 1,
      this.experience = 0.0,
      this.totalXp = 0.0,
      this.hunger = 100.0,
      this.happiness = 100.0,
      this.lastFed,
      this.lastInteracted,
      this.lastInteraction})
      : super._();

  factory _$PetImpl.fromJson(Map<String, dynamic> json) =>
      _$$PetImplFromJson(json);

  @override
  final String id;
  @override
  final String coupleId;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final double experience;
// XP within current level
  @override
  @JsonKey()
  final double totalXp;
// Total accumulated XP
  @override
  @JsonKey()
  final double hunger;
// 100 = full
  @override
  @JsonKey()
  final double happiness;
// 100 = max happy
  @override
  final DateTime? lastFed;
  @override
  final DateTime? lastInteracted;
  @override
  final PetInteraction? lastInteraction;

  @override
  String toString() {
    return 'Pet(id: $id, coupleId: $coupleId, name: $name, level: $level, experience: $experience, totalXp: $totalXp, hunger: $hunger, happiness: $happiness, lastFed: $lastFed, lastInteracted: $lastInteracted, lastInteraction: $lastInteraction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.coupleId, coupleId) ||
                other.coupleId == coupleId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.totalXp, totalXp) || other.totalXp == totalXp) &&
            (identical(other.hunger, hunger) || other.hunger == hunger) &&
            (identical(other.happiness, happiness) ||
                other.happiness == happiness) &&
            (identical(other.lastFed, lastFed) || other.lastFed == lastFed) &&
            (identical(other.lastInteracted, lastInteracted) ||
                other.lastInteracted == lastInteracted) &&
            (identical(other.lastInteraction, lastInteraction) ||
                other.lastInteraction == lastInteraction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      coupleId,
      name,
      level,
      experience,
      totalXp,
      hunger,
      happiness,
      lastFed,
      lastInteracted,
      lastInteraction);

  /// Create a copy of Pet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PetImplCopyWith<_$PetImpl> get copyWith =>
      __$$PetImplCopyWithImpl<_$PetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PetImplToJson(
      this,
    );
  }
}

abstract class _Pet extends Pet {
  const factory _Pet(
      {required final String id,
      required final String coupleId,
      final String name,
      final int level,
      final double experience,
      final double totalXp,
      final double hunger,
      final double happiness,
      final DateTime? lastFed,
      final DateTime? lastInteracted,
      final PetInteraction? lastInteraction}) = _$PetImpl;
  const _Pet._() : super._();

  factory _Pet.fromJson(Map<String, dynamic> json) = _$PetImpl.fromJson;

  @override
  String get id;
  @override
  String get coupleId;
  @override
  String get name;
  @override
  int get level;
  @override
  double get experience; // XP within current level
  @override
  double get totalXp; // Total accumulated XP
  @override
  double get hunger; // 100 = full
  @override
  double get happiness; // 100 = max happy
  @override
  DateTime? get lastFed;
  @override
  DateTime? get lastInteracted;
  @override
  PetInteraction? get lastInteraction;

  /// Create a copy of Pet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PetImplCopyWith<_$PetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PetInteraction _$PetInteractionFromJson(Map<String, dynamic> json) {
  return _PetInteraction.fromJson(json);
}

/// @nodoc
mixin _$PetInteraction {
  String get userId => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'poke', 'love', 'feed'
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this PetInteraction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PetInteraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PetInteractionCopyWith<PetInteraction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PetInteractionCopyWith<$Res> {
  factory $PetInteractionCopyWith(
          PetInteraction value, $Res Function(PetInteraction) then) =
      _$PetInteractionCopyWithImpl<$Res, PetInteraction>;
  @useResult
  $Res call({String userId, String type, DateTime timestamp});
}

/// @nodoc
class _$PetInteractionCopyWithImpl<$Res, $Val extends PetInteraction>
    implements $PetInteractionCopyWith<$Res> {
  _$PetInteractionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PetInteraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PetInteractionImplCopyWith<$Res>
    implements $PetInteractionCopyWith<$Res> {
  factory _$$PetInteractionImplCopyWith(_$PetInteractionImpl value,
          $Res Function(_$PetInteractionImpl) then) =
      __$$PetInteractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String type, DateTime timestamp});
}

/// @nodoc
class __$$PetInteractionImplCopyWithImpl<$Res>
    extends _$PetInteractionCopyWithImpl<$Res, _$PetInteractionImpl>
    implements _$$PetInteractionImplCopyWith<$Res> {
  __$$PetInteractionImplCopyWithImpl(
      _$PetInteractionImpl _value, $Res Function(_$PetInteractionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PetInteraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(_$PetInteractionImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PetInteractionImpl implements _PetInteraction {
  const _$PetInteractionImpl(
      {required this.userId, required this.type, required this.timestamp});

  factory _$PetInteractionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PetInteractionImplFromJson(json);

  @override
  final String userId;
  @override
  final String type;
// 'poke', 'love', 'feed'
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'PetInteraction(userId: $userId, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PetInteractionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, type, timestamp);

  /// Create a copy of PetInteraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PetInteractionImplCopyWith<_$PetInteractionImpl> get copyWith =>
      __$$PetInteractionImplCopyWithImpl<_$PetInteractionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PetInteractionImplToJson(
      this,
    );
  }
}

abstract class _PetInteraction implements PetInteraction {
  const factory _PetInteraction(
      {required final String userId,
      required final String type,
      required final DateTime timestamp}) = _$PetInteractionImpl;

  factory _PetInteraction.fromJson(Map<String, dynamic> json) =
      _$PetInteractionImpl.fromJson;

  @override
  String get userId;
  @override
  String get type; // 'poke', 'love', 'feed'
  @override
  DateTime get timestamp;

  /// Create a copy of PetInteraction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PetInteractionImplCopyWith<_$PetInteractionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
