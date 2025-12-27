import 'package:carseva/carinfo/domain/entities/car_entity.dart';
import 'package:carseva/carinfo/domain/insuarace.dart';
import 'package:carseva/carinfo/domain/ownership_info.dart';
import 'package:carseva/carinfo/domain/register_info.dart';
import 'package:carseva/carinfo/domain/service_info.dart';
import 'package:carseva/carinfo/domain/usage_info.dart';
import 'package:carseva/carinfo/domain/vehicle_info.dart';

class VehicleInfoModel extends VehicleInfo {
  const VehicleInfoModel({
    required super.brand,
    required super.model,
    required super.variant,
    required super.year,
    required super.fuelType,
    required super.transmission,
  });

  factory VehicleInfoModel.fromMap(Map<String, dynamic> map) {
    return VehicleInfoModel(
      brand: map['brand'] as String,
      model: map['model'] as String,
      variant: map['variant'] as String,
      year: map['year'] as int,
      fuelType: map['fuelType'] as String,
      transmission: map['transmission'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'variant': variant,
      'year': year,
      'fuelType': fuelType,
      'transmission': transmission,
    };
  }
}

class RegistrationInfoModel extends RegistrationInfo {
  const RegistrationInfoModel({
    required super.registrationNumber,
    required super.state,
    required super.city,
  });

  factory RegistrationInfoModel.fromMap(Map<String, dynamic> map) {
    return RegistrationInfoModel(
      registrationNumber: map['registrationNumber'] as String,
      state: map['state'] as String,
      city: map['city'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'registrationNumber': registrationNumber,
      'state': state,
      'city': city,
    };
  }
}

class OwnershipInfoModel extends OwnershipInfo {
  const OwnershipInfoModel({
    required super.purchaseDate,
    required super.purchasePrice,
    required super.ownershipType,
    required super.isFinanced,
  });

  factory OwnershipInfoModel.fromMap(Map<String, dynamic> map) {
    return OwnershipInfoModel(
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      purchasePrice: map['purchasePrice'] as int,
      ownershipType: map['ownershipType'] as String,
      isFinanced: map['isFinanced'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'purchaseDate': purchaseDate.toIso8601String(),
      'purchasePrice': purchasePrice,
      'ownershipType': ownershipType,
      'isFinanced': isFinanced,
    };
  }
}

class UsageInfoModel extends UsageInfo {
  const UsageInfoModel({
    required super.odometerKm,
    required super.dailyAverageKm,
    required super.usageType,
  });

  factory UsageInfoModel.fromMap(Map<String, dynamic> map) {
    return UsageInfoModel(
      odometerKm: map['odometerKm'] as int,
      dailyAverageKm: map['dailyAverageKm'] as int,
      usageType: map['usageType'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'odometerKm': odometerKm,
      'dailyAverageKm': dailyAverageKm,
      'usageType': usageType,
    };
  }
}

class ServiceInfoModel extends ServiceInfo {
  const ServiceInfoModel({
    required super.lastServiceDate,
    required super.nextServiceDueKm,
    required super.serviceCenter,
  });

  factory ServiceInfoModel.fromMap(Map<String, dynamic> map) {
    return ServiceInfoModel(
      lastServiceDate: DateTime.parse(map['lastServiceDate'] as String),
      nextServiceDueKm: map['nextServiceDueKm'] as int,
      serviceCenter: map['serviceCenter'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'nextServiceDueKm': nextServiceDueKm,
      'serviceCenter': serviceCenter,
    };
  }
}

class InsuranceInfoModel extends InsuranceInfo {
  const InsuranceInfoModel({
    required super.provider,
    required super.policyExpiry,
    required super.policyType,
  });

  factory InsuranceInfoModel.fromMap(Map<String, dynamic> map) {
    return InsuranceInfoModel(
      provider: map['provider'] as String,
      policyExpiry: DateTime.parse(map['policyExpiry'] as String),
      policyType: map['policyType'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider': provider,
      'policyExpiry': policyExpiry.toIso8601String(),
      'policyType': policyType,
    };
  }
}

class UserCarModel extends UserCarEntity {
  const UserCarModel({
    required super.vehicle,
    required super.registration,
    required super.ownership,
    required super.usage,
    required super.service,
    required super.insurance,
  });

  factory UserCarModel.fromFirestore(Map<String, dynamic> data) {
    return UserCarModel(
      vehicle: VehicleInfoModel.fromMap(data['vehicle'] as Map<String, dynamic>),
      registration: RegistrationInfoModel.fromMap(data['registration'] as Map<String, dynamic>),
      ownership: OwnershipInfoModel.fromMap(data['ownership'] as Map<String, dynamic>),
      usage: UsageInfoModel.fromMap(data['usage'] as Map<String, dynamic>),
      service: ServiceInfoModel.fromMap(data['service'] as Map<String, dynamic>),
      insurance: InsuranceInfoModel.fromMap(data['insurance'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicle': (vehicle as VehicleInfoModel).toMap(),
      'registration': (registration as RegistrationInfoModel).toMap(),
      'ownership': (ownership as OwnershipInfoModel).toMap(),
      'usage': (usage as UsageInfoModel).toMap(),
      'service': (service as ServiceInfoModel).toMap(),
      'insurance': (insurance as InsuranceInfoModel).toMap(),
    };
  }

  factory UserCarModel.fromEntity(UserCarEntity entity) {
    return UserCarModel(
      vehicle: VehicleInfoModel(
        brand: entity.vehicle.brand,
        model: entity.vehicle.model,
        variant: entity.vehicle.variant,
        year: entity.vehicle.year,
        fuelType: entity.vehicle.fuelType,
        transmission: entity.vehicle.transmission,
      ),
      registration: RegistrationInfoModel(
        registrationNumber: entity.registration.registrationNumber,
        state: entity.registration.state,
        city: entity.registration.city,
      ),
      ownership: OwnershipInfoModel(
        purchaseDate: entity.ownership.purchaseDate,
        purchasePrice: entity.ownership.purchasePrice,
        ownershipType: entity.ownership.ownershipType,
        isFinanced: entity.ownership.isFinanced,
      ),
      usage: UsageInfoModel(
        odometerKm: entity.usage.odometerKm,
        dailyAverageKm: entity.usage.dailyAverageKm,
        usageType: entity.usage.usageType,
      ),
      service: ServiceInfoModel(
        lastServiceDate: entity.service.lastServiceDate,
        nextServiceDueKm: entity.service.nextServiceDueKm,
        serviceCenter: entity.service.serviceCenter,
      ),
      insurance: InsuranceInfoModel(
        provider: entity.insurance.provider,
        policyExpiry: entity.insurance.policyExpiry,
        policyType: entity.insurance.policyType,
      ),
    );
  }
}
