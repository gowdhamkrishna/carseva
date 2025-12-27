import 'package:carseva/carinfo/domain/entities/car_entity.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_state.dart';
import 'package:carseva/core/user_profile/pages/add_vehicle_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VehicleProfileSettingsPage extends StatelessWidget {
  const VehicleProfileSettingsPage({super.key});

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
              _buildAppBar(context),
              Expanded(
                child: BlocBuilder<UserProfileBloc, UserProfileState>(
                  builder: (context, state) {
                    if (state is UserProfileLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                      );
                    }

                    if (state is UserProfileLoaded && state.vehicle != null) {
                      return _buildVehicleDetails(context, state.vehicle!);
                    }

                    return _buildNoVehicleState(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.settings, color: Color(0xFF6C63FF), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Vehicle Profile',
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

  Widget _buildVehicleDetails(BuildContext context, UserCarEntity vehicle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditButton(context),
          const SizedBox(height: 16),
          _buildSection(
            'Vehicle Information',
            Icons.directions_car,
            const Color(0xFF6C63FF),
            [
              _buildDetailRow('Brand', vehicle.vehicle.brand),
              _buildDetailRow('Model', vehicle.vehicle.model),
              _buildDetailRow('Variant', vehicle.vehicle.variant),
              _buildDetailRow('Year', vehicle.vehicle.year.toString()),
              _buildDetailRow('Fuel Type', vehicle.vehicle.fuelType),
              _buildDetailRow('Transmission', vehicle.vehicle.transmission),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Registration',
            Icons.assignment,
            const Color(0xFF4CAF50),
            [
              _buildDetailRow('Registration Number', vehicle.registration.registrationNumber),
              _buildDetailRow('State', vehicle.registration.state),
              _buildDetailRow('City', vehicle.registration.city),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Ownership',
            Icons.person,
            const Color(0xFFFF9800),
            [
              _buildDetailRow('Purchase Date', DateFormat('dd MMM yyyy').format(vehicle.ownership.purchaseDate)),
              _buildDetailRow('Purchase Price', '₹${vehicle.ownership.purchasePrice.toString()}'),
              _buildDetailRow('Ownership Type', vehicle.ownership.ownershipType),
              _buildDetailRow('Financed', vehicle.ownership.isFinanced ? 'Yes' : 'No'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Usage',
            Icons.speed,
            const Color(0xFF2196F3),
            [
              _buildDetailRow('Odometer', '${vehicle.usage.odometerKm} km'),
              _buildDetailRow('Daily Average', '${vehicle.usage.dailyAverageKm} km'),
              _buildDetailRow('Usage Type', vehicle.usage.usageType),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Service',
            Icons.build,
            const Color(0xFF9C27B0),
            [
              _buildDetailRow('Last Service', DateFormat('dd MMM yyyy').format(vehicle.service.lastServiceDate)),
              _buildDetailRow('Next Service Due', '${vehicle.service.nextServiceDueKm} km'),
              _buildDetailRow('Service Center', vehicle.service.serviceCenter),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Insurance',
            Icons.security,
            const Color(0xFFE91E63),
            [
              _buildDetailRow('Provider', vehicle.insurance.provider),
              _buildDetailRow('Policy Expiry', DateFormat('dd MMM yyyy').format(vehicle.insurance.policyExpiry)),
              _buildDetailRow('Policy Type', vehicle.insurance.policyType),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddVehicleFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Vehicle Details'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.8),
            const Color(0xFF2D3561).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicleState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              color: Color(0xFF6C63FF),
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Vehicle Added',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your vehicle details to get started',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddVehicleFormPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
