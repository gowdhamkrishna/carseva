import 'package:carseva/carinfo/presentation/bloc/car_info_bloc.dart';
import 'package:carseva/carinfo/presentation/bloc/car_info_event.dart';
import 'package:carseva/carinfo/presentation/bloc/car_info_state.dart';
import 'package:carseva/carinfo/presentation/models/car_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Example usage of CarUIModel with CarInfoBloc
/// 
/// This demonstrates how to:
/// 1. Use CarUIModel in a form
/// 2. Validate user input
/// 3. Save car details using BLoC
/// 4. Load existing car details
class CarInfoExample extends StatefulWidget {
  final String userId;

  const CarInfoExample({super.key, required this.userId});

  @override
  State<CarInfoExample> createState() => _CarInfoExampleState();
}

class _CarInfoExampleState extends State<CarInfoExample> {
  late CarUIModel carModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    carModel = CarUIModel();
    // Load existing car info when widget initializes
    context.read<CarInfoBloc>().add(LoadCarInfoEvent(widget.userId));
  }

  void _saveCar() {
    if (carModel.isValid()) {
      // Convert UI model to entity and save
      final entity = carModel.toEntity();
      context.read<CarInfoBloc>().add(
            SaveCarInfoEvent(
              userId: widget.userId,
              car: entity,
            ),
          );
    } else {
      // Show validation errors
      final errors = carModel.getValidationErrors();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix errors: ${errors.values.join(', ')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Information')),
      body: BlocConsumer<CarInfoBloc, CarInfoState>(
        listener: (context, state) {
          if (state is CarInfoSavedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Car details saved successfully!')),
            );
          } else if (state is CarInfoLoadedState) {
            // Update UI model with loaded data
            setState(() {
              carModel = CarUIModel.fromEntity(state.car);
            });
          } else if (state is CarInfoErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is CarInfoLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vehicle Information Section
                  _buildSectionHeader('Vehicle Information'),
                  TextFormField(
                    initialValue: carModel.brand,
                    decoration: const InputDecoration(labelText: 'Brand'),
                    onChanged: (value) => carModel.brand = value,
                  ),
                  TextFormField(
                    initialValue: carModel.model,
                    decoration: const InputDecoration(labelText: 'Model'),
                    onChanged: (value) => carModel.model = value,
                  ),
                  TextFormField(
                    initialValue: carModel.variant,
                    decoration: const InputDecoration(labelText: 'Variant'),
                    onChanged: (value) => carModel.variant = value,
                  ),
                  TextFormField(
                    initialValue: carModel.year.toString(),
                    decoration: const InputDecoration(labelText: 'Year'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => carModel.year = int.tryParse(value) ?? 2024,
                  ),

                  // Registration Information Section
                  const SizedBox(height: 24),
                  _buildSectionHeader('Registration Information'),
                  TextFormField(
                    initialValue: carModel.registrationNumber,
                    decoration: const InputDecoration(labelText: 'Registration Number'),
                    onChanged: (value) => carModel.registrationNumber = value,
                  ),
                  TextFormField(
                    initialValue: carModel.state,
                    decoration: const InputDecoration(labelText: 'State'),
                    onChanged: (value) => carModel.state = value,
                  ),
                  TextFormField(
                    initialValue: carModel.city,
                    decoration: const InputDecoration(labelText: 'City'),
                    onChanged: (value) => carModel.city = value,
                  ),

                  // Ownership Information Section
                  const SizedBox(height: 24),
                  _buildSectionHeader('Ownership Information'),
                  TextFormField(
                    initialValue: carModel.purchasePrice.toString(),
                    decoration: const InputDecoration(labelText: 'Purchase Price'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        carModel.purchasePrice = int.tryParse(value) ?? 0,
                  ),
                  SwitchListTile(
                    title: const Text('Financed'),
                    value: carModel.isFinanced,
                    onChanged: (value) => setState(() => carModel.isFinanced = value),
                  ),

                  // Usage Information Section
                  const SizedBox(height: 24),
                  _buildSectionHeader('Usage Information'),
                  TextFormField(
                    initialValue: carModel.odometerKm.toString(),
                    decoration: const InputDecoration(labelText: 'Odometer (km)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        carModel.odometerKm = int.tryParse(value) ?? 0,
                  ),

                  // Save Button
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveCar,
                    child: const Text('Save Car Details'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
