import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/mechanic_model.dart';
import '../../data/mechanic_ai_service.dart';

class FindMechanicsPage extends StatefulWidget {
  const FindMechanicsPage({super.key});

  @override
  State<FindMechanicsPage> createState() => _FindMechanicsPageState();
}

class _FindMechanicsPageState extends State<FindMechanicsPage> {
  bool _isLoading = true;
  bool _locationDenied = false;
  Position? _currentPosition;
  List<Mechanic> _mechanics = [];
  final _aiService = MechanicAIService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _locationDenied = true;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _locationDenied = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _locationDenied = true;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Generate mechanics using AI (2-3 locations)
      List<Mechanic> allMechanics = await _aiService.generateNearbyMechanics(
        position.latitude,
        position.longitude,
      );
      
      // Sort by distance
      allMechanics.sort((a, b) {
        double distA = _calculateDistance(
          position.latitude,
          position.longitude,
          a.latitude,
          a.longitude,
        );
        double distB = _calculateDistance(
          position.latitude,
          position.longitude,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });

      setState(() {
        _currentPosition = position;
        _mechanics = allMechanics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationDenied = true;
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF0F1535),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _locationDenied
                        ? _buildLocationDeniedState()
                        : _buildMechanicsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Find Mechanics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4CAF50)),
          SizedBox(height: 20),
          Text(
            'Finding mechanics near you...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Using AI to generate realistic locations',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDeniedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Location Access Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please enable location services and grant permission to find nearby mechanics',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _locationDenied = false;
                    });
                    _getCurrentLocation();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMechanicsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mechanics.length,
      itemBuilder: (context, index) {
        final mechanic = _mechanics[index];
        final distance = _currentPosition != null
            ? _calculateDistance(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                mechanic.latitude,
                mechanic.longitude,
              )
            : 0.0;
        return _buildMechanicCard(mechanic, distance);
      },
    );
  }

  Widget _buildMechanicCard(Mechanic mechanic, double distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.8),
            const Color(0xFF2D3561).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.build,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${mechanic.rating} (${mechanic.reviewCount})',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(mechanic.isOpen),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.place_outlined, color: Colors.white.withOpacity(0.6), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    mechanic.address,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(Icons.navigation, '${distance.toStringAsFixed(1)} km'),
                const SizedBox(width: 8),
                if (mechanic.openingHours != null)
                  _buildInfoChip(Icons.access_time, mechanic.openingHours!),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mechanic.services
                  .take(3)
                  .map((service) => _buildServiceChip(service))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(mechanic.phoneNumber),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _getDirections(mechanic),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF4CAF50).withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpen ? const Color(0xFF4CAF50) : Colors.red,
          width: 1,
        ),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          color: isOpen ? const Color(0xFF4CAF50) : Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service,
        style: TextStyle(
          color: const Color(0xFF4CAF50).withOpacity(0.9),
          fontSize: 11,
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _getDirections(Mechanic mechanic) async {
    try {
      // Try Google Maps app first with coordinates
      final mapsUrl = 'google.navigation:q=${mechanic.latitude},${mechanic.longitude}';
      final mapsUri = Uri.parse(mapsUrl);
      
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to web Google Maps
      final webUrl = 'https://www.google.com/maps/dir/?api=1&destination=${mechanic.latitude},${mechanic.longitude}';
      final webUri = Uri.parse(webUrl);
      
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Last fallback - simple maps search
      final searchUrl = 'https://www.google.com/maps/search/?api=1&query=${mechanic.latitude},${mechanic.longitude}';
      final searchUri = Uri.parse(searchUrl);
      await launchUrl(searchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open maps. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
