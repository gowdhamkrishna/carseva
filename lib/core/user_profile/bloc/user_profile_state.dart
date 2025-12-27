import 'package:carseva/core/user_profile/domain/user_profile.dart';

abstract class UserProfileState {
  const UserProfileState();
}

/// Initial state - not initialized
class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

/// Loading user profile data
class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

/// User profile loaded with vehicle data
class UserProfileLoaded extends UserProfileState {
  final UserProfile profile;

  const UserProfileLoaded(this.profile);

  /// Quick access to vehicle
  get vehicle => profile.vehicle;

  /// Check if user has vehicle
  bool get hasVehicle => profile.hasVehicle;
}

/// User logged in but no vehicle registered
class UserProfileNoVehicle extends UserProfileState {
  final UserProfile profile;

  const UserProfileNoVehicle(this.profile);
}

/// Error loading or updating profile
class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);
}

/// Vehicle updated successfully
class VehicleUpdated extends UserProfileState {
  final UserProfile profile;

  const VehicleUpdated(this.profile);

  get vehicle => profile.vehicle;
}
