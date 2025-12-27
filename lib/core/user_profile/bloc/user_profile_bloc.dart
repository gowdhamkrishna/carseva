import 'package:carseva/carinfo/domain/usecases/get_current_car.dart';
import 'package:carseva/carinfo/domain/usecases/save_current.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_event.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_state.dart';
import 'package:carseva/core/user_profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global BLoC managing user vehicle profile state
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetCurrentCar getCurrentCar;
  final SaveCurrentCar saveCurrentCar;
  final FirebaseAuth firebaseAuth;

  UserProfile? _currentProfile;

  UserProfileBloc({
    required this.getCurrentCar,
    required this.saveCurrentCar,
    required this.firebaseAuth,
  }) : super(const UserProfileInitial()) {
    // Initialize user profile
    on<InitializeUserProfileEvent>((event, emit) async {
      emit(const UserProfileLoading());
      try {
        final user = firebaseAuth.currentUser;
        if (user == null) {
          emit(const UserProfileInitial());
          return;
        }

        // Load vehicle data
        final vehicle = await getCurrentCar(event.userId);

        _currentProfile = UserProfile(
          userId: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
          vehicle: vehicle,
          lastUpdated: DateTime.now(),
        );

        if (vehicle != null) {
          emit(UserProfileLoaded(_currentProfile!));
        } else {
          emit(UserProfileNoVehicle(_currentProfile!));
        }
      } catch (e) {
        emit(UserProfileError(e.toString()));
      }
    });

    // Update vehicle
    on<UpdateVehicleEvent>((event, emit) async {
      emit(const UserProfileLoading());
      try {
        // Save to Firestore
        await saveCurrentCar(
          userId: event.userId,
          car: event.vehicle,
        );

        // Update local profile
        _currentProfile = _currentProfile?.copyWith(
          vehicle: event.vehicle,
          lastUpdated: DateTime.now(),
        );

        if (_currentProfile != null) {
          emit(VehicleUpdated(_currentProfile!));
          // Transition to loaded state
          emit(UserProfileLoaded(_currentProfile!));
        }
      } catch (e) {
        emit(UserProfileError(e.toString()));
      }
    });

    // Refresh vehicle data
    on<RefreshVehicleEvent>((event, emit) async {
      emit(const UserProfileLoading());
      try {
        final vehicle = await getCurrentCar(event.userId);

        _currentProfile = _currentProfile?.copyWith(
          vehicle: vehicle,
          lastUpdated: DateTime.now(),
        );

        if (_currentProfile != null) {
          if (vehicle != null) {
            emit(UserProfileLoaded(_currentProfile!));
          } else {
            emit(UserProfileNoVehicle(_currentProfile!));
          }
        }
      } catch (e) {
        emit(UserProfileError(e.toString()));
      }
    });

    // Update user info
    on<UpdateUserInfoEvent>((event, emit) {
      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          displayName: event.displayName,
          photoUrl: event.photoUrl,
          lastUpdated: DateTime.now(),
        );

        if (_currentProfile!.hasVehicle) {
          emit(UserProfileLoaded(_currentProfile!));
        } else {
          emit(UserProfileNoVehicle(_currentProfile!));
        }
      }
    });

    // Clear profile
    on<ClearProfileEvent>((event, emit) {
      _currentProfile = null;
      emit(const UserProfileInitial());
    });
  }

  /// Get current profile (for direct access)
  UserProfile? get currentProfile => _currentProfile;

  /// Check if user has vehicle
  bool get hasVehicle => _currentProfile?.hasVehicle ?? false;
}
