import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carseva/core/constants/car_data_constants.dart';
import 'package:carseva/core/widgets/autocomplete_text_field.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/prediction_result_card.dart';

class AvailabilityPredictionPage extends StatefulWidget {
  const AvailabilityPredictionPage({super.key});

  @override
  State<AvailabilityPredictionPage> createState() =>
      _AvailabilityPredictionPageState();
}

class _AvailabilityPredictionPageState
    extends State<AvailabilityPredictionPage> {
  final _carModelController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void dispose() {
    _carModelController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _predictAvailability() {
    if (_carModelController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<MarketBloc>().add(
          PredictAvailabilityEvent(
            carModel: _carModelController.text.trim(),
            area: _areaController.text.trim(),
            city: _cityController.text.trim(),
            pincode: _pincodeController.text.trim().isEmpty
                ? null
                : _pincodeController.text.trim(),
          ),
        );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 24),
                BlocBuilder<MarketBloc, MarketState>(
                  builder: (context, state) {
                    if (state is MarketLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      );
                    }

                    if (state is AvailabilityPredicted) {
                      return PredictionResultCard(
                        prediction: state.prediction,
                      );
                    }

                    if (state is MarketError) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.message,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.location_searching,
            color: Color(0xFF6C63FF), size: 28),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Availability Prediction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.8),
            const Color(0xFF2D3561).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Car Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          AutocompleteTextField(
            controller: _carModelController,
            label: 'Car Model *',
            hint: 'e.g., Honda City, Maruti Swift',
            suggestions: CarDataConstants.getAllModels(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter car model';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Location Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          AutocompleteTextField(
            controller: _cityController,
            label: 'City *',
            hint: 'e.g., Mumbai, Delhi, Bangalore',
            suggestions: CarDataConstants.cities,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _areaController,
            label: 'Area / Locality *',
            hint: 'e.g., Andheri, Connaught Place',
            icon: Icons.place,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _pincodeController,
            label: 'Pincode (Optional)',
            hint: 'e.g., 400053',
            icon: Icons.pin,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _predictAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Predict Availability',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }
}

