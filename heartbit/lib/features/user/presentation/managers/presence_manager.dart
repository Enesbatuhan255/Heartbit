import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/user/presentation/providers/user_provider.dart';
import 'package:heartbit/features/user/presentation/providers/partner_provider.dart';

/// Manages presence (online status) and interaction (heartbeat bursts).
/// It updates the user's `lastSeen` periodically and calculates the
/// current heartbeat animation speed based on the partner's activity.
class PresenceManager extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context, double speed) builder;

  const PresenceManager({
    super.key,
    required this.builder,
  });

  @override
  ConsumerState<PresenceManager> createState() => _PresenceManagerState();
}

class _PresenceManagerState extends ConsumerState<PresenceManager> {
  Timer? _heartbeatTimer;
  Timer? _burstDecayTimer;
  
  // Animation speed state
  double _currentSpeed = 1.0;
  DateTime? _lastPartnerInteraction;

  @override
  void initState() {
    super.initState();
    // Start sending "I'm alive" signals
    _startHeartbeat();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _burstDecayTimer?.cancel();
    super.dispose();
  }

  void _startHeartbeat() {
    // Update lastSeen every minute
    _updatePresence(); // Initial call
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updatePresence();
    });
  }

  Future<void> _updatePresence() async {
    final userId = ref.read(authUserIdProvider);
    if (userId != null) {
      try {
        await ref.read(userRepositoryProvider).updateLastSeen(userId);
      } catch (e) {
        debugPrint('Failed to update presence: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch partner to react to their presence/interaction
    final partnerAsync = ref.watch(partnerStateProvider);
    
    return partnerAsync.when(
      data: (partner) {
        if (partner == null) return widget.builder(context, 1.0);

        // 1. Check if partner is online (lastSeen < 2 mins ago)
        bool isOnline = false;
        if (partner.lastSeen != null) {
          final timeDiff = DateTime.now().difference(partner.lastSeen!);
          if (timeDiff.inMinutes < 2) {
            isOnline = true;
          }
        }

        // 2. Check for new interaction (Burst Logic)
        if (partner.lastInteraction != null) {
           // If we have a new interaction timestamp we haven't processed (or just changed)
           // Logic: If partner.lastInteraction is essentially "now" (e.g. < 5 seconds ago) 
           // AND it's newer than what we last stored, TRIGGER BURST.
           // However, since Stream builds continuously, we just check relative time.
           
           final interactionDiff = DateTime.now().difference(partner.lastInteraction!);
           
           // If interaction was very recent (< 2 seconds), trigger high speed
           if (interactionDiff.inSeconds < 5) { // 5s window for Firestore latency
             // Check if this is a "new" interaction to trigger the decay animation start
             if (_lastPartnerInteraction != partner.lastInteraction) {
               _lastPartnerInteraction = partner.lastInteraction;
               // Trigger Burst!
               _triggerBurst();
             }
           }
        }

        // 3. Determine Target Speed based on state
        // If we are in the middle of a burst decay, handling is done in _triggerBurst/Timer
        // But here we set the "base" speed.
        
        // If burst timer is active, _currentSpeed is being controlled by it.
        // If not, we set it based on Online status.
        if (_burstDecayTimer == null || !_burstDecayTimer!.isActive) {
           _currentSpeed = isOnline ? 2.5 : 1.0;
        }

        return widget.builder(context, _currentSpeed);
      },
      loading: () => widget.builder(context, 1.0),
      error: (_, __) => widget.builder(context, 1.0),
    );
  }

  void _triggerBurst() {
    // Start at high speed and decay to normal
    setState(() {
      _currentSpeed = 6.0;
    });

    _burstDecayTimer?.cancel();
    // Decay over 2 seconds back to base (which will be checked in build)
    int steps = 20;
    int currentStep = 0;
    const duration = Duration(milliseconds: 100); // 2 seconds total

    _burstDecayTimer = Timer.periodic(duration, (timer) {
      currentStep++;
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        // Linear decay for simplicity
        // From 6.0 down to ~2.5 (or 1.0)
        // Let's assume we decay to 2.5 (online speed) as burst implies we are interacting = online
        if (_currentSpeed > 2.5) {
          _currentSpeed -= 0.2; 
        } else {
           timer.cancel();
        }
      });
    });
  }
}
