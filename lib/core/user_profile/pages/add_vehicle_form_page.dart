import 'package:carseva/carinfo/domain/entities/car_entity.dart';
import 'package:carseva/carinfo/domain/insuarace.dart';
import 'package:carseva/carinfo/domain/ownership_info.dart';
import 'package:carseva/carinfo/domain/register_info.dart';
import 'package:carseva/carinfo/domain/service_info.dart';
import 'package:carseva/carinfo/domain/usage_info.dart';
import 'package:carseva/carinfo/domain/vehicle_info.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddVehicleFormPage extends StatefulWidget {
  const AddVehicleFormPage({super.key});

  @override
  State<AddVehicleFormPage> createState() => _AddVehicleFormPageState();
}

class _AddVehicleFormPageState extends State<AddVehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Vehicle Info
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _variantController = TextEditingController();
  final _yearController = TextEditingController();
  String _fuelType = 'Petrol';
  String _transmission = 'Manual';

  // Registration Info
  final _regNumberController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  // Ownership Info
  DateTime _purchaseDate = DateTime.now();
  final _purchasePriceController = TextEditingController();
  String _ownershipType = 'First Owner';
  bool _isFinanced = false;

  // Usage Info
  final _odometerController = TextEditingController();
  final _dailyAverageController = TextEditingController();
  String _usageType = 'Personal';

  // Service Info
  DateTime _lastServiceDate = DateTime.now();
  final _nextServiceDueController = TextEditingController();
  final _serviceCenterController = TextEditingController();

  // Insurance Info
  final _insuranceProviderController = TextEditingController();
  DateTime _policyExpiry = DateTime.now().add(const Duration(days: 365));
  String _policyType = 'Comprehensive';

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _variantController.dispose();
    _yearController.dispose();
    _regNumberController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _purchasePriceController.dispose();
    _odometerController.dispose();
    _dailyAverageController.dispose();
    _nextServiceDueController.dispose();
    _serviceCenterController.dispose();
    _insuranceProviderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        title: const Text(
          'Add Vehicle',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: _buildControls,
          type: StepperType.vertical,
          steps: [
            _buildVehicleInfoStep(),
            _buildRegistrationStep(),
            _buildOwnershipStep(),
            _buildUsageStep(),
            _buildServiceStep(),
            _buildInsuranceStep(),
          ],
        ),
      ),
    );
  }

  Step _buildVehicleInfoStep() {
    return Step(
      title: const Text('Vehicle Information', style: TextStyle(color: Colors.white)),
      content: Column(
        children: [
          _buildTextField(_brandController, 'Brand', 'e.g., Honda, Toyota'),
          _buildTextField(_modelController, 'Model', 'e.g., City, Fortuner'),
          _buildTextField(_variantController, 'Variant', 'e.g., VX CVT, ZX'),
          _buildTextField(_yearController, 'Year', 'e.g., 2023', isNumber: true),
          _buildDropdown('Fuel Type', _fuelType, ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'], (val) {
            setState(() => _fuelType = val!);
          }),
          _buildDropdown('Transmission', _transmission, ['Manual', 'Automatic', 'CVT', 'AMT'], (val) {
            setState(() => _transmission = val!);
          }),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildRegistrationStep() {
    return Step(
      title: const Text('Registration', style: TextStyle(color: Colors.white)),
      content: Column(
        children: [
          _buildTextField(_regNumberController, 'Registration Number', 'e.g., MH12AB1234'),
          _buildTextField(_stateController, 'State', 'e.g., Maharashtra'),
          _buildTextField(_cityController, 'City', 'e.g., Mumbai'),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildOwnershipStep() {
    return Step(
      title: const Text('Ownership', style: TextStyle(color: Colors.white)),
      content: Column(
        children: [
          _buildDatePicker('Purchase Date', _purchaseDate, (date) {
            setState(() => _purchaseDate = date);
          }),
          _buildTextField(_purchasePriceController, 'Purchase Price (₹)', 'e.g., 1200000', isNumber: true),
          _buildDropdown('Ownership Type', _ownershipType, ['First Owner', 'Second Owner', 'Third Owner', 'Fourth+ Owner'], (val) {
            setState(() => _ownershipType = val!);
          }),
          _buildSwitch('Is Financed?', _isFinanced, (val) {
            setState(() => _isFinanced = val);
          }),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildUsageStep() {
    return Step(
      title: const Text('Usage', style: TextStyle(color: Colors.white)),
      content: Column(
        children: [
          _buildTextField(_odometerController, 'Current Odometer (km)', 'e.g., 45000', isNumber: true),
          _buildTextField(_dailyAverageController, 'Daily Average (km)', 'e.g., 50', isNumber: true),
          _buildDropdown('Usage Type', _usageType, ['Personal', 'Commercial', 'Taxi'], (val) {
            setState(() => _usageType = val!);
          }),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildServiceStep() {
    return Step(
      title: const Text('Service', style: TextStyle(color: Colors.white)),
      content: Column(
        children: [
          _buildDatePicker('Last Service Date', _lastServiceDate, (date) {
            setState(() => _lastServiceDate = date);
          }),
          _buildTextField(_nextServiceDueController, 'Next Service Due (km)', 'e.g., 50000', isNumber: true),
          _buildTextField(_serviceCenterController, 'Service Center', 'e.g., Honda Service Center'),
        ],
      ),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildInsuranceStep() {
    return Step(
      title: const Text('Insurance', style: TextStyle(color: Colors.white)),
      content: Column(
        children: [
          _buildTextField(_insuranceProviderController, 'Provider', 'e.g., HDFC ERGO'),
          _buildDatePicker('Policy Expiry', _policyExpiry, (date) {
            setState(() => _policyExpiry = date);
          }),
          _buildDropdown('Policy Type', _policyType, ['Comprehensive', 'Third Party', 'Zero Depreciation'], (val) {
            setState(() => _policyType = val!);
          }),
        ],
      ),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: const Color(0xFF1A1F3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF1A1F3A),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
          filled: true,
          fillColor: const Color(0xFF1A1F3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, void Function(DateTime) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF6C63FF),
                    surface: Color(0xFF1A1F3A),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) onDateSelected(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
            filled: true,
            fillColor: const Color(0xFF1A1F3A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.3)),
            ),
          ),
          child: Text(
            '${date.day}/${date.month}/${date.year}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, void Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep < 5)
            ElevatedButton(
              onPressed: details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Continue'),
            ),
          if (_currentStep == 5)
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Submit'),
            ),
          const SizedBox(width: 12),
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Back', style: TextStyle(color: Color(0xFF6C63FF))),
            ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final vehicle = UserCarEntity(
        vehicle: VehicleInfo(
          brand: _brandController.text,
          model: _modelController.text,
          variant: _variantController.text,
          year: int.parse(_yearController.text),
          fuelType: _fuelType,
          transmission: _transmission,
        ),
        registration: RegistrationInfo(
          registrationNumber: _regNumberController.text,
          state: _stateController.text,
          city: _cityController.text,
        ),
        ownership: OwnershipInfo(
          purchaseDate: _purchaseDate,
          purchasePrice: int.parse(_purchasePriceController.text),
          ownershipType: _ownershipType,
          isFinanced: _isFinanced,
        ),
        usage: UsageInfo(
          odometerKm: int.parse(_odometerController.text),
          dailyAverageKm: int.parse(_dailyAverageController.text),
          usageType: _usageType,
        ),
        service: ServiceInfo(
          lastServiceDate: _lastServiceDate,
          nextServiceDueKm: int.parse(_nextServiceDueController.text),
          serviceCenter: _serviceCenterController.text,
        ),
        insurance: InsuranceInfo(
          provider: _insuranceProviderController.text,
          policyExpiry: _policyExpiry,
          policyType: _policyType,
        ),
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<UserProfileBloc>().add(
              UpdateVehicleEvent(userId: userId, vehicle: vehicle),
            );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    }
  }
}
