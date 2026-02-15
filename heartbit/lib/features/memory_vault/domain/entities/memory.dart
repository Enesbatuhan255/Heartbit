import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory.freezed.dart';
part 'memory.g.dart';

@freezed
class Memory with _$Memory {
  const factory Memory({
    required String id,
    required String coupleId,
    required String imageUrl,
    required DateTime date,
    required String description,
    String? title,
    DateTime? createdAt,
    String? createdBy,
  }) = _Memory;

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
}
