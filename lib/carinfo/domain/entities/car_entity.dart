import 'package:carseva/carinfo/domain/insuarace.dart';
import 'package:carseva/carinfo/domain/ownership_info.dart';
import 'package:carseva/carinfo/domain/register_info.dart';
import 'package:carseva/carinfo/domain/service_info.dart';
import 'package:carseva/carinfo/domain/usage_info.dart';
import 'package:carseva/carinfo/domain/vehicle_info.dart';

class UserCarEntity {
  final VehicleInfo vehicle;
  final RegistrationInfo registration;
  final OwnershipInfo ownership;
  final UsageInfo usage;
  final ServiceInfo service;
  final InsuranceInfo insurance;

  const UserCarEntity({
    required this.vehicle,
    required this.registration,
    required this.ownership,
    required this.usage,
    required this.service,
    required this.insurance,
  });
}
