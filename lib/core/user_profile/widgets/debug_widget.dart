import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Debug widget to show UserProfileBloc state
class UserProfileDebugCard extends StatelessWidget {
  const UserProfileDebugCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1F3A).withOpacity(0.8),
                const Color(0xFF2D3561).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bug_report,
                      color: Color(0xFF6C63FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'User Profile State',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStateInfo(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStateInfo(UserProfileState state) {
    String stateText;
    Color stateColor;
    IconData stateIcon;

    if (state is UserProfileInitial) {
      stateText = 'Not Initialized\nCall InitializeUserProfileEvent with userId';
      stateColor = Colors.orange;
      stateIcon = Icons.warning;
    } else if (state is UserProfileLoading) {
      stateText = 'Loading vehicle data...';
      stateColor = Colors.blue;
      stateIcon = Icons.hourglass_empty;
    } else if (state is UserProfileLoaded) {
      final vehicle = state.vehicle;
      stateText = vehicle != null
          ? 'Vehicle Loaded: ${vehicle.vehicle.brand} ${vehicle.vehicle.model}'
          : 'User loaded but no vehicle';
      stateColor = Colors.green;
      stateIcon = Icons.check_circle;
    } else if (state is UserProfileNoVehicle) {
      stateText = 'User logged in but no vehicle registered\nAdd vehicle data to Firestore';
      stateColor = Colors.amber;
      stateIcon = Icons.info;
    } else if (state is UserProfileError) {
      stateText = 'Error: ${(state as UserProfileError).message}';
      stateColor = Colors.red;
      stateIcon = Icons.error;
    } else {
      stateText = 'Unknown state: ${state.runtimeType}';
      stateColor = Colors.grey;
      stateIcon = Icons.help;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(stateIcon, color: stateColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            stateText,
            style: TextStyle(
              color: stateColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
