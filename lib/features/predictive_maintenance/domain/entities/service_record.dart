class ServiceRecord {
  final String id;
  final String carId;
  final DateTime serviceDate;
  final int mileageAtService;
  final String serviceType; // e.g., "Oil Change", "Brake Service"
  final String? serviceCenter;
  final double cost;
  final List<String> partsReplaced;
  final String? notes;
  final List<String>? photoUrls;
  final String? mechanicRating; // e.g., "5/5"

  const ServiceRecord({
    required this.id,
    required this.carId,
    required this.serviceDate,
    required this.mileageAtService,
    required this.serviceType,
    this.serviceCenter,
    required this.cost,
    required this.partsReplaced,
    this.notes,
    this.photoUrls,
    this.mechanicRating,
  });

  int daysSinceService() {
    return DateTime.now().difference(serviceDate).inDays;
  }
}
