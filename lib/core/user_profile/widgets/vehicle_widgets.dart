import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that provides easy access to user vehicle data
class VehicleDataBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, dynamic vehicle) builder;
  final Widget? noVehicleWidget;
  final Widget? loadingWidget;

  const VehicleDataBuilder({
    super.key,
    required this.builder,
    this.noVehicleWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (state is UserProfileLoaded) {
          return builder(context, state.vehicle);
        }

        if (state is UserProfileNoVehicle) {
          return noVehicleWidget ??
              const Center(
                child: Text(
                  'No vehicle registered',
                  style: TextStyle(color: Colors.white70),
                ),
              );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Widget that shows vehicle summary card
class VehicleSummaryCard extends StatelessWidget {
  const VehicleSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is! UserProfileLoaded) {
          return const SizedBox.shrink();
        }

        final vehicle = state.vehicle;
        if (vehicle == null) return const SizedBox.shrink();

        return Container(
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
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
                          '${vehicle.vehicle.brand} ${vehicle.vehicle.model}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          vehicle.vehicle.variant,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    vehicle.vehicle.year.toString(),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.local_gas_station,
                    vehicle.vehicle.fuelType,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.speed,
                    '${vehicle.usage.odometerKm} km',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
