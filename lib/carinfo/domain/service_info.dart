class ServiceInfo {
  final DateTime lastServiceDate;
  final int nextServiceDueKm;
  final String serviceCenter;

  const ServiceInfo({
    required this.lastServiceDate,
    required this.nextServiceDueKm,
    required this.serviceCenter,
  });
}
