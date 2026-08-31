import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/geo_service.dart';
import '../../core/services/location_service.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
class NearbyPatientsMapScreen extends StatefulWidget {
  const NearbyPatientsMapScreen({super.key});

  @override
  State<NearbyPatientsMapScreen> createState() => _NearbyPatientsMapScreenState();
}

class _NearbyPatientsMapScreenState extends State<NearbyPatientsMapScreen> {
  final LocationService _locationService = LocationService();
  final GeoService _geoService = GeoService();
  final AuthService _authService = AuthService();

  static const double _radiusKm = 0.2;

  bool _isLoading = true;
  String? _errorMessage;
  LatLng? _center;
  List<UserModel> _nearbyPatients = [];

  @override
  void initState() {
    super.initState();
    _loadNearbyPatients();
  }

  Future<void> _loadNearbyPatients() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final currentUser = _authService.currentUser;
      if (currentUser == null) throw Exception('Not signed in.');

      final nearby = await _geoService.fetchNearbyUnhealthyPatients(
        centerLat: position.latitude,
        centerLng: position.longitude,
        radiusInKm: _radiusKm,
        excludeUid: currentUser.uid,
      );

      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _nearbyPatients = nearby;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Could not load nearby patients.';
        _isLoading = false;
      });
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_center != null) {
      markers.add(
        Marker(
          point: _center!,
          width: 44,
          height: 44,
          child: const Tooltip(
            message: 'You',
            child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
          ),
        ),
      );
    }

    for (final patient in _nearbyPatients) {
      if (patient.latitude == null || patient.longitude == null) continue;
      markers.add(
        Marker(
          point: LatLng(patient.latitude!, patient.longitude!),
          width: 44,
          height: 44,
          child: Tooltip(
            message: patient.fullName,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Patients')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _center!,
                    initialZoom: 15,
                  ),
                  children: [
    Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.yourcompany.healthcare_app',
      tileProvider: CancellableNetworkTileProvider(),
    ),
    MarkerLayer(markers: _buildMarkers()),
  ],
),
    );
  }
}