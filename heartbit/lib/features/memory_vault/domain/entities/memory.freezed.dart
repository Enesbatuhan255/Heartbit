// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Memory _$MemoryFromJson(Map<String, dynamic> json) {
  return _Memory.fromJson(json);
}

/// @nodoc
mixin _$Memory {
  String get id => throw _privateConstructorUsedError;
  String get coupleId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this Memory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryCopyWith<Memory> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryCopyWith<$Res> {
  factory $MemoryCopyWith(Memory value, $Res Function(Memory) then) =
      _$MemoryCopyWithImpl<$Res, Memory>;
  @useResult
  $Res call(
      {String id,
      String coupleId,
      String imageUrl,
      DateTime date,
      String description,
      String? title,
      DateTime? createdAt,
      String? createdBy});
}

/// @nodoc
class _$MemoryCopyWithImpl<$Res, $Val extends Memory>
    implements $MemoryCopyWith<$Res> {
  _$MemoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? imageUrl = null,
    Object? date = null,
    Object? description = null,
    Object? title = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
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
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemoryImplCopyWith<$Res> implements $MemoryCopyWith<$Res> {
  factory _$$MemoryImplCopyWith(
          _$MemoryImpl value, $Res Function(_$MemoryImpl) then) =
      __$$MemoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String coupleId,
      String imageUrl,
      DateTime date,
      String description,
      String? title,
      DateTime? createdAt,
      String? createdBy});
}

/// @nodoc
class __$$MemoryImplCopyWithImpl<$Res>
    extends _$MemoryCopyWithImpl<$Res, _$MemoryImpl>
    implements _$$MemoryImplCopyWith<$Res> {
  __$$MemoryImplCopyWithImpl(
      _$MemoryImpl _value, $Res Function(_$MemoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? imageUrl = null,
    Object? date = null,
    Object? description = null,
    Object? title = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_$MemoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coupleId: null == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemoryImpl implements _Memory {
  const _$MemoryImpl(
      {required this.id,
      required this.coupleId,
      required this.imageUrl,
      required this.date,
      required this.description,
      this.title,
      this.createdAt,
      this.createdBy});

  factory _$MemoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryImplFromJson(json);

  @override
  final String id;
  @override
  final String coupleId;
  @override
  final String imageUrl;
  @override
  final DateTime date;
  @override
  final String description;
  @override
  final String? title;
  @override
  final DateTime? createdAt;
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'Memory(id: $id, coupleId: $coupleId, imageUrl: $imageUrl, date: $date, description: $description, title: $title, createdAt: $createdAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.coupleId, coupleId) ||
                other.coupleId == coupleId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, coupleId, imageUrl, date,
      description, title, createdAt, createdBy);

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryImplCopyWith<_$MemoryImpl> get copyWith =>
      __$$MemoryImplCopyWithImpl<_$MemoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryImplToJson(
      this,
    );
  }
}

abstract class _Memory implements Memory {
  const factory _Memory(
      {required final String id,
      required final String coupleId,
      required final String imageUrl,
      required final DateTime date,
      required final String description,
      final String? title,
      final DateTime? createdAt,
      final String? createdBy}) = _$MemoryImpl;

  factory _Memory.fromJson(Map<String, dynamic> json) = _$MemoryImpl.fromJson;

  @override
  String get id;
  @override
  String get coupleId;
  @override
  String get imageUrl;
  @override
  DateTime get date;
  @override
  String get description;
  @override
  String? get title;
  @override
  DateTime? get createdAt;
  @override
  String? get createdBy;

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryImplCopyWith<_$MemoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
