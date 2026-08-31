import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String gender;
  final String role; // 'medical_staff' or 'patient'
  final String healthStatus; // 'healthy' or 'patient'
  final GeoPoint? location; // read from the 'geo' field's geopoint
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.role,
    this.healthStatus = 'healthy',
    this.location,
    required this.createdAt,
  });

  double? get latitude => location?.latitude;
  double? get longitude => location?.longitude;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'gender': gender,
      'role': role,
      'healthStatus': healthStatus,
      'createdAt': createdAt.toIso8601String(),
      // 'geo' is deliberately not written here — it's written separately
      // via GeoService.updateUserLocation, which uses geoflutterfire_plus's
      // setPoint() so the geohash actually gets generated correctly.
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    GeoPoint? location;
    final geoField = map['geo'];
    if (geoField is Map<String, dynamic> && geoField['geopoint'] is GeoPoint) {
      location = geoField['geopoint'] as GeoPoint;
    }

    return UserModel(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      gender: map['gender'] as String,
      role: map['role'] as String,
      healthStatus: map['healthStatus'] as String? ?? 'healthy',
      location: location,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}