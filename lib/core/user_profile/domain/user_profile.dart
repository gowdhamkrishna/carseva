import 'package:carseva/carinfo/domain/entities/car_entity.dart';

/// User profile containing user info and vehicle details
class UserProfile {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserCarEntity? vehicle;
  final DateTime? lastUpdated;

  const UserProfile({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.vehicle,
    this.lastUpdated,
  });

  /// Check if user has a vehicle registered
  bool get hasVehicle => vehicle != null;

  /// Copy with method for updating profile
  UserProfile copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    UserCarEntity? vehicle,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicle: vehicle ?? this.vehicle,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, email: $email, hasVehicle: $hasVehicle)';
  }
}
