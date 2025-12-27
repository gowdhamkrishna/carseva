class Mechanic {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final bool isOpen;
  final String? openingHours;

  const Mechanic({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.services,
    required this.rating,
    required this.reviewCount,
    this.imageUrl,
    this.isOpen = true,
    this.openingHours,
  });

  /// Calculate distance from user location (in km)
  double distanceFrom(double userLat, double userLon) {
    return _calculateDistance(userLat, userLon, latitude, longitude);
  }

  /// Haversine formula for distance calculation
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() * lat2.toRadians().cos() *
        (dLon / 2).sin() * (dLon / 2).sin();

    final double c = 2 * (a.sqrt()).asin();
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }
}

extension on double {
  double toRadians() => this * (3.14159265359 / 180.0);
  double sin() => this.toRadians().sin();
  double cos() => this.toRadians().cos();
  double asin() => this.asin();
  double sqrt() => this.sqrt();
}

/// Mock data for nearby mechanics
class MechanicData {
  /// Generate mock mechanics near the user's location
  static List<Mechanic> getMockMechanics({double? userLat, double? userLon}) {
    // If no user location provided, use default (Bangalore)
    final baseLat = userLat ?? 12.9716;
    final baseLon = userLon ?? 77.5946;

    // Generate mechanics within ~5km radius of user location
    return [
      Mechanic(
        id: '1',
        name: 'AutoCare Service Center',
        address: 'Near Main Road, Your Area',
        phoneNumber: '+91 98765 43210',
        latitude: baseLat + 0.01, // ~1.1 km north
        longitude: baseLon + 0.01,
        services: const ['General Repair', 'Oil Change', 'Brake Service', 'AC Repair'],
        rating: 4.5,
        reviewCount: 120,
        isOpen: true,
        openingHours: '9 AM - 7 PM',
      ),
      Mechanic(
        id: '2',
        name: 'Quick Fix Auto Workshop',
        address: 'Market Street, Nearby',
        phoneNumber: '+91 98765 43211',
        latitude: baseLat - 0.015, // ~1.7 km south
        longitude: baseLon + 0.02,
        services: const ['Engine Repair', 'Transmission', 'Electrical', 'Painting'],
        rating: 4.2,
        reviewCount: 85,
        isOpen: true,
        openingHours: '8 AM - 8 PM',
      ),
      Mechanic(
        id: '3',
        name: 'Elite Motors Service',
        address: 'Industrial Area, Local',
        phoneNumber: '+91 98765 43212',
        latitude: baseLat + 0.02, // ~2.2 km north
        longitude: baseLon - 0.01,
        services: const ['Denting', 'Painting', 'Detailing', 'Polishing'],
        rating: 4.7,
        reviewCount: 200,
        isOpen: false,
        openingHours: '10 AM - 6 PM',
      ),
      Mechanic(
        id: '4',
        name: 'Speedy Service Station',
        address: 'Highway Junction, Nearby',
        phoneNumber: '+91 98765 43213',
        latitude: baseLat - 0.025, // ~2.8 km south
        longitude: baseLon - 0.015,
        services: const ['Quick Service', 'Oil Change', 'Tire Rotation', 'Battery'],
        rating: 4.0,
        reviewCount: 65,
        isOpen: true,
        openingHours: '24/7',
      ),
      Mechanic(
        id: '5',
        name: 'Premium Auto Care',
        address: 'Commercial Complex, Your City',
        phoneNumber: '+91 98765 43214',
        latitude: baseLat + 0.03, // ~3.3 km north
        longitude: baseLon + 0.025,
        services: const ['Luxury Car Service', 'Diagnostics', 'Performance Tuning'],
        rating: 4.8,
        reviewCount: 150,
        isOpen: true,
        openingHours: '9 AM - 9 PM',
      ),
    ];
  }
}
