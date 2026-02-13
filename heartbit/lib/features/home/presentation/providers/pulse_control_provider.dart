import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pulse_control_provider.g.dart';

@riverpod
class PulseTrigger extends _$PulseTrigger {
  @override
  int build() {
    return 0;
  }

  void trigger() {
    state++;
  }
}
