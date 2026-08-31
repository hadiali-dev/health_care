import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/geo_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final LocationService _locationService = LocationService();
  final GeoService _geoService = GeoService();
  final AuthService _authService = AuthService();

  static const double _radiusKm = 0.2; // 200 meters, per spec

  @override
  void initState() {
    super.initState();
    _checkNearbyPatients();
  }

  Future<void> _checkNearbyPatients() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final position = await _locationService.getCurrentPosition();

      await _geoService.updateUserLocation(
        uid: currentUser.uid,
        lat: position.latitude,
        lng: position.longitude,
      );

      final nearby = await _geoService.fetchNearbyUnhealthyPatients(
        centerLat: position.latitude,
        centerLng: position.longitude,
        radiusInKm: _radiusKm,
        excludeUid: currentUser.uid,
      );

      if (nearby.isNotEmpty) {
        await NotificationService.instance.showNearbyPatientAlert(nearby.length);
      }
    } catch (_) {
      // Deliberately silent: this is a background check the patient never
      // explicitly triggered, so surfacing a permission/GPS error here
      // would just be noise on a screen that's supposed to show only the
      // app name. Worth revisiting once you build proper permission UX.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'HealthCare',
        style: theme.textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
      ),
    );
  }
}