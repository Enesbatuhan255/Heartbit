
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/user/presentation/providers/partner_provider.dart';
import 'package:heartbit/features/user/presentation/providers/user_provider.dart';

part 'distance_provider.g.dart';

/// Calculates the distance (in km) between the current user and their partner.
/// Reuses the existing partnerStateProvider and current user's profile stream.
@riverpod
Stream<double?> partnerDistance(PartnerDistanceRef ref) {
  final userId = ref.watch(authUserIdProvider);
  if (userId == null) return const Stream.empty();

  // Watch current user's profile for their location
  final myProfileStream = ref.watch(userRepositoryProvider).watchUser(userId);
  
  // Watch partner's profile stream (already has location via partnerStateProvider)
  final partnerAsync = ref.watch(partnerStateProvider);

  return myProfileStream.map((myProfile) {
    if (myProfile == null) return null;
    if (myProfile.latitude == null || myProfile.longitude == null) return null;

    // Get partner data from the provider
    final partner = partnerAsync.valueOrNull;
    if (partner == null) return null;
    if (partner.latitude == null || partner.longitude == null) return null;

    return _haversineDistance(
      myProfile.latitude!,
      myProfile.longitude!,
      partner.latitude!,
      partner.longitude!,
    );
  });
}

/// Haversine formula to calculate distance between two coordinates in km
double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371.0; // km

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _toRadians(double degrees) => degrees * pi / 180;
