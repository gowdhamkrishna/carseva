import 'package:carseva/carinfo/domain/entities/car_entity.dart';
import 'package:carseva/carinfo/domain/insuarace.dart';
import 'package:carseva/carinfo/domain/ownership_info.dart';
import 'package:carseva/carinfo/domain/register_info.dart';
import 'package:carseva/carinfo/domain/service_info.dart';
import 'package:carseva/carinfo/domain/usage_info.dart';
import 'package:carseva/carinfo/domain/vehicle_info.dart';

/// UI Model for managing car information in forms and UI components
class CarUIModel {
  // Vehicle Information
  String brand;
  String model;
  String variant;
  int year;
  String fuelType;
  String transmission;

  // Registration Information
  String registrationNumber;
  String state;
  String city;

  // Ownership Information
  DateTime purchaseDate;
  int purchasePrice;
  String ownershipType;
  bool isFinanced;

  // Usage Information
  int odometerKm;
  int dailyAverageKm;
  String usageType;

  // Service Information
  DateTime lastServiceDate;
  int nextServiceDueKm;
  String serviceCenter;

  // Insurance Information
  String insuranceProvider;
  DateTime policyExpiry;
  String policyType;

  CarUIModel({
    // Vehicle
    this.brand = '',
    this.model = '',
    this.variant = '',
    this.year = 2024,
    this.fuelType = '',
    this.transmission = '',
    // Registration
    this.registrationNumber = '',
    this.state = '',
    this.city = '',
    // Ownership
    DateTime? purchaseDate,
    this.purchasePrice = 0,
    this.ownershipType = '',
    this.isFinanced = false,
    // Usage
    this.odometerKm = 0,
    this.dailyAverageKm = 0,
    this.usageType = '',
    // Service
    DateTime? lastServiceDate,
    this.nextServiceDueKm = 0,
    this.serviceCenter = '',
    // Insurance
    this.insuranceProvider = '',
    DateTime? policyExpiry,
    this.policyType = '',
  })  : purchaseDate = purchaseDate ?? DateTime.now(),
        lastServiceDate = lastServiceDate ?? DateTime.now(),
        policyExpiry = policyExpiry ?? DateTime.now().add(const Duration(days: 365));

  /// Create UI model from domain entity
  factory CarUIModel.fromEntity(UserCarEntity entity) {
    return CarUIModel(
      // Vehicle
      brand: entity.vehicle.brand,
      model: entity.vehicle.model,
      variant: entity.vehicle.variant,
      year: entity.vehicle.year,
      fuelType: entity.vehicle.fuelType,
      transmission: entity.vehicle.transmission,
      // Registration
      registrationNumber: entity.registration.registrationNumber,
      state: entity.registration.state,
      city: entity.registration.city,
      // Ownership
      purchaseDate: entity.ownership.purchaseDate,
      purchasePrice: entity.ownership.purchasePrice,
      ownershipType: entity.ownership.ownershipType,
      isFinanced: entity.ownership.isFinanced,
      // Usage
      odometerKm: entity.usage.odometerKm,
      dailyAverageKm: entity.usage.dailyAverageKm,
      usageType: entity.usage.usageType,
      // Service
      lastServiceDate: entity.service.lastServiceDate,
      nextServiceDueKm: entity.service.nextServiceDueKm,
      serviceCenter: entity.service.serviceCenter,
      // Insurance
      insuranceProvider: entity.insurance.provider,
      policyExpiry: entity.insurance.policyExpiry,
      policyType: entity.insurance.policyType,
    );
  }

  /// Convert UI model to domain entity
  UserCarEntity toEntity() {
    return UserCarEntity(
      vehicle: VehicleInfo(
        brand: brand,
        model: model,
        variant: variant,
        year: year,
        fuelType: fuelType,
        transmission: transmission,
      ),
      registration: RegistrationInfo(
        registrationNumber: registrationNumber,
        state: state,
        city: city,
      ),
      ownership: OwnershipInfo(
        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        ownershipType: ownershipType,
        isFinanced: isFinanced,
      ),
      usage: UsageInfo(
        odometerKm: odometerKm,
        dailyAverageKm: dailyAverageKm,
        usageType: usageType,
      ),
      service: ServiceInfo(
        lastServiceDate: lastServiceDate,
        nextServiceDueKm: nextServiceDueKm,
        serviceCenter: serviceCenter,
      ),
      insurance: InsuranceInfo(
        provider: insuranceProvider,
        policyExpiry: policyExpiry,
        policyType: policyType,
      ),
    );
  }

  /// Create a copy with modified fields
  CarUIModel copyWith({
    String? brand,
    String? model,
    String? variant,
    int? year,
    String? fuelType,
    String? transmission,
    String? registrationNumber,
    String? state,
    String? city,
    DateTime? purchaseDate,
    int? purchasePrice,
    String? ownershipType,
    bool? isFinanced,
    int? odometerKm,
    int? dailyAverageKm,
    String? usageType,
    DateTime? lastServiceDate,
    int? nextServiceDueKm,
    String? serviceCenter,
    String? insuranceProvider,
    DateTime? policyExpiry,
    String? policyType,
  }) {
    return CarUIModel(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      state: state ?? this.state,
      city: city ?? this.city,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      ownershipType: ownershipType ?? this.ownershipType,
      isFinanced: isFinanced ?? this.isFinanced,
      odometerKm: odometerKm ?? this.odometerKm,
      dailyAverageKm: dailyAverageKm ?? this.dailyAverageKm,
      usageType: usageType ?? this.usageType,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceDueKm: nextServiceDueKm ?? this.nextServiceDueKm,
      serviceCenter: serviceCenter ?? this.serviceCenter,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      policyExpiry: policyExpiry ?? this.policyExpiry,
      policyType: policyType ?? this.policyType,
    );
  }

  /// Validate if all required fields are filled
  bool isValid() {
    return brand.isNotEmpty &&
        model.isNotEmpty &&
        variant.isNotEmpty &&
        year > 1900 &&
        fuelType.isNotEmpty &&
        transmission.isNotEmpty &&
        registrationNumber.isNotEmpty &&
        state.isNotEmpty &&
        city.isNotEmpty &&
        ownershipType.isNotEmpty &&
        usageType.isNotEmpty &&
        serviceCenter.isNotEmpty &&
        insuranceProvider.isNotEmpty &&
        policyType.isNotEmpty;
  }

  /// Get validation errors
  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};

    if (brand.isEmpty) errors['brand'] = 'Brand is required';
    if (model.isEmpty) errors['model'] = 'Model is required';
    if (variant.isEmpty) errors['variant'] = 'Variant is required';
    if (year <= 1900) errors['year'] = 'Valid year is required';
    if (fuelType.isEmpty) errors['fuelType'] = 'Fuel type is required';
    if (transmission.isEmpty) errors['transmission'] = 'Transmission is required';
    if (registrationNumber.isEmpty) {
      errors['registrationNumber'] = 'Registration number is required';
    }
    if (state.isEmpty) errors['state'] = 'State is required';
    if (city.isEmpty) errors['city'] = 'City is required';
    if (ownershipType.isEmpty) errors['ownershipType'] = 'Ownership type is required';
    if (usageType.isEmpty) errors['usageType'] = 'Usage type is required';
    if (serviceCenter.isEmpty) errors['serviceCenter'] = 'Service center is required';
    if (insuranceProvider.isEmpty) {
      errors['insuranceProvider'] = 'Insurance provider is required';
    }
    if (policyType.isEmpty) errors['policyType'] = 'Policy type is required';

    return errors;
  }

  @override
  String toString() {
    return 'CarUIModel(brand: $brand, model: $model, variant: $variant, '
        'registrationNumber: $registrationNumber)';
  }
}
