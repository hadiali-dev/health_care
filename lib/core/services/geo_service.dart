import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../models/user_model.dart';

class GeoService {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Writes/updates this user's current position, generating the geohash
  /// geoflutterfire_plus needs to run proximity queries against it.
  Future<void> updateUserLocation({
    required String uid,
    required double lat,
    required double lng,
  }) async {
    await GeoCollectionReference(_usersCollection).updatePoint(
      id: uid,
      field: 'geo',
     geopoint: GeoPoint(lat, lng),
    );
  }

  /// One-shot fetch of patients marked unhealthy within [radiusInKm] of
  /// the given center point, excluding the caller themself.
  Future<List<UserModel>> fetchNearbyUnhealthyPatients({
    required double centerLat,
    required double centerLng,
    required double radiusInKm,
    required String excludeUid,
  }) async {
    final center = GeoFirePoint(GeoPoint(centerLat, centerLng));

    final snapshots = await GeoCollectionReference(_usersCollection).fetchWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: 'geo',
      geopointFrom: (data) =>
          (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
      strictMode: true,
      queryBuilder: (query) => query
          .where('role', isEqualTo: 'patient')
          .where('healthStatus', isEqualTo: 'patient'),
    );

    return snapshots
        .where((doc) => doc.id != excludeUid)
        .map((doc) => UserModel.fromMap(doc.data()!))
        .toList();
  }
}