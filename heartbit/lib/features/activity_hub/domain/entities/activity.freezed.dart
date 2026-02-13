// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  return _Activity.fromJson(json);
}

/// @nodoc
mixin _$Activity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get estimatedTime => throw _privateConstructorUsedError;
  int get budgetLevel =>
      throw _privateConstructorUsedError; // 1=Free, 2=$, 3=$$, 4=$$$
  int get intensityLevel =>
      throw _privateConstructorUsedError; // 1=Low, 2=Medium, 3=High
  List<String> get moods =>
      throw _privateConstructorUsedError; // chill, romantic, adventure
  List<String> get tags => throw _privateConstructorUsedError;
  String get activityType =>
      throw _privateConstructorUsedError; // 'global' | 'custom'
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityCopyWith<Activity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) then) =
      _$ActivityCopyWithImpl<$Res, Activity>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      String category,
      String estimatedTime,
      int budgetLevel,
      int intensityLevel,
      List<String> moods,
      List<String> tags,
      String activityType,
      bool isActive});
}

/// @nodoc
class _$ActivityCopyWithImpl<$Res, $Val extends Activity>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? category = null,
    Object? estimatedTime = null,
    Object? budgetLevel = null,
    Object? intensityLevel = null,
    Object? moods = null,
    Object? tags = null,
    Object? activityType = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedTime: null == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as String,
      budgetLevel: null == budgetLevel
          ? _value.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as int,
      intensityLevel: null == intensityLevel
          ? _value.intensityLevel
          : intensityLevel // ignore: cast_nullable_to_non_nullable
              as int,
      moods: null == moods
          ? _value.moods
          : moods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$ActivityImplCopyWith(
          _$ActivityImpl value, $Res Function(_$ActivityImpl) then) =
      __$$ActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      String category,
      String estimatedTime,
      int budgetLevel,
      int intensityLevel,
      List<String> moods,
      List<String> tags,
      String activityType,
      bool isActive});
}

/// @nodoc
class __$$ActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$ActivityImpl>
    implements _$$ActivityImplCopyWith<$Res> {
  __$$ActivityImplCopyWithImpl(
      _$ActivityImpl _value, $Res Function(_$ActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? category = null,
    Object? estimatedTime = null,
    Object? budgetLevel = null,
    Object? intensityLevel = null,
    Object? moods = null,
    Object? tags = null,
    Object? activityType = null,
    Object? isActive = null,
  }) {
    return _then(_$ActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedTime: null == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as String,
      budgetLevel: null == budgetLevel
          ? _value.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as int,
      intensityLevel: null == intensityLevel
          ? _value.intensityLevel
          : intensityLevel // ignore: cast_nullable_to_non_nullable
              as int,
      moods: null == moods
          ? _value._moods
          : moods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityImpl implements _Activity {
  const _$ActivityImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.category,
      this.estimatedTime = '1-2 hours',
      this.budgetLevel = 2,
      this.intensityLevel = 2,
      final List<String> moods = const [],
      final List<String> tags = const [],
      this.activityType = 'global',
      this.isActive = true})
      : _moods = moods,
        _tags = tags;

  factory _$ActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final String category;
  @override
  @JsonKey()
  final String estimatedTime;
  @override
  @JsonKey()
  final int budgetLevel;
// 1=Free, 2=$, 3=$$, 4=$$$
  @override
  @JsonKey()
  final int intensityLevel;
// 1=Low, 2=Medium, 3=High
  final List<String> _moods;
// 1=Low, 2=Medium, 3=High
  @override
  @JsonKey()
  List<String> get moods {
    if (_moods is EqualUnmodifiableListView) return _moods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moods);
  }

// chill, romantic, adventure
  final List<String> _tags;
// chill, romantic, adventure
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String activityType;
// 'global' | 'custom'
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, category: $category, estimatedTime: $estimatedTime, budgetLevel: $budgetLevel, intensityLevel: $intensityLevel, moods: $moods, tags: $tags, activityType: $activityType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            (identical(other.budgetLevel, budgetLevel) ||
                other.budgetLevel == budgetLevel) &&
            (identical(other.intensityLevel, intensityLevel) ||
                other.intensityLevel == intensityLevel) &&
            const DeepCollectionEquality().equals(other._moods, _moods) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      imageUrl,
      category,
      estimatedTime,
      budgetLevel,
      intensityLevel,
      const DeepCollectionEquality().hash(_moods),
      const DeepCollectionEquality().hash(_tags),
      activityType,
      isActive);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      __$$ActivityImplCopyWithImpl<_$ActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityImplToJson(
      this,
    );
  }
}

abstract class _Activity implements Activity {
  const factory _Activity(
      {required final String id,
      required final String title,
      required final String description,
      required final String imageUrl,
      required final String category,
      final String estimatedTime,
      final int budgetLevel,
      final int intensityLevel,
      final List<String> moods,
      final List<String> tags,
      final String activityType,
      final bool isActive}) = _$ActivityImpl;

  factory _Activity.fromJson(Map<String, dynamic> json) =
      _$ActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  String get category;
  @override
  String get estimatedTime;
  @override
  int get budgetLevel; // 1=Free, 2=$, 3=$$, 4=$$$
  @override
  int get intensityLevel; // 1=Low, 2=Medium, 3=High
  @override
  List<String> get moods; // chill, romantic, adventure
  @override
  List<String> get tags;
  @override
  String get activityType; // 'global' | 'custom'
  @override
  bool get isActive;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
