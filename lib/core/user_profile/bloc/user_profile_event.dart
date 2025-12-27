import 'package:carseva/carinfo/domain/entities/car_entity.dart';

abstract class UserProfileEvent {}

/// Initialize user profile - load user and vehicle data
class InitializeUserProfileEvent extends UserProfileEvent {
  final String userId;

  InitializeUserProfileEvent(this.userId);
}

/// Update vehicle information
class UpdateVehicleEvent extends UserProfileEvent {
  final String userId;
  final UserCarEntity vehicle;

  UpdateVehicleEvent({
    required this.userId,
    required this.vehicle,
  });
}

/// Refresh vehicle data from Firestore
class RefreshVehicleEvent extends UserProfileEvent {
  final String userId;

  RefreshVehicleEvent(this.userId);
}

/// Clear profile on logout
class ClearProfileEvent extends UserProfileEvent {}

/// Update user info (name, photo)
class UpdateUserInfoEvent extends UserProfileEvent {
  final String? displayName;
  final String? photoUrl;

  UpdateUserInfoEvent({
    this.displayName,
    this.photoUrl,
  });
}
